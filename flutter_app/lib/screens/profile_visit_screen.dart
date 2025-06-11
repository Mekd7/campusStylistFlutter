// File: lib/ui/screens/profile_visit_screen.dart
import 'package:flutter/material.dart';
import '../components/footer.dart';
import 'profile_post_item.dart';

class ProfileVisitScreen extends StatelessWidget {
  final String token;
  final VoidCallback onHomeClick;
  final VoidCallback onOrdersClick;
  final VoidCallback onProfileClick;
  final VoidCallback onBookClick;
  final Function(String) navController;

  const ProfileVisitScreen({
    Key? key,
    required this.token,
    required this.onHomeClick,
    required this.onOrdersClick,
    required this.onProfileClick,
    required this.onBookClick,
    required this.navController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final darkBackgroundColor = Color(0xFF222020);
    final whiteColor = Color(0xFFFFFFFF);
    final pinkColor = Color(0xFFE0136C);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: darkBackgroundColor,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Profile Header
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Profile Image
                      ClipOval(
                        child: Image.asset(
                          'assets/images/hair_style.png',
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Profile Name
                      Text(
                        'Ashley Gram',
                        style: TextStyle(
                          color: whiteColor,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Profile Bio
                      Text(
                        'Hair is my passion\n\nLocated At AAiT, dorm room 306\n\nBook Now !!!',
                        style: TextStyle(
                          color: whiteColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          height: 1.25,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      // Book Button
                      ElevatedButton(
                        onPressed: onBookClick,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: pinkColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          minimumSize: Size(
                            MediaQuery.of(context).size.width * 0.8,
                            50,
                          ),
                        ),
                        child: Text(
                          'Book',
                          style: TextStyle(
                            color: whiteColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Posts Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Posts Title
                        Padding(
                          padding: const EdgeInsets.only(left: 8, bottom: 16),
                          child: Text(
                            'Posts',
                            style: TextStyle(
                              color: whiteColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        // Grid for Posts
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ProfilePostItem(
                              imagePath: 'assets/images/hair_style.png',
                              description: 'Description',
                            ),
                            ProfilePostItem(
                              imagePath: 'assets/images/hair_style.png',
                              description: 'Description',
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ProfilePostItem(
                              imagePath: 'assets/images/hair_style.png',
                              description: 'Description',
                            ),
                            ProfilePostItem(
                              imagePath: 'assets/images/hair_style.png',
                              description: 'Description',
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ProfilePostItem(
                              imagePath: 'assets/images/hair_style.png',
                              description: 'Description',
                            ),
                            ProfilePostItem(
                              imagePath: 'assets/images/hair_style.png',
                              description: 'Description',
                            ),
                          ],
                        ),
                        const SizedBox(height: 80), // Space for footer
                      ],
                    ),
                  ),
                ],
              ),
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
                footerType: FooterType.client,
                onHomeClick: onHomeClick,
                onSecondaryClick: onOrdersClick,
                onTertiaryClick: onProfileClick,
                onProfileClick: onProfileClick,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


