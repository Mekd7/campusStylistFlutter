import 'package:flutter/foundation.dart';

class AddBookingUiState {
  final String date;
  final String time;

  AddBookingUiState({this.date = '', this.time = ''});

  AddBookingUiState copyWith({String? date, String? time}) {
    return AddBookingUiState(
      date: date ?? this.date,
      time: time ?? this.time,
    );
  }
}

class AddBookingViewModel extends ChangeNotifier {
  AddBookingUiState _uiState = AddBookingUiState();

  AddBookingUiState get uiState => _uiState;

  void onDateChanged(String date) {
    _uiState = _uiState.copyWith(date: date);
    notifyListeners();
  }

  void onTimeChanged(String time) {
    _uiState = _uiState.copyWith(time: time);
    notifyListeners();
  }
}