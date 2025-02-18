const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const bodyParser = require("body-parser");
const multer = require("multer");
const path = require("path");

const app = express();
app.use(cors());
app.use(bodyParser.json());
app.use("/uploads", express.static("uploads"));

mongoose.connect("mongodb+srv://gaganraghav143:uiIs8pfGueSrUSdM@cluster0.3zkr6.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0", {
    useNewUrlParser: true,
    useUnifiedTopology: true,
})
.then(() => console.log("Connected to MongoDB"))
.catch((err) => console.log(err));

const BlogSchema = new mongoose.Schema({
    title: String,
    content: String,
    category: String,
    image: String,
});

const Blog = mongoose.model("Blog", BlogSchema);

// Multer setup for image upload
const storage = multer.diskStorage({
    destination: "./uploads/",
    filename: (req, file, cb) => {
        cb(null, file.fieldname + "-" + Date.now() + path.extname(file.originalname));
    },
});

const upload = multer({ storage: storage });

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

app.listen(5000, () => console.log("Server running on port 5000"));
