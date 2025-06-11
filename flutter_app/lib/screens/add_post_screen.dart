import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/add_post_view_model.dart';
import '../components/footer.dart'; // FooterType is defined here

class AddPostScreen extends StatelessWidget {
  final String token;
  final VoidCallback onBackClick;
  final Function(String) navController;

  const AddPostScreen({
    Key? key,
    required this.token,
    required this.onBackClick,
    required this.navController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final darkBackgroundColor = Color(0xFF222020);
    final whiteColor = Color(0xFFFFFFFF);
    final pinkColor = Color(0xFFE0136C);

    return ChangeNotifierProvider(
      create: (_) => AddPostViewModel(),
      child: Consumer<AddPostViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            body: Stack(
              children: [
                Container(
                  color: darkBackgroundColor,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              'Add New Post',
                              style: TextStyle(
                                color: whiteColor,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              onChanged: (value) => viewModel.onDescriptionChanged(value),
                              style: TextStyle(color: whiteColor),
                              decoration: InputDecoration(
                                labelText: 'Description',
                                labelStyle: TextStyle(color: whiteColor),
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 4,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                // TODO: Implement post saving logic
                                onBackClick(); // Go back after saving
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: pinkColor,
                                foregroundColor: whiteColor,
                                minimumSize: const Size(double.infinity, 48),
                              ),
                              child: const Text(
                                'Save Post',
                                style: TextStyle(fontSize: 16),
                              ),
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
                      footerType: FooterType.hairdresser, // Changed to lowercase
                      onHomeClick: () => navController('hairdresserHome/$token'),
                      onSecondaryClick: () => navController('myRequests/$token'),
                      onTertiaryClick: () => navController('manageSchedule/$token'),
                      onProfileClick: () => navController('hairdresserProfile/$token/$token'),
                    ),
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