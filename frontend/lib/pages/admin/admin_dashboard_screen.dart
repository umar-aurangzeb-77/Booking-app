import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/admin_room_service.dart';
import '../../services/booking_service.dart';
import '../../services/student_service.dart';
import '../../models/room_model.dart';
import '../../models/booking_model.dart';
import '../../models/student_model.dart';
import '../../widgets/admin/room_card.dart';
import '../../theme/app_colors.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminRoomService _roomService = AdminRoomService();
  final BookingService _bookingService = BookingService();
  final StudentService _studentService = StudentService();
  
  int _currentIndex = 0;
  List<RoomModel> _rooms = [];
  List<BookingModel> _allBookings = [];
  List<StudentModel> _registeredStudents = [];
  Set<String> _bookedRoomIds = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final today = DateTime.now();

    try {
      final results = await Future.wait([
        _roomService.fetchRooms(),
        _bookingService.fetchBookedRooms(today),
        _studentService.fetchAllStudents(),
      ]);

      setState(() {
        _rooms = results[0] as List<RoomModel>;
        _allBookings = results[1] as List<BookingModel>;
        _registeredStudents = results[2] as List<StudentModel>;
        _bookedRoomIds = _allBookings.map((b) => b.roomId).toSet();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              context.read<AuthProvider>().setRole(null);
              Navigator.pushReplacementNamed(context, '/admin-login');
            },
          ),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : _error != null 
              ? Center(child: Text('Error: $_error'))
              : _buildBody(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color(0x0D000000), // 5% opacity black
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Colors.black,
              unselectedItemColor: Colors.black54,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.meeting_room),
                  label: 'Rooms',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.book_online),
                  label: 'Bookings',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.how_to_reg),
                  label: 'Registered Students',
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _currentIndex == 1 ? null : FloatingActionButton(
        onPressed: _currentIndex == 0 ? _addRoom : _registerNewStudent,
        child: const Icon(Icons.add),
      ),
    );
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0: return 'Manage Rooms';
      case 1: return 'Current Bookings';
      case 2: return 'Registered Students';
      default: return 'Admin Dashboard';
    }
  }

  void _addRoom() async {
    final result = await Navigator.pushNamed(context, '/add-room');
    if (result == true) _loadData();
  }

  void _registerNewStudent() {
    final nameController = TextEditingController();
    final batchController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Register Student'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Full Name')),
            TextField(controller: batchController, decoration: const InputDecoration(labelText: 'Batch (Year)'), keyboardType: TextInputType.number),
            TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Access Password (Student ID)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final batchStr = batchController.text.trim();
              final password = passwordController.text.trim();

              if (name.isNotEmpty && batchStr.isNotEmpty && password.isNotEmpty) {
                final batch = int.tryParse(batchStr);
                if (batch != null) {
                  await _studentService.findOrCreateStudent(
                    name: name,
                    batch: batch,
                    studentId: password,
                  );
                  if (mounted) Navigator.pop(context);
                  _loadData();
                }
              }
            },
            child: const Text('Register'),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0: return _buildRoomsList();
      case 1: return _buildBookingsList();
      case 2: return _buildRegisteredStudents();
      default: return Container();
    }
  }

  Widget _buildRoomsList() {
    if (_rooms.isEmpty) return const Center(child: Text('No rooms found.'));
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        itemCount: _rooms.length,
        itemBuilder: (context, index) {
          final room = _rooms[index];
          return AdminRoomCard(
            room: room,
            isBooked: _bookedRoomIds.contains(room.id),
            onTap: () async {
              final result = await Navigator.pushNamed(context, '/room-details', arguments: room);
              if (result == true) _loadData();
            },
          );
        },
      ),
    );
  }

  Widget _buildBookingsList() {
    if (_allBookings.isEmpty) return const Center(child: Text('No bookings for today.'));
    return ListView.builder(
      itemCount: _allBookings.length,
      itemBuilder: (context, index) {
        final booking = _allBookings[index];
        final room = _rooms.firstWhere((r) => r.id == booking.roomId, orElse: () => RoomModel(id: '', name: 'Unknown Room', capacity: 0));
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.bookmark)),
            title: Text(room.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Booked by: ${booking.studentName} (Batch: ${booking.batch})'),
            trailing: Text(booking.status.toUpperCase(), style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }

  Widget _buildRegisteredStudents() {
    if (_registeredStudents.isEmpty) return const Center(child: Text('No students registered yet.'));
    return ListView.builder(
      itemCount: _registeredStudents.length,
      itemBuilder: (context, index) {
        final student = _registeredStudents[index];
        return ListTile(
          leading: const CircleAvatar(backgroundColor: Colors.blueAccent, child: Icon(Icons.person, color: Colors.white)),
          title: Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('ID: ${student.studentId} | Batch: ${student.batch}'),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Unregister Student?'),
                  content: Text('Are you sure you want to unregister ${student.name}? Their profile and credentials will be deleted.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Unregister'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await _studentService.deleteStudent(student.id);
                _loadData();
              }
            },
          ),
        );
      },
    );
  }
}
