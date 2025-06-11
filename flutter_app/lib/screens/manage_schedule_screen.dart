import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../components/appointment_card.dart';
import '../components/footer.dart';
import '../providers/api_provider.dart'; // Import the provider

class Appointment {
  final String time;
  final String client;
  final String service;
  final String status;

  Appointment({
    required this.time,
    required this.client,
    required this.service,
    this.status = "APPROVED",
  });
}

// Changed to ConsumerStatefulWidget
class ManageScheduleScreen extends ConsumerStatefulWidget {
  final String token;
  final VoidCallback onLogout;
  final VoidCallback onHomeClick;
  final VoidCallback onRequestsClick;
  final VoidCallback onScheduleClick;
  // Changed to accept a String (the user ID)
  final Function(String) onProfileClick;
  final Function(String) navController;

  const ManageScheduleScreen({
    Key? key,
    required this.token,
    required this.onLogout,
    required this.onHomeClick,
    required this.onRequestsClick,
    required this.onScheduleClick,
    required this.onProfileClick,
    required this.navController,
  }) : super(key: key);

  @override
  _ManageScheduleScreenState createState() => _ManageScheduleScreenState();
}

// Changed to ConsumerState
class _ManageScheduleScreenState extends ConsumerState<ManageScheduleScreen> {
  late DateTime _selectedDate;
  final List<Appointment> _appointments = [
    Appointment(time: "10:00 AM", client: "John Doe", service: "Haircut"),
    Appointment(time: "11:00 AM", client: "Jane Smith", service: "Coloring"),
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  void _onDateSelected(DateTime date, DateTime focusedDate) {
    setState(() {
      _selectedDate = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the auth repository using ref
    final authRepository = ref.read(authRepositoryProvider);

    final backgroundColor = const Color(0xFF1C2526);
    final pinkColor = const Color(0xFFFF4081);
    final whiteColor = Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          const SizedBox(height: 16),
          Text(
            "Manage Schedule",
            style: TextStyle(
              color: whiteColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _selectedDate,
            calendarFormat: CalendarFormat.month,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
            onDaySelected: _onDateSelected,
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: pinkColor.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: pinkColor,
                shape: BoxShape.circle,
              ),
              weekendTextStyle: TextStyle(color: whiteColor),
              defaultTextStyle: TextStyle(color: whiteColor),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleTextStyle: TextStyle(color: whiteColor, fontSize: 18),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(color: whiteColor),
              weekendStyle: TextStyle(color: whiteColor),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => widget.navController('addBooking/${widget.token}'),
                style: ElevatedButton.styleFrom(backgroundColor: pinkColor),
                child: const Text("Add Booking", style: TextStyle(color: Colors.white)),
              ),
              ElevatedButton(
                onPressed: () => widget.navController('editBooking/${widget.token}'),
                style: ElevatedButton.styleFrom(backgroundColor: pinkColor),
                child: const Text("Edit Schedule", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "Appointments on ${DateFormat('d MMMM, yyyy').format(_selectedDate)}",
            style: TextStyle(
              color: whiteColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _appointments.length,
              itemBuilder: (context, index) => AppointmentCard(appointment: _appointments[index]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Footer(
        footerType: FooterType.hairdresser,
        onHomeClick: widget.onHomeClick,
        onSecondaryClick: widget.onRequestsClick,
        onTertiaryClick: widget.onScheduleClick,
        // THIS IS THE FIX: Get the user ID and pass it to the callback
        onProfileClick: () {
          final hairdresserId = authRepository.userId;
          if (hairdresserId != null) {
            widget.onProfileClick(hairdresserId);
          }
        },
      ),
    );
  }
}