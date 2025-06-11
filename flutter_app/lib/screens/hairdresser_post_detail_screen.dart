import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HairDresserPostDetailScreen extends StatelessWidget {
  final String token;
  final String hairdresserId;
  final int postId;
  final String pictureUrl;
  final String description;
  final VoidCallback onHomeClick;
  final VoidCallback onOrdersClick;
  final VoidCallback onProfileClick;
  final VoidCallback onBackClick;

  const HairDresserPostDetailScreen({
    super.key,
    required this.token,
    required this.hairdresserId,
    required this.postId,
    required this.pictureUrl,
    required this.description,
    required this.onHomeClick,
    required this.onOrdersClick,
    required this.onProfileClick,
    required this.onBackClick,
  });

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF1C2526);
    const pinkColor = Color(0xFFFF4081);
    const whiteColor = Colors.white;
    const blackColor = Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: onBackClick,
                    icon: const Icon(
                      Icons.arrow_back,
                      color: whiteColor,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
                child: Text(
                  'Hairdresser ID: $hairdresserId',
                  style: const TextStyle(
                    color: whiteColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              CachedNetworkImage(
                imageUrl: pictureUrl,
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Description:',
                      style: TextStyle(
                        color: whiteColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: const TextStyle(
                        color: whiteColor,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Footer(
              onHomeClick: onHomeClick,
              onOrdersClick: onOrdersClick,
              onProfileClick: onProfileClick,
            ),
          ),
        ],
      ),
    );
  }
}

class Footer extends StatelessWidget {
  final VoidCallback onHomeClick;
  final VoidCallback onOrdersClick;
  final VoidCallback onProfileClick;

  const Footer({
    super.key,
    required this.onHomeClick,
    required this.onOrdersClick,
    required this.onProfileClick,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[900],
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            onPressed: onHomeClick,
            icon: const Icon(Icons.home, color: Colors.white),
          ),
          IconButton(
            onPressed: onOrdersClick,
            icon: const Icon(Icons.list_alt, color: Colors.white),
          ),
          IconButton(
            onPressed: onProfileClick,
            icon: const Icon(Icons.person, color: Colors.white),
          ),
        ],
      ),
    );
  }
}