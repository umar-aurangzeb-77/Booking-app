import 'package:flutter/material.dart';
import '../../models/room_model.dart';
import '../../services/booking_service.dart';
import '../../services/local_session_service.dart';
import 'package:intl/intl.dart';

class RoomBookingScreen extends StatefulWidget {
  const RoomBookingScreen({super.key});

  @override
  State<RoomBookingScreen> createState() => _RoomBookingScreenState();
}

class _RoomBookingScreenState extends State<RoomBookingScreen> {
  final BookingService _bookingService = BookingService();
  final LocalSessionService _sessionService = LocalSessionService();
  
  DateTime? _selectedDate;
  bool _isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), // Prevent past bookings
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _confirmBooking(RoomModel room) async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date for booking')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final student = await _sessionService.getCurrentStudent();
      if (student == null) {
        throw Exception('User session expired. Please login again.');
      }

      await _bookingService.bookRoom(
        room: room,
        student: student,
        bookingDate: _selectedDate!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Room booked successfully!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final RoomModel room = ModalRoute.of(context)!.settings.arguments as RoomModel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Room'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Icon(Icons.meeting_room, size: 40, color: Theme.of(context).primaryColor),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              room.name,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.people, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  'Capacity: ${room.capacity} seats',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Facilities',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (room.facilities.isEmpty)
              const Text('No facilities assigned.', style: TextStyle(color: Colors.grey))
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: room.facilities.map((f) {
                  IconData icon = Icons.check_circle_outline;
                  if (f.contains('WiFi') || f.contains('Internet')) icon = Icons.wifi;
                  if (f.contains('AC') || f.contains('Cooling')) icon = Icons.ac_unit;
                  if (f.contains('Smart')) icon = Icons.developer_board;

                  return Chip(
                    avatar: Icon(icon, size: 18),
                    label: Text(f),
                  );
                }).toList(),
              ),
            const SizedBox(height: 32),
            const Text(
              'Select Date',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDate == null
                          ? 'Tap to select a date'
                          : DateFormat('EEEE, MMM dd, yyyy').format(_selectedDate!),
                      style: TextStyle(
                        fontSize: 16,
                        color: _selectedDate == null ? Colors.grey.shade600 : Colors.black87,
                      ),
                    ),
                    Icon(Icons.calendar_month, color: Theme.of(context).primaryColor),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => _confirmBooking(room),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'CONFIRM BOOKING',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
