import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_markdown/flutter_markdown.dart';

class RecordingAnalysisPage extends StatefulWidget {
  @override
  _RecordingAnalysisPageState createState() => _RecordingAnalysisPageState();
}

class _RecordingAnalysisPageState extends State<RecordingAnalysisPage> {
  File? _selectedFile;
  bool _isAnalyzing = false;
  String _transcription = "";
  String _analysisResult = "";

  Future<void> _pickAudioFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['wav', 'webm', 'aac'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _transcription = "";
        _analysisResult = "";
      });
    }
  }

  Future<void> _uploadAndAnalyzeAudio() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please select an audio file first"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.black87,
        ),
      );
      return;
    }

    setState(() => _isAnalyzing = true);

    try {
      var request = http.MultipartRequest(
        "POST",
        Uri.parse("https://692f-103-199-206-125.ngrok-free.app/analyze-audio"),
      );
      request.files.add(await http.MultipartFile.fromPath('audio', _selectedFile!.path));
      
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonData = jsonDecode(responseData);

      setState(() {
        _transcription = jsonData["transcription"] ?? "No transcription available";
        _analysisResult = jsonData["analysis"] ?? "No analysis available";
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error analyzing audio: ${e.toString()}"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red[700],
        ),
      );
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "Audio Analysis",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Upload Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Colors.grey[200]!),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Upload Recording",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16),
                  _selectedFile == null
                      ? _buildUploadButton()
                      : _buildFileInfo(),
                  if (_selectedFile != null) ...[
                    SizedBox(height: 16),
                    _buildAnalyzeButton(),
                  ],
                ],
              ),
            ),

            // Results Section
            if (_isAnalyzing)
              _buildLoadingState()
            else if (_transcription.isNotEmpty || _analysisResult.isNotEmpty)
              _buildResults(),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadButton() {
    return InkWell(
      onTap: _pickAudioFile,
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(Icons.cloud_upload_outlined, size: 48, color: Colors.blue[700]),
            SizedBox(height: 12),
            Text(
              "Select Audio File",
              style: TextStyle(
                color: Colors.blue[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Supported formats: WAV, WebM, AAC",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileInfo() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.audio_file, color: Colors.blue[700]),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedFile?.path.split('/').last ?? 'Selected File',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Ready for analysis',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.blue[700]),
            onPressed: () => setState(() => _selectedFile = null),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyzeButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isAnalyzing ? null : _uploadAndAnalyzeAudio,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16),
          backgroundColor: const Color.fromARGB(255, 152, 183, 214),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          "Analyze Recording",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: EdgeInsets.all(32),
      child: Column(
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
            strokeWidth: 2,
          ),
          SizedBox(height: 16),
          Text(
            "Analyzing audio...",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return Container(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_transcription.isNotEmpty) ...[
            _buildResultSection(
              title: "Transcription",
              icon: Icons.description_outlined,
              content: _transcription,
            ),
            SizedBox(height: 24),
          ],
          if (_analysisResult.isNotEmpty)
            _buildResultSection(
              title: "Analysis",
              icon: Icons.analytics_outlined,
              content: _analysisResult,
            ),
        ],
      ),
    );
  }

  Widget _buildResultSection({
    required String title,
    required IconData icon,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[700]),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: MarkdownBody(
            data: content,
            styleSheet: MarkdownStyleSheet(
              p: TextStyle(
                color: Colors.black87,
                height: 1.5,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}