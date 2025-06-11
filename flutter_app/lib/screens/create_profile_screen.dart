import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusstylistflutter/viewmodel/create_profile_view_model.dart';
import '../providers/create_profile_provider.dart';

class CreateProfileScreen extends ConsumerWidget {
  final bool isHairdresser;
  final String token;
  final VoidCallback onProfileCreated;

  const CreateProfileScreen({
    super.key,
    required this.isHairdresser,
    required this.token,
    required this.onProfileCreated,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createProfileProvider);
    final notifier = ref.read(createProfileProvider.notifier);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (state.token.isEmpty || state.isHairdresser != isHairdresser) {
        notifier.setInitialData(isHairdresser, token);
      }
    });

    return Scaffold(
      body: Container(
        color: const Color(0xFF222020),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Create Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: () async {
                  try {
                    await notifier.pickImage();
                    if (state.errorMessage != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.errorMessage!)),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to pick image: $e')),
                    );
                  }
                },
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: state.selectedImagePath == null
                      ? const Color(0xFFD9D9D9)
                      : Colors.transparent,
                  backgroundImage: state.selectedImagePath != null
                      ? FileImage(File(state.selectedImagePath!))
                      : null,
                  child: state.selectedImagePath == null
                      ? const Icon(Icons.camera_alt, color: Colors.grey)
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Upload picture',
                style: const TextStyle(
                  color: Color(0xFFE0136C),
                  fontSize: 24,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(height: 48),
              _buildTextField(
                label: 'Your Name',
                value: state.name,
                onChanged: (value) => notifier.updateName(value),
              ),
              const SizedBox(height: 32),
              _buildTextField(
                label: 'Bio',
                value: state.bio,
                onChanged: (value) => notifier.updateBio(value),
                maxLines: 4,
              ),
              if (state.errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  state.errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ],
              const SizedBox(height: 16),
              state.isLoading
                  ? const CircularProgressIndicator(color: Color(0xFFE0136C))
                  : ElevatedButton(
                onPressed: () => notifier.createProfile(onProfileCreated),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE0136C),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: const Text(
                  'Create Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.normal,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: const InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFE0136C)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFE0136C)),
            ),
          ),
          style: const TextStyle(color: Colors.white, fontSize: 18),
          maxLines: maxLines,
          cursorColor: Colors.white,
          onChanged: onChanged,
          controller: TextEditingController(text: value)
            ..selection = TextSelection.fromPosition(
                TextPosition(offset: value.length)),
        ),
      ],
    );
  }
}