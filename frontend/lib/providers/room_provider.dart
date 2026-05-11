import 'package:flutter/material.dart';
import '../models/room_model.dart';
import '../models/booking_model.dart';
import '../services/admin_room_service.dart';
import '../services/booking_service.dart';

class RoomProvider with ChangeNotifier {
  final AdminRoomService _roomService = AdminRoomService();
  final BookingService _bookingService = BookingService();
  
  List<RoomModel> _rooms = [];
  Set<String> _bookedRoomIds = {};
  bool _isLoading = false;
  String? _error;

  List<RoomModel> get rooms => _rooms;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool isRoomBooked(String roomId) => _bookedRoomIds.contains(roomId);

  Future<void> loadRooms() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final results = await Future.wait([
        _roomService.fetchRooms(),
        _bookingService.fetchBookedRooms(DateTime.now()),
      ]);
      
      _rooms = results[0] as List<RoomModel>;
      final bookings = results[1] as List<BookingModel>;
      _bookedRoomIds = bookings.map((b) => b.roomId).toSet();
      
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
