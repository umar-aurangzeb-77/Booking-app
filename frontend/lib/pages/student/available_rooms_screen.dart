import 'package:flutter/material.dart';
import '../../services/booking_service.dart';
import '../../models/room_model.dart';
import '../../widgets/student/available_room_card.dart';

class AvailableRoomsScreen extends StatefulWidget {
  const AvailableRoomsScreen({super.key});

  @override
  State<AvailableRoomsScreen> createState() => _AvailableRoomsScreenState();
}

class _AvailableRoomsScreenState extends State<AvailableRoomsScreen> {
  final BookingService _bookingService = BookingService();
  List<RoomModel> _rooms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    setState(() => _isLoading = true);
    try {
      final today = DateTime.now();
      final rooms = await _bookingService.fetchAvailableRooms(today);
      if (mounted) {
        setState(() {
          _rooms = rooms;
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
        title: const Text('Available Rooms'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _rooms.isEmpty
              ? const Center(child: Text('No rooms available right now.'))
              : RefreshIndicator(
                  onRefresh: _loadRooms,
                  child: ListView.builder(
                    itemCount: _rooms.length,
                    itemBuilder: (context, index) {
                      return AvailableRoomCard(
                        room: _rooms[index],
                        onTap: () async {
                          await Navigator.pushNamed(context, '/room-booking', arguments: _rooms[index]);
                          _loadRooms();
                        },
                      );
                    },
                  ),
                ),
    );
  }
}
