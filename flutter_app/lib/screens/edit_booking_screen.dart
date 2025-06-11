import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/edit_booking_view_model.dart';

class EditBookingScreen extends StatelessWidget {
  final String token;
  final Function(String)? navController;
  final VoidCallback onBackClick;

  const EditBookingScreen({
    super.key,
    required this.token,
    this.navController,
    required this.onBackClick,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => EditBookingViewModel(token: token),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Edit Booking"),
        ),
        body: Consumer<EditBookingViewModel>(
          builder: (context, viewModel, child) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Edit Booking Details",
                    style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    initialValue: viewModel.uiState.date,
                    onChanged: viewModel.onDateChanged,
                    decoration: const InputDecoration(
                      labelText: "Date",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    initialValue: viewModel.uiState.time,
                    onChanged: viewModel.onTimeChanged,
                    decoration: const InputDecoration(
                      labelText: "Time",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton(
                        onPressed: onBackClick,
                        child: const Text("Back"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          viewModel.saveBooking();
                          if (navController != null) {
                            navController!('/manageSchedule/$token');
                          } else {
                            Navigator.of(context).pop();
                          }
                        },
                        child: const Text("Save"),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}