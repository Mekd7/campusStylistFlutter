import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/post.dart';
import '../components/footer.dart';
import 'package:campusstylistflutter/viewmodel/hairdresser_profile_viewmodel.dart';

class HairDresserProfileScreen extends ConsumerStatefulWidget {
  final String token;
  final String hairdresserId;
  final VoidCallback onHomeClick;
  final VoidCallback onOrdersClick;
  final VoidCallback onProfileClick;
  final Function(Post) onPostClick;
  final Function(String) navController;

  const HairDresserProfileScreen({
    super.key,
    required this.token,
    required this.hairdresserId,
    required this.onHomeClick,
    required this.onOrdersClick,
    required this.onProfileClick,
    required this.onPostClick,
    required this.navController,
  });

  @override
  ConsumerState<HairDresserProfileScreen> createState() =>
      _HairDresserProfileScreenState();
}

class _HairDresserProfileScreenState
    extends ConsumerState<HairDresserProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(hairDresserProfileProvider.notifier)
          .fetchProfile(widget.token, widget.hairdresserId);
    });
  }

  // --- THIS ENTIRE BUILD METHOD HAS BEEN REPLACED TO MATCH YOUR DESIGN ---
  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(hairDresserProfileProvider);

    const backgroundColor = Color(0xFF2D2D2D); // A slightly lighter dark grey from your image
    const pinkColor = Color(0xFFE0136C);
    const whiteColor = Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          if (viewModel.isLoading)
            const Center(
              child: CircularProgressIndicator(color: pinkColor),
            )
          else if (viewModel.errorMessage != null)
            Center(
              child: Text(
                viewModel.errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            )
          else
          // Use a CustomScrollView for more complex scrollable layouts
            CustomScrollView(
              slivers: [
                // SliverToBoxAdapter holds regular widgets inside a CustomScrollView
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Profile Header Section ---
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CachedNetworkImage(
                              imageUrl: viewModel.user?.profilePicture ?? 'https://via.placeholder.com/150',
                              imageBuilder: (context, imageProvider) => CircleAvatar(
                                radius: 50,
                                backgroundImage: imageProvider,
                              ),
                              placeholder: (context, url) => const CircleAvatar(radius: 50, child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) => const CircleAvatar(radius: 50, child: Icon(Icons.error)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    viewModel.user?.username ?? 'Hairdresser Name',
                                    style: const TextStyle(
                                      color: whiteColor,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    viewModel.user?.bio ?? 'No bio available.',
                                    style: const TextStyle(
                                      color: whiteColor,
                                      fontSize: 14,
                                      height: 1.4, // Line spacing
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // --- Action Buttons Section ---
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  // Navigate to Edit Profile Screen
                                  widget.navController('editProfile/${widget.token}');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: pinkColor,
                                  foregroundColor: whiteColor,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text('Edit Profile'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  // Navigate to Add Post Screen
                                  widget.navController('addPost/${widget.token}');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: pinkColor,
                                  foregroundColor: whiteColor,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text('Add Post'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // --- Posts Header ---
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Text(
                          'Posts',
                          style: TextStyle(
                            color: whiteColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // --- Post Grid Section ---
                // Use SliverGrid for performance within a CustomScrollView
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // 2 columns to match your design
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final post = viewModel.posts[index];
                        return GestureDetector(
                          onTap: () => widget.onPostClick(post),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // The Image, clipped to have rounded corners
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: CachedNetworkImage(
                                    imageUrl: post.pictureUrl,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(color: Colors.grey[800]),
                                    errorWidget: (context, url, error) => const Icon(Icons.error, color: pinkColor),
                                  ),
                                ),
                              ),
                              // The Description below the image
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                                child: Text(
                                  'Description', // Using a static description as per your design
                                  style: const TextStyle(color: whiteColor, fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      childCount: viewModel.posts.length,
                    ),
                  ),
                ),
                // Add some padding at the very bottom to not be hidden by the footer
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Footer(
              footerType: FooterType.hairdresser,
              onHomeClick: widget.onHomeClick,
              onSecondaryClick: widget.onOrdersClick,
              onTertiaryClick: () => widget.navController('manageSchedule/${widget.token}'),
              onProfileClick: widget.onProfileClick,
            ),
          ),
        ],
      ),
    );
  }
}