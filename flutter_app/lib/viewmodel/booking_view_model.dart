import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../models/service.dart';

class Order {
  final String? hairdresser;
  final String service;
  final String status;

  Order({this.hairdresser, required this.service, required this.status});
}

class Booking {
  final int clientId;
  final int hairstylistId;
  final String service;
  final double price;
  final String date;
  final String status;
  final String? username;

  Booking({
    required this.clientId,
    required this.hairstylistId,
    required this.service,
    required this.price,
    required this.date,
    required this.status,
    this.username,
  });

  Map<String, dynamic> toJson() => {
    'clientId': clientId,
    'hairstylistId': hairstylistId,
    'service': service,
    'price': price,
    'date': date,
    'status': status,
    'username': username,
  };
}

class BookingViewModel extends ChangeNotifier {
  DateTime? _selectedDate;
  Service? _selectedService;
  final List<Order> _orders = [];
  bool _navigateToOrders = false;
  String? _errorMessage;
  bool _isLoading = false;
  int? _hairstylistId;

  DateTime? get selectedDate => _selectedDate;
  Service? get selectedService => _selectedService;
  List<Order> get orders => _orders;
  bool get navigateToOrders => _navigateToOrders;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  int? get hairstylistId => _hairstylistId;

  void initialize(String token, int? hairstylistId) async {
    _hairstylistId = hairstylistId;
    try {
      final response = await http.get(
        Uri.parse('YOUR_API_URL/user/profile'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final userProfile = jsonDecode(response.body);
        if (hairstylistId == null && userProfile['role'] == 'HAIRDRESSER') {
          _hairstylistId = userProfile['id'];
        }
      } else {
        _errorMessage = response.statusCode == 401
            ? 'Invalid token. Please log in again.'
            : response.statusCode == 404
            ? 'User not found.'
            : 'Failed to load user data: ${response.reasonPhrase}';
      }
    } catch (e) {
      _errorMessage = 'Failed to load user data: $e';
    }
    notifyListeners();
  }

  void onDateSelected(DateTime date) {
    _selectedDate = date;
    checkAvailability(date);
    notifyListeners();
  }

  void onServiceSelected(Service service) {
    _selectedService = service;
    notifyListeners();
  }

  void confirmBooking(String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await http.get(
        Uri.parse('YOUR_API_URL/user/profile'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode != 200) throw Exception('Failed to load user profile');
      final userProfile = jsonDecode(response.body);
      final clientId = userProfile['id'];
      final booking = Booking(
        clientId: clientId,
        hairstylistId: hairstylistId ?? (throw Exception('Hairstylist not selected')),
        service: selectedService?.name ?? '',
        price: double.parse(selectedService?.price.replaceAll(' Birr', '') ?? '0.0'),
        date: DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(selectedDate ?? DateTime.now()),
        status: 'Pending',
        username: null,
      );
      final bookingResponse = await http.post(
        Uri.parse('YOUR_API_URL/bookings'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(booking.toJson()),
      );
      if (bookingResponse.statusCode == 200) {
        final responseData = jsonDecode(bookingResponse.body);
        _orders.add(Order(service: responseData['service'], status: 'Pending'));
        _selectedService = null;
        _selectedDate = null;
        _navigateToOrders = true;
      } else {
        _errorMessage = bookingResponse.statusCode == 400
            ? 'Invalid booking details. Please check your selection.'
            : bookingResponse.statusCode == 401
            ? 'Authentication failed. Please log in again.'
            : bookingResponse.statusCode == 403
            ? 'You are not authorized to make this booking.'
            : 'Failed to confirm booking: ${bookingResponse.reasonPhrase}';
      }
    } catch (e) {
      _errorMessage = 'Failed to confirm booking: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void fetchOrders(String token) async {
    try {
      final response = await http.get(
        Uri.parse('YOUR_API_URL/user/profile'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode != 200) throw Exception('Failed to load user profile');
      final userProfile = jsonDecode(response.body);
      final clientId = userProfile['id'];
      final ordersResponse = await http.get(
        Uri.parse('YOUR_API_URL/bookings/user/$clientId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (ordersResponse.statusCode == 200) {
        final orders = jsonDecode(ordersResponse.body) as List;
        _orders.clear();
        _orders.addAll(orders.map((booking) => Order(
          hairdresser: 'Hairdresser ${booking['hairstylistId']}',
          service: booking['service'],
          status: booking['status'],
        )));
      } else {
        _errorMessage = 'Failed to load orders: ${ordersResponse.reasonPhrase}';
      }
    } catch (e) {
      _errorMessage = 'Failed to load orders: $e';
    }
    notifyListeners();
  }

  void checkAvailability(DateTime date) async {
    if (hairstylistId == null) return;
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final response = await http.get(
        Uri.parse('YOUR_API_URL/bookings/hairstylist/$hairstylistId/date/$dateStr'),
        headers: {},
      );
      if (response.statusCode == 200) {
        final bookings = jsonDecode(response.body) as List;
        if (bookings.isNotEmpty) {
          _errorMessage = 'Hairdresser is fully booked on this date.';
          _selectedDate = null;
        }
      } else {
        _errorMessage = response.statusCode == 400
            ? 'Invalid date or hairstylist ID.'
            : response.statusCode == 401
            ? 'Authentication failed. Please log in again.'
            : 'Failed to check availability: ${response.reasonPhrase}';
      }
    } catch (e) {
      _errorMessage = 'Failed to check availability: $e';
    }
    notifyListeners();
  }

  void clearSelection() {
    _selectedService = null;
    _selectedDate = null;
    _errorMessage = null;
    notifyListeners();
  }

  void onNavigated() {
    _navigateToOrders = false;
    notifyListeners();
  }
}