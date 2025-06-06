import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/client_home_view_model.dart';
import '../models/post.dart';
import '../components/footer.dart';

class ClientHomeScreen extends StatelessWidget {
  final String token;
  final VoidCallback onLogout;
  final VoidCallback onHomeClick;
  final VoidCallback onOrdersClick;
  final VoidCallback onProfileClick;
  final Function(String) onHairdresserProfileClick;

  const ClientHomeScreen({
    Key? key,
    required this.token,
    required this.onLogout,
    required this.onHomeClick,
    required this.onOrdersClick,
    required this.onProfileClick,
    required this.onHairdresserProfileClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ClientHomeViewModel>(context);
    final backgroundColor = Color(0xFF1C2526);
    final pinkColor = Color(0xFFFF4081);
    final whiteColor = Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // Header with title
          Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: pinkColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Home',
              style: TextStyle(
                color: whiteColor,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: viewModel.posts.length,
              itemBuilder: (context, index) {
                final post = viewModel.posts[index];
                return Card(
                  color: Color(0xFF2A3435),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  margin: EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => onHairdresserProfileClick(post.hairdresserId),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  post.imagePath,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey,
                                    child: Icon(Icons.error, color: Colors.white),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post.hairdresserName,
                                    style: TextStyle(
                                      color: whiteColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  GestureDetector(
                                    onTap: () => onHairdresserProfileClick(post.hairdresserId),
                                    child: Text(
                                      'View Profile',
                                      style: TextStyle(
                                        color: pinkColor,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => onHairdresserProfileClick(post.hairdresserId),
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: pinkColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.person,
                                color: pinkColor,
                                size: 32,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Footer(
            footerType: FooterType.CLIENT,
            onHomeClick: onHomeClick,
            onSecondaryClick: onOrdersClick,
            onTertiaryClick: onProfileClick,
            onProfileClick: onProfileClick, // Same as onTertiaryClick for CLIENT
          ),
        ],
      ),
    );
  }
}