import 'package:flutter/material.dart';
import '../../models/room_model.dart';
import '../../services/booking_service.dart';
import '../../services/admin_room_service.dart';
import 'package:intl/intl.dart';

class RoomDetailsScreen extends StatefulWidget {
  const RoomDetailsScreen({super.key});

  @override
  State<RoomDetailsScreen> createState() => _RoomDetailsScreenState();
}

class _RoomDetailsScreenState extends State<RoomDetailsScreen> {
  final BookingService _bookingService = BookingService();
  final AdminRoomService _adminRoomService = AdminRoomService();
  bool _isBooked = false;
  bool _isLoadingStatus = true;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    // We'll fetch the status after the first frame to get arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStatus();
    });
  }

  Future<void> _loadStatus() async {
    final RoomModel room = ModalRoute.of(context)!.settings.arguments as RoomModel;
    try {
      final bookedSeats = await _bookingService.fetchBookedSeats(room.id, DateTime.now());
      final totalSeats = room.seatmap?.length ?? room.capacity;
      final status = bookedSeats.length >= totalSeats && totalSeats > 0;
      
      if (mounted) {
        setState(() {
          _isBooked = status;
          _isLoadingStatus = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingStatus = false);
      }
    }
  }

  Future<void> _deleteRoom(RoomModel room) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Room'),
        content: Text('Are you sure you want to delete ${room.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isDeleting = true);
      try {
        await _adminRoomService.deleteRoom(room.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Room deleted successfully.')),
          );
          Navigator.pop(context, true); // Return true to refresh list
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting room: $e')),
          );
          setState(() => _isDeleting = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Room is passed as an argument
    final RoomModel room = ModalRoute.of(context)!.settings.arguments as RoomModel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Room Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.pushNamed(context, '/edit-room', arguments: room);
              if (result == true) {
                // If updated, return true to previous screen (dashboard) to refresh
                Navigator.pop(context, true);
              }
            },
            tooltip: 'Edit Room',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    child: Icon(Icons.meeting_room, size: 40, color: Theme.of(context).primaryColor),
                  ),
                  if (!_isLoadingStatus)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _isBooked ? Colors.red : Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(
                        _isBooked ? Icons.lock : Icons.lock_open,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (!_isLoadingStatus)
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isBooked ? Colors.red.shade100 : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _isBooked ? 'OCCUPIED TODAY' : 'AVAILABLE TODAY',
                    style: TextStyle(
                      color: _isBooked ? Colors.red.shade800 : Colors.green.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Text(
              room.name,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            if (room.createdAt != null)
              Text(
                'Added on ${DateFormat('MMM dd, yyyy').format(room.createdAt!)}',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            const SizedBox(height: 24),
            _buildInfoCard(
              context,
              'Capacity',
              '${room.capacity} seats',
              Icons.people,
            ),
            const SizedBox(height: 24),
            Text(
              'Facilities',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
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
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isDeleting ? null : () => _deleteRoom(room),
                icon: _isDeleting 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.delete_outline, color: Colors.red),
                label: Text(
                  _isDeleting ? 'Deleting...' : 'Delete Room',
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
