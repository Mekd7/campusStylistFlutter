import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/booking_view_model.dart';
import '../components/footer.dart';
import 'package:intl/intl.dart';
import '../models/service.dart';

class BookingScreen extends StatelessWidget {
  final String token;
  final int? hairstylistId;
  final VoidCallback onBookingConfirmed;
  final VoidCallback onHomeClick;
  final VoidCallback onOrdersClick;
  final VoidCallback onProfileClick;

  const BookingScreen({
    Key? key,
    required this.token,
    required this.hairstylistId,
    required this.onBookingConfirmed,
    required this.onHomeClick,
    required this.onOrdersClick,
    required this.onProfileClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Color(0xFF1C2526);
    final pinkColor = Color(0xFFFF4081);
    final whiteColor = Colors.white;
    final blackColor = Colors.black;

    final services = [
      Service('Basic Haircut', '200.0 Birr', 'assets/images/basichaircut.png'),
      Service('Layered Cut', '300.0 Birr', 'assets/images/layeredcut.png'),
      Service('Braids', '500.0 Birr', 'assets/images/braid.png'),
      Service('Cornrows', '600.0 Birr', 'assets/images/cornrows.png'),
      Service('Updo', '400.0 Birr', 'assets/images/updo.png'),
      Service('Hair Coloring', '800.0 Birr', 'assets/images/haircoloring.png'),
      Service('Hair Treatment', '700.0 Birr', 'assets/images/hairtreatment.png'),
      Service('Extensions', '1200.0 Birr', 'assets/images/extensions.png'),
    ];

    return ChangeNotifierProvider(
      create: (_) => BookingViewModel()..initialize(token, hairstylistId),
      child: Consumer<BookingViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.navigateToOrders) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              viewModel.onNavigated();
              onBookingConfirmed();
            });
          }

          return Scaffold(
            body: Stack(
              children: [
                Container(
                  color: backgroundColor,
                  padding: const EdgeInsets.only(top: 16, bottom: 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Book',
                        style: TextStyle(
                          color: whiteColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: CalendarDatePicker(
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(Duration(days: 365)),
                          onDateChanged: (date) => viewModel.onDateSelected(date),
                        ),
                      ),
                      GestureDetector(
                        onTap: viewModel.selectedService != null
                            ? viewModel.clearSelection
                            : null,
                        child: Text(
                          viewModel.selectedService == null
                              ? 'Select a Service'
                              : 'Select a Date',
                          style: TextStyle(
                            color: whiteColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (viewModel.selectedService == null)
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: services.length,
                            itemBuilder: (context, index) {
                              final service = services[index];
                              return GestureDetector(
                                onTap: () => viewModel.onServiceSelected(service),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: whiteColor.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Image.asset(
                                          service.iconPath,
                                          width: 24,
                                          height: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          service.name,
                                          style: TextStyle(
                                            color: whiteColor,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        service.price,
                                        style: TextStyle(
                                          color: whiteColor,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      else
                        const Spacer(),
                      if (viewModel.selectedService != null && viewModel.selectedDate != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: pinkColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Your service: ${viewModel.selectedService!.name}',
                                style: TextStyle(color: whiteColor, fontSize: 16),
                              ),
                              Text(
                                'Date: ${DateFormat('d MMMM, yyyy').format(viewModel.selectedDate!)}',
                                style: TextStyle(color: whiteColor, fontSize: 16),
                              ),
                              Text(
                                'Total price: ${viewModel.selectedService!.price}',
                                style: TextStyle(color: whiteColor, fontSize: 16),
                              ),
                              const SizedBox(height: 16),
                              if (viewModel.isLoading)
                                CircularProgressIndicator(color: whiteColor)
                              else
                                ElevatedButton(
                                  onPressed: () => viewModel.confirmBooking(token),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: blackColor,
                                    foregroundColor: whiteColor,
                                    minimumSize: const Size(double.infinity, 36),
                                  ),
                                  child: const Text(
                                    'Confirm Booking',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),
                      if (viewModel.errorMessage != null)
                        Text(
                          viewModel.errorMessage!,
                          style: const TextStyle(color: Colors.red, fontSize: 16),
                        ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Footer(
                    footerType: FooterType.client,
                    onHomeClick: onHomeClick,
                    onSecondaryClick: onOrdersClick,
                    onTertiaryClick: onProfileClick,
                    onProfileClick: onProfileClick,
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