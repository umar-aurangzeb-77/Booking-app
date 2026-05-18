import 'package:flutter/material.dart';
import '../../models/booking_model.dart';
import '../../models/room_model.dart';
import '../../services/booking_service.dart';
import '../../services/admin_room_service.dart';
import '../../services/local_session_service.dart';
import '../../widgets/student/my_booking_card.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final BookingService _bookingService = BookingService();
  final LocalSessionService _sessionService = LocalSessionService();
  final AdminRoomService _roomService = AdminRoomService();
  
  List<BookingModel> _bookings = [];
  List<RoomModel> _allRooms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    try {
      final student = await _sessionService.getCurrentStudent();
      if (student != null) {
        final bookings = await _bookingService.fetchMyBookings(student.id);
        final all = await _roomService.fetchRooms();
        if (mounted) {
          setState(() {
            _bookings = bookings;
            _allRooms = all;
          });
        }
      }
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
              ? const Center(child: Text('You have not booked any rooms yet.'))
              : RefreshIndicator(
                  onRefresh: _loadBookings,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _bookings.length,
                    itemBuilder: (context, index) {
                      final booking = _bookings[index];
                      final roomName = _allRooms.firstWhere((r) => r.id == booking.roomId, orElse: () => RoomModel(id: '', name: 'Unknown Room', capacity: 0)).name;
                      return MyBookingCard(booking: booking, roomName: roomName);
                    },
                  ),
                ),
    );
  }
}
