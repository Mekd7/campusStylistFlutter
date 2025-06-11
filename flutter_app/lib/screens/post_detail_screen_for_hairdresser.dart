import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/post_detail_view_model.dart';
import '../components/footer.dart';

class PostDetailScreenForHairdressers extends StatelessWidget {
  final String token;
  final String serviceName;

  const PostDetailScreenForHairdressers({
    Key? key,
    required this.token,
    required this.serviceName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Color(0xFF1C2526);
    final pinkColor = Color(0xFFFF4081);
    final whiteColor = Colors.white;

    return ChangeNotifierProvider(
      create: (_) => PostDetailViewModel(),
      child: Consumer<PostDetailViewModel>(
        builder: (context, viewModel, child) {
          final post = viewModel.getPostByServiceName(serviceName);

          return Scaffold(
            body: Stack(
              children: [
                Container(
                  color: backgroundColor,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: Icon(
                                  Icons.arrow_back,
                                  color: whiteColor,
                                ),
                              ),
                            ),
                            Text(
                              'Ashley Gram',
                              style: TextStyle(
                                color: whiteColor,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Image.asset(
                              post?.imagePath ?? 'assets/images/braid.png',
                              width: double.infinity,
                              height: 300,
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              serviceName,
                              style: TextStyle(
                                color: whiteColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '16 inches',
                              style: TextStyle(
                                color: whiteColor,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Took 5 hours',
                              style: TextStyle(
                                color: whiteColor,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pushNamed(
                                      'editPost/$token/$serviceName',
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: pinkColor,
                                    foregroundColor: whiteColor,
                                  ),
                                  child: const Text('Edit Post'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    viewModel.deletePost(serviceName);
                                    Navigator.of(context).pop();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: pinkColor,
                                    foregroundColor: whiteColor,
                                  ),
                                  child: const Text('Delete Post'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Footer(
                    footerType: FooterType.hairdresser,
                    onHomeClick: () {
                      Navigator.of(context).pushNamed('hairdresserHome/$token');
                    },
                    onSecondaryClick: () {
                      Navigator.of(context).pushNamed('requests/$token');
                    },
                    onTertiaryClick: () {
                      Navigator.of(context).pushNamed('manageSchedule/$token');
                    },
                    onProfileClick: () {
                      Navigator.of(context).pushNamed('editProfile/$token');
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}