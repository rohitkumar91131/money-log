import 'package:flutter/material.dart';

import '../widgets/premium_drawer.dart'; // Yeh sahi hai, same folder me hai
// 🚀 THE FIX: Added one more '../' to go back to the main 'features' folder
import '../../../expense/presentation/screens/homepage.dart';
import '../../../search/presentation/screens/search_screen.dart';
import '../../../analytics/presentation/screens/chart_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  // The screens in order
  final List<Widget> _screens = [
    const Homepage(),
    const SearchScreen(),
    const ChartScreen(),
    const ProfileScreen(),
    const SettingsScreen(),
  ];

  void _onMenuTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    Navigator.pop(context); // Close the drawer smoothly
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: PremiumDrawer(
        currentIndex: _currentIndex,
        onMenuTapped: _onMenuTapped,
      ),
      // IndexedStack keeps the state (like search text) alive when switching tabs
      body: IndexedStack(index: _currentIndex, children: _screens),
    );
  }
}
