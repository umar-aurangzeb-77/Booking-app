import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';

class BookingProvider with ChangeNotifier {
  final BookingService _service = BookingService();
  List<BookingModel> _bookings = [];
  bool _isLoading = false;
  String? _error;

  List<BookingModel> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<BookingModel> get upcomingBookings => _bookings.where((b) => b.status == 'active').toList();
  List<BookingModel> get pastBookings => _bookings.where((b) => b.status != 'active').toList();

  Future<void> loadUserBookings([String studentId = '']) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _bookings = await _service.fetchMyBookings(studentId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    try {
      await _service.cancelBooking(bookingId);
      _bookings.removeWhere((b) => b.id == bookingId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
