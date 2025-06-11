import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/footer.dart';
import '../providers/api_provider.dart'; // Import the provider

// Changed to ConsumerWidget
class MyRequestsScreen extends ConsumerWidget {
  final String token;
  final VoidCallback onLogout;
  final VoidCallback onHomeClick;
  final VoidCallback onRequestsClick;
  final VoidCallback onScheduleClick;
  // Changed to accept a String (the user ID)
  final Function(String) onProfileClick;

  const MyRequestsScreen({
    Key? key,
    required this.token,
    required this.onLogout,
    required this.onHomeClick,
    required this.onRequestsClick,
    required this.onScheduleClick,
    required this.onProfileClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the auth repository using ref
    final authRepository = ref.read(authRepositoryProvider);

    final backgroundColor = const Color(0xFF222020);
    final whiteColor = Colors.white;
    final pinkColor = const Color(0xFFE0136C);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "My Requests Screen",
                    style: TextStyle(
                      color: whiteColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: pinkColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Footer(
                footerType: FooterType.hairdresser,
                onHomeClick: onHomeClick,
                onSecondaryClick: onRequestsClick,
                onTertiaryClick: onScheduleClick,
                // THIS IS THE FIX: Get the user ID and pass it to the callback
                onProfileClick: () {
                  final hairdresserId = authRepository.userId;
                  if (hairdresserId != null) {
                    onProfileClick(hairdresserId);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}