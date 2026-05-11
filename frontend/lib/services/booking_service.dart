import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/room_model.dart';
import '../models/student_model.dart';
import '../models/booking_model.dart';
import 'admin_room_service.dart';
import 'package:uuid/uuid.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AdminRoomService _adminRoomService = AdminRoomService();

  final List<BookingModel> _mockBookings = [];
  bool _useMock = false;

  BookingService();

  Future<List<RoomModel>> fetchAvailableRooms(DateTime date) async {
    final allRooms = await _adminRoomService.fetchRooms();
    final bookedRoomIds = await _getBookedRoomIds(date);

    return allRooms.where((room) => !bookedRoomIds.contains(room.id)).toList();
  }

  Future<List<BookingModel>> fetchBookedRooms(DateTime date) async {
    final formattedDate = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    if (_useMock) {
      return _mockBookings.where((b) => b.bookingDate.toIso8601String().startsWith(formattedDate)).toList();
    }

    try {
      final snapshot = await _firestore
          .collection('bookings')
          .where('booking_date', isGreaterThanOrEqualTo: formattedDate)
          .where('booking_date', isLessThan: "${date.year}-${date.month.toString().padLeft(2, '0')}-${(date.day + 1).toString().padLeft(2, '0')}")
          .get();

      // Better fallback: just fetch all for the current demo and filter locally since date strings can be tricky in Firestore without proper index
      final allSnapshot = await _firestore.collection('bookings').get();
      final allBookings = allSnapshot.docs.map((doc) => BookingModel.fromJson(doc.data())).toList();
      return allBookings.where((b) => b.bookingDate.toIso8601String().startsWith(formattedDate)).toList();
      
    } catch (e) {
      debugPrint('Error fetching booked rooms from Firebase, falling back to mock: $e');
      _useMock = true;
      return _mockBookings.where((b) => b.bookingDate.toIso8601String().startsWith(formattedDate)).toList();
    }
  }

  Future<List<BookingModel>> fetchMyBookings(String studentRecordId) async {
    if (_useMock) {
      return _mockBookings.where((b) => b.studentRecordId == studentRecordId).toList();
    }

    try {
      final snapshot = await _firestore
          .collection('bookings')
          .where('student_record_id', isEqualTo: studentRecordId)
          .get();
      
      final bookings = snapshot.docs.map((doc) => BookingModel.fromJson(doc.data())).toList();
      bookings.sort((a, b) => b.bookingDate.compareTo(a.bookingDate));
      return bookings;
    } catch (e) {
      debugPrint('Error fetching my bookings from Firebase, falling back to mock: $e');
      _useMock = true;
      return _mockBookings.where((b) => b.studentRecordId == studentRecordId).toList();
    }
  }

  Future<bool> getRoomBookingStatus(String roomId, DateTime date) async {
    final bookedRoomIds = await _getBookedRoomIds(date);
    return bookedRoomIds.contains(roomId);
  }

  Future<BookingModel> bookRoom({
    required RoomModel room,
    required StudentModel student,
    required DateTime bookingDate,
  }) async {
    final isBooked = await getRoomBookingStatus(room.id, bookingDate);
    if (isBooked) {
      throw Exception('This room is already booked for the selected date.');
    }

    final newBooking = BookingModel(
      id: Uuid().v4(),
      roomId: room.id,
      studentRecordId: student.id,
      studentId: student.studentId,
      studentName: student.name,
      batch: student.batch,
      bookingDate: bookingDate,
      status: 'active',
      createdAt: DateTime.now(),
    );

    if (_useMock) {
      _mockBookings.add(newBooking);
      return newBooking;
    }

    try {
      await _firestore.collection('bookings').doc(newBooking.id).set(newBooking.toJson());
      return newBooking;
    } catch (e) {
      debugPrint('Error inserting booking to Firebase, falling back to mock: $e');
      _useMock = true;
      _mockBookings.add(newBooking);
      return newBooking;
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    if (_useMock) {
      _mockBookings.removeWhere((b) => b.id == bookingId);
      return;
    }
    try {
      await _firestore.collection('bookings').doc(bookingId).delete();
    } catch (e) {
      debugPrint('Error canceling booking in Firebase: $e');
    }
  }

  // Helper to fetch IDs of rooms booked on a specific date
  Future<List<String>> _getBookedRoomIds(DateTime date) async {
    final formattedDate = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    if (_useMock) {
      return _mockBookings
          .where((b) => b.bookingDate.toIso8601String().startsWith(formattedDate))
          .map((b) => b.roomId)
          .toList();
    }

    try {
      // Just fetch all bookings and filter to avoid complex composite index requirements
      final snapshot = await _firestore.collection('bookings').get();
      final bookings = snapshot.docs.map((doc) => BookingModel.fromJson(doc.data())).toList();
      return bookings
          .where((b) => b.bookingDate.toIso8601String().startsWith(formattedDate))
          .map((b) => b.roomId)
          .toList();
    } catch (e) {
      _useMock = true;
      return _mockBookings
          .where((b) => b.bookingDate.toIso8601String().startsWith(formattedDate))
          .map((b) => b.roomId)
          .toList();
    }
  }
}
