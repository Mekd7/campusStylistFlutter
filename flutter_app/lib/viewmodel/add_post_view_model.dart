import 'package:flutter/foundation.dart';

class AddPostUiState {
  final String description;
  final String? image;

  AddPostUiState({this.description = '', this.image});

  AddPostUiState copyWith({String? description, String? image}) {
    return AddPostUiState(
      description: description ?? this.description,
      image: image ?? this.image,
    );
  }
}

class AddPostViewModel extends ChangeNotifier {
  AddPostUiState _uiState = AddPostUiState();

  AddPostUiState get uiState => _uiState;

  void onDescriptionChanged(String description) {
    _uiState = _uiState.copyWith(description: description);
    notifyListeners();
  }

  void onImageSelected(String? image) {
    _uiState = _uiState.copyWith(image: image);
    notifyListeners();
  }
}