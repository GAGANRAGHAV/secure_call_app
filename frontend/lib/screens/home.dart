import 'package:flutter/material.dart';
import './awareness.dart';
import './chatbot.dart';
import './sms_analysis.dart';
import './dos_donts.dart';
import './recording_analysis.dart'; // Import the new page for recording analysis

class HomePage extends StatelessWidget {
  final List<Map<String, dynamic>> features = [
    {
      'icon': Icons.article_outlined,
      'title': 'Awareness Blogs',
      'description': 'Read & share scam prevention tips',
      'page': AwarenessPage(),
      'color': Colors.blue,
    },
    {
      'icon': Icons.chat_bubble_outline,
      'title': 'AI Chatbot',
      'description': 'Get scam-related assistance instantly',
      'page': ChatbotPage(),
      'color': Colors.green,
    },
    {
      'icon': Icons.sms_failed_outlined,
      'title': 'Message Analysis',
      'description': 'Detect scam messages in real-time',
      'page': SmsAnalysisPage(),
      'color': Colors.orange,
    },
    {
      'icon': Icons.rule_outlined,
      'title': "Do's & Don'ts",
      'description': 'Know how to stay safe from frauds',
      'page': Dos_dontsPage(),
      'color': Colors.purple,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'SecureCall',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.8),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.security,
                      size: 60,
                      color: Colors.white,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Stay protected from scams & frauds!',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Audio Scam Detection',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      Center(
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.upload_file),
                          label: Text("Upload & Analyze Recording"),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            textStyle: TextStyle(fontSize: 16),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      RecordingAnalysisPage()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final feature = features[index];
                  return _buildFeatureCard(context, feature);
                },
                childCount: features.length,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, Map<String, dynamic> feature) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => feature['page']),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: feature['color'].withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  feature['icon'],
                  size: 24,
                  color: feature['color'],
                ),
              ),
              SizedBox(height: 12),
              Text(
                feature['title'],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 6),
              Text(
                feature['description'],
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
