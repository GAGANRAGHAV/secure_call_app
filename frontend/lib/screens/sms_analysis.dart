import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';

class SmsAnalysisPage extends StatefulWidget {
  @override
  _SmsAnalysisPageState createState() => _SmsAnalysisPageState();
}

class _SmsAnalysisPageState extends State<SmsAnalysisPage> {
  List<SmsMessage> messages = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    requestSmsPermission();
  }

  Future<void> requestSmsPermission() async {
    var status = await Permission.sms.request();
    if (status.isGranted) {
      fetchMessages();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchMessages() async {
    SmsQuery query = SmsQuery();
    List<SmsMessage> smsList = await query.getAllSms;

    // Sort messages by date (latest first)
    smsList.sort((a, b) => (b.date ?? DateTime(0)).compareTo(a.date ?? DateTime(0)));

    setState(() {
      messages = smsList;
      isLoading = false;
    });
  }

  bool isSuspiciousMessage(String message) {
    List<String> scamKeywords = [
      "lottery", "win", "urgent", "account blocked", "click this link",
      "send money", "transfer", "password", "OTP", "verify", "update your details"
    ];

    List<String> suspiciousUrls = ["bit.ly", "tinyurl.com", "shorturl"];

    for (String keyword in scamKeywords) {
      if (message.toLowerCase().contains(keyword)) {
        return true;
      }
    }

    for (String url in suspiciousUrls) {
      if (message.toLowerCase().contains(url)) {
        return true;
      }
    }

    return false;
  }

  String formatDate(DateTime? dateTime) {
    if (dateTime == null) return "Unknown date";
    return DateFormat('MMM dd, h:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "SMS Analysis",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black54),
            onPressed: () {
              setState(() {
                isLoading = true;
              });
              fetchMessages();
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Analyzing messages...",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : messages.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.sms_failed, size: 48, color: Colors.black26),
                      SizedBox(height: 16),
                      Text(
                        "No messages found",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: messages.length,
                  separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[200]),
                  padding: EdgeInsets.symmetric(vertical: 8),
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    bool isSuspicious = isSuspiciousMessage(message.body ?? "");

                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  message.sender ?? "Unknown",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                formatDate(message.date),
                                style: TextStyle(
                                  color: Colors.black45,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6),
                          Text(
                            message.body ?? "No content",
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (isSuspicious)
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.red[50],
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: Colors.red[100]!),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.warning_amber_rounded, size: 14, color: Colors.red[700]),
                                      SizedBox(width: 4),
                                      Text(
                                        "Suspicious",
                                        style: TextStyle(
                                          color: Colors.red[700],
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green[50],
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: Colors.green[100]!),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.check_circle_outline, size: 14, color: Colors.green[700]),
                                      SizedBox(width: 4),
                                      Text(
                                        "Safe",
                                        style: TextStyle(
                                          color: Colors.green[700],
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}