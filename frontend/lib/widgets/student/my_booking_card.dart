import 'package:flutter/material.dart';
import '../../models/booking_model.dart';
import 'package:intl/intl.dart';

class MyBookingCard extends StatelessWidget {
  final BookingModel booking;
  final String roomName;

  const MyBookingCard({
    super.key, 
    required this.booking,
    required this.roomName,
  });

  @override
  Widget build(BuildContext context) {
    // Check if expired
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isExpired = booking.bookingDate.isBefore(today);

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isExpired ? Colors.grey.shade100 : Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.event_seat,
                color: isExpired ? Colors.grey : Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    roomName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    booking.seatId != null ? 'Seat: ${booking.seatId!.replaceAll('Seat ', '')}' : 'Room Booking',
                    style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey.shade800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('EEEE, MMM dd, yyyy').format(booking.bookingDate),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                  if (booking.bookedById != null && booking.bookedById != booking.studentRecordId) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: Text(
                        'Booked for you by ${booking.bookedByName}',
                        style: TextStyle(fontSize: 11, color: Colors.blue.shade700, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isExpired ? Colors.grey.shade200 : Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isExpired ? 'Expired' : 'Active',
                style: TextStyle(
                  color: isExpired ? Colors.grey.shade700 : Theme.of(context).primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
