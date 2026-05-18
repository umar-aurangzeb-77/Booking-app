import 'package:flutter/material.dart';
import '../../models/room_model.dart';
import '../../models/student_model.dart';
import '../../services/booking_service.dart';
import '../../services/local_session_service.dart';
import '../../services/student_service.dart';
import 'package:intl/intl.dart';

class RoomBookingScreen extends StatefulWidget {
  const RoomBookingScreen({super.key});

  @override
  State<RoomBookingScreen> createState() => _RoomBookingScreenState();
}

class _RoomBookingScreenState extends State<RoomBookingScreen> {
  final BookingService _bookingService = BookingService();
  final LocalSessionService _sessionService = LocalSessionService();
  final StudentService _studentService = StudentService();
  
  DateTime? _selectedDate;
  bool _isLoading = false;
  bool _isLoadingSeats = false;

  StudentModel? _currentStudent;
  List<StudentModel> _allStudents = [];
  
  List<String> _bookedSeats = [];
  List<String> _selectedSeats = [];
  Map<String, String> _seatAssignments = {}; // Maps seat ID to student ID

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final current = await _sessionService.getCurrentStudent();
    final all = await _studentService.fetchAllStudents();
    
    final uniqueStudents = <StudentModel>[];
    if (current != null) {
      uniqueStudents.add(current);
    }
    for (var student in all) {
      if (!uniqueStudents.any((s) => s.id == student.id)) {
        uniqueStudents.add(student);
      }
    }

    if (mounted) {
      setState(() {
        _currentStudent = current;
        _allStudents = uniqueStudents;
      });
    }
  }

  Future<void> _selectDate(BuildContext context, RoomModel room) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), // Prevent past bookings
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedSeats.clear();
        _seatAssignments.clear();
      });
      _fetchBookedSeats(room.id, picked);
    }
  }

  Future<void> _fetchBookedSeats(String roomId, DateTime date) async {
    setState(() => _isLoadingSeats = true);
    try {
      final booked = await _bookingService.fetchBookedSeats(roomId, date);
      if (mounted) {
        setState(() {
          _bookedSeats = booked;
        });
      }
    } catch (e) {
      // ignore
    } finally {
      if (mounted) {
        setState(() => _isLoadingSeats = false);
      }
    }
  }

  void _toggleSeat(String seat) {
    if (_bookedSeats.contains(seat)) return;

    setState(() {
      if (_selectedSeats.contains(seat)) {
        _selectedSeats.remove(seat);
        _seatAssignments.remove(seat);
      } else {
        if (_selectedSeats.length >= 3) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You can only book up to 3 seats at a time.')),
          );
          return;
        }
        _selectedSeats.add(seat);
        // Removed auto-assignment to prevent dropdown assertion failures.
      }
    });
  }

  Future<void> _confirmBooking(RoomModel room) async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date for booking')),
      );
      return;
    }
    if (_selectedSeats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one seat.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Reconstruct the map of seat -> StudentModel for the booking service
      Map<String, StudentModel> assignmentsForService = {};
      for (var entry in _seatAssignments.entries) {
        assignmentsForService[entry.key] = _allStudents.firstWhere((s) => s.id == entry.value);
      }

      await _bookingService.bookSeats(
        room: room,
        seatIds: _selectedSeats,
        seatAssignments: assignmentsForService,
        bookingDate: _selectedDate!,
        currentStudent: _currentStudent!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully booked ${_selectedSeats.length} seat(s)!')),
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
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args == null || args is! RoomModel) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Room not found. Please navigate back and try again.')),
      );
    }
    final RoomModel room = args;
    final List<String> seatmap = room.seatmap ?? List.generate(room.capacity, (i) => 'Seat ${i + 1}');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Seats'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              room.name,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Capacity: ${room.capacity} seats',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            
            const Text(
              '1. Select Date',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _selectDate(context, room),
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
            const SizedBox(height: 32),

            if (_selectedDate != null) ...[
              const Text(
                '2. Select Seats (Max 3)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (_isLoadingSeats)
                const Center(child: CircularProgressIndicator())
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2,
                  ),
                  itemCount: seatmap.length,
                  itemBuilder: (context, index) {
                    final seat = seatmap[index];
                    final isBooked = _bookedSeats.contains(seat);
                    final isSelected = _selectedSeats.contains(seat);

                    return InkWell(
                      onTap: isBooked ? null : () => _toggleSeat(seat),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isBooked
                              ? Colors.grey.shade300
                              : isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.white,
                          border: Border.all(
                            color: isBooked
                                ? Colors.grey.shade400
                                : isSelected
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey.shade400,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          seat.replaceAll('Seat ', ''),
                          style: TextStyle(
                            color: isBooked
                                ? Colors.grey.shade600
                                : isSelected
                                    ? Colors.white
                                    : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegend(Colors.white, 'Available', true),
                    const SizedBox(width: 16),
                    _buildLegend(Theme.of(context).primaryColor, 'Selected', false),
                    const SizedBox(width: 16),
                    _buildLegend(Colors.grey.shade300, 'Booked', false),
                  ],
                ),
            ],
            
            if (_selectedSeats.isNotEmpty) ...[
              const SizedBox(height: 32),
              const Text(
                '3. Assign Students',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ..._selectedSeats.map((seat) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          seat,
                          style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          value: _seatAssignments[seat],
                          items: _allStudents.map((student) {
                            final isSelf = _currentStudent?.id == student.id;
                            return DropdownMenuItem<String>(
                              value: student.id,
                              child: Text(
                                isSelf ? 'Self (${student.name})' : '${student.name} (${student.batch})',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _seatAssignments[seat] = val;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],

            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading || _selectedSeats.isEmpty ? null : () => _confirmBooking(room),
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

  Widget _buildLegend(Color color, String label, bool hasBorder) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: hasBorder ? Border.all(color: Colors.grey.shade400) : null,
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
      ],
    );
  }
}

