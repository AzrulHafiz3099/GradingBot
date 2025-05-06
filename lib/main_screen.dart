import 'package:flutter/material.dart';
import 'Home_Page.dart';
import 'Analytics_Page.dart';
import 'Manage_Page.dart';
import 'Profile_Page.dart';
import 'widget/custom_button_nav.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    AnalyticsPage(),
    ManagePage(),
    ProfilePage(),
  ];

  void _onTabTapped(int index) {
    if (index == 4) {
      print("QR Scanner Pressed");
      // You can implement QR scanner page navigation here
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
