import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import '../providers/booking_provider.dart';
import '../models/booking_model.dart';
import 'package:intl/intl.dart';

class ReservationsPage extends StatefulWidget {
  const ReservationsPage({super.key});

  @override
  State<ReservationsPage> createState() => _ReservationsPageState();
}

class _ReservationsPageState extends State<ReservationsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().loadUserBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('My Bookings', style: AppTextStyles.heading2),
          backgroundColor: Colors.transparent,
          elevation: 0,
          bottom: TabBar(
            indicatorColor: Theme.of(context).primaryColor,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: AppColors.secondaryText,
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'Past'),
            ],
          ),
        ),
        body: bookingProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildBookingList(bookingProvider.upcomingBookings),
                  _buildBookingList(bookingProvider.pastBookings),
                ],
              ),
      ),
    );
  }

  Widget _buildBookingList(List<BookingModel> bookings) {
    if (bookings.isEmpty) {
      return const Center(child: Text('No bookings found.'));
    }

    return RefreshIndicator(
      onRefresh: () => context.read<BookingProvider>().loadUserBookings(),
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.medium),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          final isUpcoming = booking.status == 'Active';
          
          return Card(
            margin: const EdgeInsets.only(bottom: AppSpacing.medium),
            elevation: 2,
            shadowColor: Colors.black12,
            child: ListTile(
              contentPadding: const EdgeInsets.all(AppSpacing.medium),
              title: Text('Room ID: ${booking.roomId}', style: AppTextStyles.bodyBold),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM dd, yyyy • hh:mm a').format(booking.bookingDate),
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isUpcoming ? Theme.of(context).colorScheme.secondary.withOpacity(0.1) : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      booking.status,
                      style: AppTextStyles.caption.copyWith(
                        color: isUpcoming ? Theme.of(context).primaryColor : Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              trailing: isUpcoming 
                  ? IconButton(
                      icon: const Icon(Icons.cancel_outlined, color: AppColors.error),
                      onPressed: () {
                        context.read<BookingProvider>().cancelBooking(booking.id);
                      },
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}
