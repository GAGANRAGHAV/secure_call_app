import 'package:flutter/material.dart';
import 'screens/awareness.dart';
import 'screens/chatbot.dart';
import 'screens/sms_analysis.dart';
import 'screens/dos_donts.dart';
import 'screens/home.dart';

void main() {
  runApp(SecureCallApp());
}

class SecureCallApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        bottomNavigationBarTheme: BottomNavigationBarTheme.of(context).copyWith(
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 8.0,
          backgroundColor: Colors.white,
        ),
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _controller;
  late Animation<double> _animation;

  /// **Fix: The order of pages now matches the bottom navigation**
  final List<Widget> _pages = [
    HomePage(),       // 0 - Home (First tab)
    ChatbotPage(),    // 1 - Chatbot
    SmsAnalysisPage(), // 2 - SMS Analysis
    Dos_dontsPage(),   // 3 - Do's & Don'ts
    AwarenessPage(),  // 4 - Awareness (Last tab)
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _controller.reset();
      _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _animation,
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            items: [
              _buildNavItem(Icons.home_rounded, "Home"),           // 0
              _buildNavItem(Icons.chat_bubble_rounded, "Chatbot"), // 1
              _buildNavItem(Icons.message_rounded, "SMS Analysis"),// 2
              _buildNavItem(Icons.rule_folder_rounded, "Do's & Don'ts"), // 3
              _buildNavItem(Icons.article, "Awareness"),           // 4
            ],
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label) {
    return BottomNavigationBarItem(
      icon: Container(
        padding: EdgeInsets.symmetric(vertical: 5),
        child: Icon(icon),
      ),
      activeIcon: Container(
        padding: EdgeInsets.symmetric(vertical: 5),
        child: Column(
          children: [
            Icon(icon),
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
      label: label,
    );
  }
}
