import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:campusstylistflutter/viewmodel/edit_post_view_model.dart';

class EditPostScreen extends StatefulWidget {
  const EditPostScreen({super.key});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  // It's best practice to use a TextEditingController for text fields
  // to maintain cursor position and performance.
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    // Initialize the controller with the starting value from the ViewModel.
    // We use context.read here because we only need the initial value
    // and don't need to listen for changes inside initState.
    final initialDescription = context.read<EditPostViewModel>().uiState.description;
    _descriptionController = TextEditingController(text: initialDescription);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The Consumer widget will rebuild its children whenever the ViewModel calls notifyListeners().
    return Consumer<EditPostViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Edit Post"),
          ),
          body: Padding(
            // Modifier.padding(16.dp) becomes a Padding widget.
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Text is very similar.
                const Text(
                  "Edit Your Post",
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                // Spacer becomes a SizedBox.
                const SizedBox(height: 16.0),
                // OutlinedTextField becomes TextFormField.
                TextFormField(
                  controller: _descriptionController,
                  onChanged: viewModel.onDescriptionChanged,
                  decoration: const InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5, // Allow for multi-line descriptions
                ),
                const SizedBox(height: 16.0),

                // This section shows the selected image state and a button to change it
                OutlinedButton.icon(
                  icon: const Icon(Icons.image),
                  label: const Text("Select Image"),
                  onPressed: () {
                    // In a real app, this would open an image picker.
                    // Here, we just simulate selecting a new image file.
                    viewModel.onImageSelected("path/to/new_image.jpg");
                  },
                ),
                if (viewModel.uiState.image != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text("Selected image: ${viewModel.uiState.image}"),
                  ),
                
                // Spacer to push buttons to the bottom
                const Spacer(),

                // Row is the same as in Compose.
                Row(
                  // Arrangement.SpaceEvenly -> MainAxisAlignment.spaceEvenly
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Button -> OutlinedButton
                    OutlinedButton(
                      onPressed: () {
                        // onBackClick & navController.popBackStack() -> Navigator.pop()
                        Navigator.of(context).pop();
                      },
                      child: const Text("Back"),
                    ),
                    // Button -> ElevatedButton
                    ElevatedButton(
                      onPressed: () {
                        // Call the save logic in the view model
                        viewModel.savePost();
                        // Then navigate back
                        Navigator.of(context).pop();
                      },
                      child: const Text("Save"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// This is a helper widget to provide the ViewModel for the screen.
class EditPostScreenProvider extends StatelessWidget {
  const EditPostScreenProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EditPostViewModel(),
      child: const EditPostScreen(),
    );
  }
}