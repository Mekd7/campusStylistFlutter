import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../viewmodel/post_detail_viewmodel.dart';
import '../components/footer.dart';

class PostDetailScreen extends StatelessWidget {
  final String token; // Added
  final String serviceName;
  final String description;
  final VoidCallback onHomeClick;
  final VoidCallback onOrdersClick;
  final VoidCallback onProfileClick;
  final VoidCallback onBackClick;

  const PostDetailScreen({
    super.key,
    required this.token, // Added
    required this.serviceName,
    required this.description,
    required this.onHomeClick,
    required this.onOrdersClick,
    required this.onProfileClick,
    required this.onBackClick,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<PostDetailViewModel>(context);
    final post = viewModel.getPostByServiceName(serviceName);

    const darkBackgroundColor = Color(0xFF222020);
    const whiteColor = Colors.white;
    const pinkColor = Color(0xFFE0136C);

    return Scaffold(
      backgroundColor: darkBackgroundColor,
      appBar: AppBar(
        backgroundColor: darkBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: whiteColor),
          onPressed: onBackClick,
        ),
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                child: Text(
                  'Post Details',
                  style: TextStyle(
                    color: whiteColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (post != null)
                CachedNetworkImage(
                  imageUrl: post.imageUrl,
                  height: 300,
                  width: 300,
                  fit: BoxFit.fitHeight,
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  ),
                  placeholder: (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error, color: whiteColor),
                )
              else
                Container(
                  height: 300,
                  width: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[800],
                  ),
                  child: const Center(
                    child: Text(
                      'Post not found',
                      style: TextStyle(color: whiteColor),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  description,
                  style: const TextStyle(
                    color: whiteColor,
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (post != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Length: ${post.length}',
                        style: const TextStyle(
                          color: whiteColor,
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      Text(
                        'Duration: ${post.duration}',
                        style: const TextStyle(
                          color: whiteColor,
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              const Spacer(),
            ],
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