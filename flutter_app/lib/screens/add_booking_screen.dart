// File: lib/ui/screens/add_booking_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/add_booking_view_model.dart';

class AddBookingScreen extends StatelessWidget {
  final Function(String) navController;
  final VoidCallback onBackClick;

  const AddBookingScreen({
    Key? key,
    required this.navController,
    required this.onBackClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddBookingViewModel(),
      child: Consumer<AddBookingViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'Add Booking',
                    style: TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    onChanged: (value) => viewModel.onDateChanged(value),
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    onChanged: (value) => viewModel.onTimeChanged(value),
                    decoration: const InputDecoration(
                      labelText: 'Time',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: onBackClick,
                        child: const Text('Back'),
                      ),
                      ElevatedButton(
                        onPressed: () => navController('popBackStack'),
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}