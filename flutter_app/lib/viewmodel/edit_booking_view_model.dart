import 'package:flutter/foundation.dart';

@immutable
class EditBookingUiState {
  final String date;
  final String time;

  const EditBookingUiState({
    this.date = "2025-07-16",
    this.time = "10:00 AM",
  });

  EditBookingUiState copyWith({
    String? date,
    String? time,
  }) {
    return EditBookingUiState(
      date: date ?? this.date,
      time: time ?? this.time,
    );
  }
}

class EditBookingViewModel extends ChangeNotifier {
  final String token;
  EditBookingUiState _uiState = const EditBookingUiState();

  EditBookingViewModel({required this.token});

  EditBookingUiState get uiState => _uiState;

  void onDateChanged(String date) {
    _uiState = _uiState.copyWith(date: date);
    notifyListeners();
  }

  void onTimeChanged(String time) {
    _uiState = _uiState.copyWith(time: time);
    notifyListeners();
  }

  void saveBooking() {
    print("Saving booking: Token - $token, Date - ${_uiState.date}, Time - ${_uiState.time}");
  }
}