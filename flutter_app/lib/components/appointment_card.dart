import 'package:flutter/material.dart';
import '../screens/manage_schedule_screen.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;

  const AppointmentCard({Key? key, required this.appointment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final whiteColor = Colors.white;
    final pinkColor = const Color(0xFFFF4081);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: const Color(0xFF2A3435),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appointment.time,
              style: TextStyle(
                color: pinkColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Client: ${appointment.client}",
              style: TextStyle(color: whiteColor, fontSize: 16),
            ),
            Text(
              "Service: ${appointment.service}",
              style: TextStyle(color: whiteColor, fontSize: 16),
            ),
            Text(
              "Status: ${appointment.status}",
              style: TextStyle(color: whiteColor, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}