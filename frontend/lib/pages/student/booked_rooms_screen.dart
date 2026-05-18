import 'package:flutter/material.dart';
import '../../models/booking_model.dart';
import '../../models/room_model.dart';
import '../../services/booking_service.dart';
import '../../services/admin_room_service.dart';
import '../../widgets/student/booked_room_card.dart';

class BookedRoomsScreen extends StatefulWidget {
  const BookedRoomsScreen({super.key});

  @override
  State<BookedRoomsScreen> createState() => _BookedRoomsScreenState();
}

class _BookedRoomsScreenState extends State<BookedRoomsScreen> {
  final BookingService _bookingService = BookingService();
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
      final today = DateTime.now();
      final bookings = await _bookingService.fetchBookedRooms(today);
      final all = await _roomService.fetchRooms();
      if (mounted) {
        setState(() {
          _bookings = bookings;
          _allRooms = all;
        });
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
        title: const Text('Booked Rooms'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
              ? const Center(child: Text('No rooms are currently booked.'))
              : RefreshIndicator(
                  onRefresh: _loadBookings,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _bookings.length,
                    itemBuilder: (context, index) {
                      final booking = _bookings[index];
                      final roomName = _allRooms.firstWhere((r) => r.id == booking.roomId, orElse: () => RoomModel(id: '', name: 'Unknown Room', capacity: 0)).name;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: BookedRoomCard(booking: booking, roomName: roomName),
                      );
                    },
                  ),
                ),
    );
  }
}
