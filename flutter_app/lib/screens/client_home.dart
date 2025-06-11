import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/post.dart';
import '../components/footer.dart';
import '../providers/client_home_provider.dart';

class ClientHomeScreen extends ConsumerWidget {
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

  // --- THIS ENTIRE BUILD METHOD HAS BEEN REPLACED ---
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(clientHomeProvider);
    const backgroundColor = Color(0xFF2D2D2D);
    const pinkColor = Color(0xFFE0136C);
    const whiteColor = Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 40, 16, 16),
            child: Text(
              'CampusStylist!',
              style: TextStyle(
                color: whiteColor,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: viewModel.posts.isEmpty
                ? const Center(child: CircularProgressIndicator(color: pinkColor))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: viewModel.posts.length,
              itemBuilder: (context, index) {
                final post = viewModel.posts[index];
                final hairdresserName = viewModel.userNames[post.userId.toString()] ?? 'Stylist Name';
                return _PostCard(
                  post: post,
                  stylistName: hairdresserName,
                  onVisitProfile: () => onHairdresserProfileClick(post.userId.toString()),
                );
              },
            ),
          ),
          Footer(
            footerType: FooterType.client,
            onHomeClick: onHomeClick,
            onSecondaryClick: onOrdersClick,
            onTertiaryClick: onProfileClick,
            onProfileClick: onProfileClick,
          ),
        ],
      ),
    );
  }
}

// --- THIS IS THE NEW REUSABLE WIDGET FOR THE POST CARD ---
class _PostCard extends StatelessWidget {
  final Post post;
  final String stylistName;
  final VoidCallback onVisitProfile;

  const _PostCard({
    required this.post,
    required this.stylistName,
    required this.onVisitProfile,
  });

  @override
  Widget build(BuildContext context) {
    const pinkColor = Color(0xFFE0136C);

    return Card(
      color: const Color(0xFF3F3F3F),
      margin: const EdgeInsets.only(bottom: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias, // Ensures content respects the rounded corners
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 16,
                  child: Icon(Icons.person_outline, color: Colors.black),
                ),
                const SizedBox(width: 12),
                Text(
                  stylistName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          CachedNetworkImage(
            imageUrl: post.pictureUrl,
            fit: BoxFit.cover,
            height: 300,
            placeholder: (context, url) => Container(height: 300, color: Colors.grey[800]),
            errorWidget: (context, url, error) => const Icon(Icons.error, color: pinkColor, size: 50),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: onVisitProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: pinkColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('Visit Profile', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}