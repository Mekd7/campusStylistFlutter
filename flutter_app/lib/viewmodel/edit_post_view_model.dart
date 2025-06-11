import 'package:flutter/foundation.dart';

// This is the equivalent of your 'data class EditPostUiState'.
// The 'image' property is nullable, just like in Kotlin (String?).
@immutable
class EditPostUiState {
  final String description;
  final String? image;

  const EditPostUiState({
    this.description = "Existing post description", // Example default
    this.image,
  });

  // The 'copyWith' method lets us create a new state instance
  // by modifying only the properties we need.
  EditPostUiState copyWith({
    String? description,
    String? image,
  }) {
    return EditPostUiState(
      description: description ?? this.description,
      image: image ?? this.image,
    );
  }
}

// This is the equivalent of your 'EditPostViewModel'.
class EditPostViewModel extends ChangeNotifier {
  // Private state
  EditPostUiState _uiState = const EditPostUiState();

  // Public getter for the UI to read the state
  EditPostUiState get uiState => _uiState;

  // Equivalent to 'onDescriptionChanged'
  void onDescriptionChanged(String description) {
    _uiState = _uiState.copyWith(description: description);
    notifyListeners(); // Tell the UI to rebuild
  }

  // Equivalent to 'onImageSelected'.
  // We can pass null here to clear the image.
  void onImageSelected(String? image) {
    _uiState = _uiState.copyWith(image: image);
    notifyListeners();
  }

  // A function to be called when the user presses 'Save'.
  void savePost() {
    // Add your logic here to save the post to a database or API.
    print("Saving post: Description - ${_uiState.description}");
    if (_uiState.image != null) {
      print("With image: ${_uiState.image}");
    }
  }
}