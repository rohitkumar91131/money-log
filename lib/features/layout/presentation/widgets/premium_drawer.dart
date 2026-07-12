import 'package:flutter/material.dart';

class PremiumDrawer extends StatelessWidget {
  final int currentIndex;
  final Function(int) onMenuTapped;

  const PremiumDrawer({
    super.key,
    required this.currentIndex,
    required this.onMenuTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[50],
      child: SafeArea(
        child: Column(
          children: [
            // 🚀 THE PREMIUM HEADER WITH CUSTOM PNG LOGO
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Row(
                children: [
                  // --- The Custom PNG Logo ---
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // --- The Typography ---
                  const Text(
                    'Money Log',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      letterSpacing: -1.2,
                    ),
                  ),
                ],
              ),
            ),

            // Map Index: 0=Home, 1=Search, 2=Chart, 3=Profile, 4=Settings
            _buildDrawerItem(icon: Icons.home_filled, title: 'Home', index: 0),
            _buildDrawerItem(icon: Icons.search, title: 'Search', index: 1),
            _buildDrawerItem(
              icon: Icons.pie_chart_outline,
              title: 'Analytics',
              index: 2,
            ),

            const Spacer(),
            const Divider(height: 1, color: Colors.black12),
            const SizedBox(height: 16),

            _buildDrawerItem(
              icon: Icons.person_outline,
              title: 'Profile',
              index: 3,
            ),
            _buildDrawerItem(
              icon: Icons.settings_outlined,
              title: 'Settings',
              index: 4,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required int index,
  }) {
    final isSelected = currentIndex == index;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      leading: Icon(
        icon,
        color: isSelected ? Colors.black : Colors.black54,
        size: 26,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          color: isSelected ? Colors.black : Colors.black87,
        ),
      ),
      onTap: () => onMenuTapped(index),
      tileColor: isSelected
          ? Colors.black.withOpacity(0.05)
          : Colors.transparent,
    );
  }
}
