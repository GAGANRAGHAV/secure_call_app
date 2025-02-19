const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const bodyParser = require("body-parser");
const multer = require("multer");
const path = require("path");
const fs = require("fs");
const axios = require("axios");
const ffmpeg = require("fluent-ffmpeg");
const { GoogleGenerativeAI } = require("@google/generative-ai");

const app = express();
app.use(cors());

const GOOGLE_SPEECH_API_KEY = "AIzaSyBiIUJiunnW34aF5VLIIpEx1J_iKZRCvn0";
const GEMINI_API_KEY = "AIzaSyCOSX_kqyRGqdjaCzA4gc_2LzxIigPAkC0";

app.use(bodyParser.json());
app.use("/uploads", express.static("uploads"));

mongoose
  .connect("mongodb+srv://gaganraghav143:uiIs8pfGueSrUSdM@cluster0.3zkr6.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0", {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  })
  .then(() => console.log("Connected to MongoDB"))
  .catch((err) => console.log(err));

// Multer setup for audio uploads
const storage = multer.diskStorage({
  destination: "./uploads/",
  filename: (req, file, cb) => {
    cb(null, file.fieldname + "-" + Date.now() + path.extname(file.originalname));
  },
});

const upload = multer({ storage });


const BlogSchema = new mongoose.Schema({
    title: String,
    content: String,
    category: String,
    image: String,
  });
  
  const Blog = mongoose.model("Blog", BlogSchema);
  

// Scam Detection Criteria
const scamFlags = `
1️⃣ **Fake Authority Claims**:
   - The caller claims to be from TRAI, police, Cyber Crime, or RBI.
   - They mention legal terms like FIRs, arrest warrants, or money laundering.
2️⃣ **Fear and Urgency Tactics**:
   - Statements like "Your number is involved in illegal activities" or "You will be arrested soon."
   - Strict deadlines to create panic (e.g., "Your contacts will be disconnected in 2 hours").
3️⃣ **Request for Sensitive Information**:
   - Asking for bank details, Aadhaar number, PAN card.
   - Requesting OTPs, UPI details, or fund transfers for verification.
4️⃣ **Unusual Payment Requests**:
   - Asking the victim to transfer money to an unknown SBI bank account.
   - Claiming the transfer is for RBI verification (which is fake).
5️⃣ **Fake Video Calls for Credibility**:
   - Showing a person in a police uniform on WhatsApp video call.
   - Using fake case details to sound legitimate (e.g., Naresh Goyal’s money laundering case).
`;



// Create a blog
app.post("/create-blog", upload.single("image"), async (req, res) => {
    const { title, content, category } = req.body;
    const image = req.file ? req.file.path : "";
    const blog = new Blog({ title, content, category, image });
    await blog.save();
    res.json({ message: "Blog created successfully!" });
  });
  
  // Fetch blogs
  app.get("/blogs", async (req, res) => {
    const blogs = await Blog.find();
    res.json(blogs);
  });

// Function to convert audio to WAV format
async function convertToWav(inputFile, outputFile) {
  return new Promise((resolve, reject) => {
    ffmpeg(inputFile)
      .toFormat("wav")
      .audioChannels(1)
      .audioFrequency(48000)
      .on("end", () => resolve(outputFile))
      .on("error", (err) => reject(err))
      .save(outputFile);
  });
}

// Transcribe Audio using Google Speech API
async function transcribeAudio(audioFilePath) {
  const audioData = fs.readFileSync(audioFilePath);
  const audioBase64 = audioData.toString("base64");
  const url = `https://speech.googleapis.com/v1/speech:recognize?key=${GOOGLE_SPEECH_API_KEY}`;

  const requestBody = {
    config: { encoding: "LINEAR16", sampleRateHertz: 48000, languageCode: "en-US" },
    audio: { content: audioBase64 },
  };

  try {
    const response = await axios.post(url, requestBody);
    const transcription = response.data.results
      ? response.data.results.map((result) => result.alternatives[0].transcript).join(" ")
      : "";
    return transcription;
  } catch (error) {
    console.error("Error in transcription:", error.response?.data || error.message);
    return "";
  }
}

// Analyze Text with Gemini AI (Scam Detection)
async function analyzeTextWithGemini(transcription) {
  try {
    const genAI = new GoogleGenerativeAI(GEMINI_API_KEY);
    const model = genAI.getGenerativeModel({ model: "gemini-pro" });

    const prompt = `
        The following is a transcribed call recording between two people:
        --- 
        "${transcription}"
        ---
        Your task is to analyze whether this call exhibits scam behavior based on the following scam detection criteria:
        ${scamFlags}

        Instructions:
        - Identify if any scam indicators are present.
        - If a scam is detected, specify which scam flags are being violated.
        - If no scam is detected, provide a brief explanation.
        - Give a scam likelihood percentage (0-100%).
        - Conclude whether this is likely a scam call or not.

        Output format:
        - **Scam Likelihood**: X%
        - **Violations**: [List of violated flags]
        - **Analysis**: [Detailed explanation]
        - **Final Verdict**: [Is it a scam? Yes/No]
    `;

    const result = await model.generateContent(prompt);
    return result.response.text();
  } catch (error) {
    console.error("Gemini AI Error:", error.message);
    return "Error analyzing text.";
  }
}

// API Endpoint: Upload & Analyze Audio
app.post("/analyze-audio", upload.single("audio"), async (req, res) => {
  try {
    const filePath = req.file.path;
    const wavPath = filePath.replace(path.extname(filePath), ".wav");

    // Convert if necessary
    if (path.extname(filePath) !== ".wav") {
      await convertToWav(filePath, wavPath);
    }

    // Transcribe Audio
    const transcription = await transcribeAudio(wavPath);
    if (!transcription) return res.json({ error: "Failed to transcribe audio." });

    // Analyze for scam
    const analysis = await analyzeTextWithGemini(transcription);

    res.json({ transcription, analysis });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Internal server error." });
  }
});

app.listen(5000, () => console.log("Server running on port 5000"));
