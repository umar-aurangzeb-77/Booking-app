import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/booking_service.dart';
import '../../services/local_session_service.dart';
import '../../models/student_model.dart';
import '../../models/room_model.dart';
import '../../models/booking_model.dart';
import '../../widgets/student/available_room_card.dart';
import '../../widgets/student/booked_room_card.dart';
import '../../widgets/student/my_booking_card.dart';
import '../../widgets/student/dashboard_section_header.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  final LocalSessionService _sessionService = LocalSessionService();
  final BookingService _bookingService = BookingService();

  StudentModel? _student;
  List<RoomModel> _availableRooms = [];
  List<BookingModel> _bookedRooms = [];
  List<BookingModel> _myBookings = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    _student = await _sessionService.getCurrentStudent();
    if (_student == null) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/student-entry');
      }
      return;
    }

    final today = DateTime.now();
    
    try {
      final available = await _bookingService.fetchAvailableRooms(today);
      final booked = await _bookingService.fetchBookedRooms(today);
      final mine = await _bookingService.fetchMyBookings(_student!.id);

      if (mounted) {
        setState(() {
          _availableRooms = available;
          _bookedRooms = booked;
          _myBookings = mine;
        });
      }
    } catch (e) {
      // Ignore or show snackbar
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _logout() async {
    await _sessionService.clearCurrentStudent();
    if (mounted) {
      context.read<AuthProvider>().setRole(null);
      Navigator.pushReplacementNamed(context, '/student-entry');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, ${_student?.name}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Batch: ${_student?.batch} | ID: ${_student?.studentId}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Available Rooms
              DashboardSectionHeader(
                title: 'Available Rooms Today',
                onViewAll: () => Navigator.pushNamed(context, '/available-rooms').then((_) => _loadData()),
              ),
              if (_availableRooms.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('No rooms available right now.', style: TextStyle(color: Colors.grey)),
                )
              else
                ..._availableRooms.take(3).map((room) => AvailableRoomCard(
                      room: room,
                      onTap: () async {
                        await Navigator.pushNamed(context, '/room-booking', arguments: room);
                        _loadData();
                      },
                    )),

              const SizedBox(height: 24),

              // Booked Rooms
              DashboardSectionHeader(
                title: 'Booked Rooms Today',
                onViewAll: () => Navigator.pushNamed(context, '/booked-rooms'),
              ),
              if (_bookedRooms.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('No rooms are currently booked.', style: TextStyle(color: Colors.grey)),
                )
              else
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _bookedRooms.length,
                    itemBuilder: (context, index) {
                      return BookedRoomCard(booking: _bookedRooms[index]);
                    },
                  ),
                ),

              const SizedBox(height: 24),

              // My Bookings
              DashboardSectionHeader(
                title: 'My Bookings',
                onViewAll: () => Navigator.pushNamed(context, '/my-bookings'),
              ),
              if (_myBookings.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text('You have not booked any rooms yet.', style: TextStyle(color: Colors.grey)),
                )
              else
                ..._myBookings.take(3).map((booking) => MyBookingCard(booking: booking)),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
