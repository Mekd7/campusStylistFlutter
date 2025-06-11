import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../viewmodel/client_profile_viewmodel.dart';
import '../components/footer.dart';
import '../providers/client_profile_provider.dart';

class ClientProfileScreen extends ConsumerStatefulWidget {
  final String token;
  final VoidCallback onLogout;
  final VoidCallback onHomeClick;
  final VoidCallback onOrdersClick;
  final VoidCallback onProfileClick;
  final VoidCallback navigateToLogin;
  final VoidCallback onEditProfileClick;

  const ClientProfileScreen({
    super.key,
    required this.token,
    required this.onLogout,
    required this.onHomeClick,
    required this.onOrdersClick,
    required this.onProfileClick,
    required this.navigateToLogin,
    required this.onEditProfileClick,
  });

  @override
  _ClientProfileScreenState createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends ConsumerState<ClientProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(clientProfileProvider.notifier).fetchProfile(widget.token);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(clientProfileProvider);
    final notifier = ref.read(clientProfileProvider.notifier);

    final backgroundColor = const Color(0xFF222020);
    final pinkColor = const Color(0xFFE0136C);
    final whiteColor = Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          state.isLoading
              ? Center(child: CircularProgressIndicator(color: pinkColor))
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  state.username ?? 'Anonymous User',
                  style: TextStyle(
                    color: whiteColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              ClipOval(
                child: CachedNetworkImage(
                  imageUrl: state.profilePicture ??
                      'https://via.placeholder.com/100',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      CircularProgressIndicator(color: whiteColor),
                  errorWidget: (context, url, error) =>
                      Icon(Icons.error, color: whiteColor),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  state.bio ?? 'No bio available',
                  style: TextStyle(
                    color: whiteColor,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: ElevatedButton(
                  onPressed: state.isLoading ? null : () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: pinkColor,
                    foregroundColor: whiteColor,
                    minimumSize: const Size(double.infinity, 48),
                    shape: const StadiumBorder(),
                  ),
                  child: const Text('Delete Account',
                      style: TextStyle(fontSize: 16)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: ElevatedButton(
                  onPressed: state.isLoading ? null : widget.onEditProfileClick,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: pinkColor,
                    foregroundColor: whiteColor,
                    minimumSize: const Size(double.infinity, 48),
                    shape: const StadiumBorder(),
                  ),
                  child: const Text('Edit Profile',
                      style: TextStyle(fontSize: 16)),
                ),
              ),
              ElevatedButton(
                onPressed: state.isLoading
                    ? null
                    : () {
                  print('Logout button pressed, calling notifier.logout');
                  notifier.logout(
                        () {
                      print('onLogout callback executed');
                      widget.onLogout();
                    },
                        () {
                      print('navigateToLogin callback executed');
                      widget.navigateToLogin();
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: pinkColor,
                  foregroundColor: whiteColor,
                  minimumSize: const Size(double.infinity, 48),
                  shape: const StadiumBorder(),
                ),
                child: const Text('Log out', style: TextStyle(fontSize: 16)),
              ),
              if (state.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Error: ${state.errorMessage}',
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
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
                onHomeClick: widget.onHomeClick,
                onSecondaryClick: widget.onOrdersClick,
                onTertiaryClick: widget.onProfileClick,
                onProfileClick: widget.onProfileClick,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
