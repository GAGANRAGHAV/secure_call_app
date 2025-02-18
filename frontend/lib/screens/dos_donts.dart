import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class Dos_dontsPage extends StatefulWidget {
  @override
  _Dos_dontsPageState createState() => _Dos_dontsPageState();
}

class _Dos_dontsPageState extends State<Dos_dontsPage> {
  String activeTab = "threats";
  final FlutterTts flutterTts = FlutterTts();
  bool isSpeaking = false;

  final List<Map<String, dynamic>> scamTypes = [
    {
      "icon": Icons.qr_code_scanner_outlined,
      "title": "QR Code Scams",
      "desc": "Fraudsters use fake QR codes to steal your payment information. Always verify QR codes from trusted sources.",
      "color": Colors.purple,
    },
    {
      "icon": Icons.download_outlined,
      "title": "Fake Apps",
      "desc": "Be cautious of screen-sharing apps or APK files from untrusted sources. Only download from official app stores.",
      "color": Colors.blue,
    },
    {
      "icon": Icons.savings_outlined,
      "title": "Investment Scams",
      "desc": "Beware of schemes promising unrealistic returns. Verify all investment opportunities thoroughly.",
      "color": Colors.orange,
    },
    {
      "icon": Icons.search_outlined,
      "title": "Search Engine Scams",
      "desc": "Avoid clicking on suspicious ads or search results. Use official websites directly.",
      "color": Colors.green,
    },
    {
      "icon": Icons.message_outlined,
      "title": "SMS/Chat Threats",
      "desc": "Never share OTPs or personal information via SMS or social media chat.",
      "color": Colors.red,
    },
  ];

  final Map<String, List<String>> safetyTips = {
    "dos": [
      "Keep your mobile number updated in bank records.",
      "Only enter UPI PIN for payments, never for receiving money.",
      "Check in-app notifications during transactions.",
      "Verify bank contact details from the official website.",
      "Report issues only to bank or police authorities.",
    ],
    "donts": [
      "Never share SMS or OTPs with unknown persons.",
      "Keep debit card details and UPI PIN private.",
      "Avoid screen-sharing apps during transactions.",
      "Don't post transaction details on social media.",
      "Never transact while on call with strangers.",
    ],
  };

  Future<void> speakText(String text) async {
    if (!isSpeaking) {
      await flutterTts.setLanguage("en-US");
      await flutterTts.speak(text);
      setState(() => isSpeaking = true);

      flutterTts.setCompletionHandler(() {
        setState(() => isSpeaking = false);
      });
    }
  }

  Future<void> stopSpeech() async {
    await flutterTts.stop();
    setState(() => isSpeaking = false);
  }

  String prepareSpeechText() {
    if (activeTab == "threats") {
      return scamTypes.map((scam) => "${scam['title']}: ${scam['desc']}").join(". ");
    } else {
      final dos = safetyTips['dos']!.join(". ");
      final donts = safetyTips['donts']!.join(". ");
      return "Do's: $dos. Don'ts: $donts";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 100.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Do\'s and Don\'ts',
                style: TextStyle(fontWeight: FontWeight.bold),
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
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildTabButton("Threats", "threats"),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: _buildTabButton("Safety Tips", "safety"),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => speakText(prepareSpeechText()),
                                  icon: Icon(isSpeaking ? Icons.volume_up : Icons.volume_up_outlined),
                                  label: Text(isSpeaking ? "Speaking..." : "Listen"),
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    backgroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: stopSpeech,
                                  icon: Icon(Icons.stop_outlined),
                                  label: Text("Stop"),
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    backgroundColor: Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          activeTab == "threats" ? _buildThreatsList() : _buildSafetyTips(),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, String tab) {
    final isActive = activeTab == tab;
    return ElevatedButton(
      onPressed: () => setState(() => activeTab = tab),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 12),
        backgroundColor: isActive ? Theme.of(context).primaryColor : Colors.grey[200],
        foregroundColor: isActive ? Colors.white : Colors.grey[800],
        elevation: isActive ? 2 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(fontWeight: isActive ? FontWeight.bold : FontWeight.normal),
      ),
    );
  }

  Widget _buildThreatsList() {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final scam = scamTypes[index];
            return Card(
              elevation: 2,
              margin: EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: scam["color"].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        scam["icon"],
                        color: scam["color"],
                        size: 28,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            scam["title"],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            scam["desc"],
                            style: TextStyle(
                              color: Colors.grey[600],
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          childCount: scamTypes.length,
        ),
      ),
    );
  }

  Widget _buildSafetyTips() {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          _buildTipsSection(
            "Do's",
            Icons.check_circle_outlined,
            Colors.green,
            safetyTips['dos']!,
          ),
          SizedBox(height: 16),
          _buildTipsSection(
            "Don'ts",
            Icons.warning_outlined,
            Colors.red,
            safetyTips['donts']!,
          ),
          SizedBox(height: 16),
        ]),
      ),
    );
  }

  Widget _buildTipsSection(String title, IconData icon, Color color, List<String> tips) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color),
                ),
                SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ...tips.map((tip) => Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      tip,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }
}