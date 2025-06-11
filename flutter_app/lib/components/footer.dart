import 'package:flutter/material.dart';

enum FooterType { client, hairdresser }

class Footer extends StatelessWidget {
  final FooterType footerType;
  final VoidCallback onHomeClick;
  final VoidCallback onSecondaryClick; // Orders for CLIENT, Requests for HAIRDRESSER
  final VoidCallback onTertiaryClick; // Profile for CLIENT, Schedule for HAIRDRESSER
  final VoidCallback onProfileClick; // Only for HAIRDRESSER

  const Footer({
    Key? key,
    required this.footerType,
    required this.onHomeClick,
    required this.onSecondaryClick,
    required this.onTertiaryClick,
    required this.onProfileClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pinkColor = Color(0xFFE0136C);

    return Container(
      decoration: BoxDecoration(
        color: pinkColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Home Icon
          IconButton(
            icon: Icon(Icons.home, color: Colors.white, size: 24),
            onPressed: onHomeClick,
            tooltip: 'Home',
          ),
          // Conditional icons based on FooterType
          if (footerType == FooterType.client) ...[
            // Orders Icon
            IconButton(
              icon: Icon(Icons.list_alt, color: Colors.white, size: 24),
              onPressed: onSecondaryClick,
              tooltip: 'Orders',
            ),
            // Profile Icon
            IconButton(
              icon: Icon(Icons.person, color: Colors.white, size: 24),
              onPressed: onTertiaryClick,
              tooltip: 'Profile',
            ),
          ] else ...[
            // Requests Icon
            IconButton(
              icon: Icon(Icons.request_page, color: Colors.white, size: 24),
              onPressed: onSecondaryClick,
              tooltip: 'Requests',
            ),
            // Schedule Icon
            IconButton(
              icon: Icon(Icons.schedule, color: Colors.white, size: 24),
              onPressed: onTertiaryClick,
              tooltip: 'Manage Schedule',
            ),
            // Profile Icon
            IconButton(
              icon: Icon(Icons.person, color: Colors.white, size: 24),
              onPressed: onProfileClick,
              tooltip: 'Profile',
            ),
          ],
        ],
      ),
    );
  }
}
