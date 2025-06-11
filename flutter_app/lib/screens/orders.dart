// File: lib/screens/orders.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/footer.dart';
import '../viewmodel/booking_view_model.dart';

class OrderScreen extends StatelessWidget {
  final String token;
  final VoidCallback onBackClick;
  final VoidCallback onHomeClick;
  final VoidCallback onOrdersClick;
  final VoidCallback onProfileClick;

  const OrderScreen({
    Key? key,
    required this.token,
    required this.onBackClick,
    required this.onHomeClick,
    required this.onOrdersClick,
    required this.onProfileClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Color(0xFF1C2526); // Match BookingScreen
    final pinkColor = Color(0xFFFF4081); // Match BookingScreen
    final whiteColor = Colors.white;

    return ChangeNotifierProvider(
      create: (_) => BookingViewModel()..fetchOrders(token), // Use existing BookingViewModel
      child: Consumer<BookingViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            body: Stack(
              children: [
                Container(
                  color: backgroundColor,
                  padding: const EdgeInsets.only(top: 16, bottom: 80), // Space for footer
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Header
                      Text(
                        'My Orders',
                        style: TextStyle(
                          color: whiteColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      // Orders List
                      Expanded(
                        child: viewModel.isLoading
                            ? Center(child: CircularProgressIndicator(color: pinkColor))
                            : viewModel.orders.isEmpty
                            ? Center(
                          child: Text(
                            'No orders found',
                            style: TextStyle(color: whiteColor, fontSize: 16),
                          ),
                        )
                            : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: viewModel.orders.length,
                          itemBuilder: (context, index) {
                            final order = viewModel.orders[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Card(
                                color: const Color(0xFF2A3435), // Consistent with HairdresserHomeScreen
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Service: ${order.service}',
                                        style: TextStyle(
                                          color: whiteColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Hairdresser: ${order.hairdresser ?? 'Unknown'}',
                                        style: TextStyle(color: whiteColor, fontSize: 14),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Status: ${order.status}',
                                        style: TextStyle(color: whiteColor, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      if (viewModel.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            viewModel.errorMessage!,
                            style: const TextStyle(color: Colors.red, fontSize: 16),
                          ),
                        ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: pinkColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Footer(
                      footerType: FooterType.client,
                      onHomeClick: onHomeClick,
                      onSecondaryClick: onOrdersClick,
                      onTertiaryClick: onProfileClick,
                      onProfileClick: onProfileClick,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}