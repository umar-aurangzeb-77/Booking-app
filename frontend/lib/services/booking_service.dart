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
    final fullyBookedRoomIds = await _getFullyBookedRoomIds(date, allRooms);

    return allRooms.where((room) => !fullyBookedRoomIds.contains(room.id)).toList();
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

  Future<List<String>> fetchBookedSeats(String roomId, DateTime date) async {
    final formattedDate = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    if (_useMock) {
      return _mockBookings
          .where((b) => b.roomId == roomId && b.seatId != null && b.bookingDate.toIso8601String().startsWith(formattedDate))
          .map((b) => b.seatId!)
          .toList();
    }

    try {
      final allSnapshot = await _firestore.collection('bookings').get();
      final allBookings = allSnapshot.docs.map((doc) => BookingModel.fromJson(doc.data())).toList();
      return allBookings
          .where((b) => b.roomId == roomId && b.seatId != null && b.bookingDate.toIso8601String().startsWith(formattedDate))
          .map((b) => b.seatId!)
          .toList();
    } catch (e) {
      _useMock = true;
      return _mockBookings
          .where((b) => b.roomId == roomId && b.seatId != null && b.bookingDate.toIso8601String().startsWith(formattedDate))
          .map((b) => b.seatId!)
          .toList();
    }
  }

  Future<List<BookingModel>> bookSeats({
    required RoomModel room,
    required List<String> seatIds,
    required Map<String, StudentModel> seatAssignments,
    required DateTime bookingDate,
    required StudentModel currentStudent,
  }) async {
    final currentlyBookedSeats = await fetchBookedSeats(room.id, bookingDate);
    
    for (var seat in seatIds) {
      if (currentlyBookedSeats.contains(seat)) {
        throw Exception('Seat $seat is already booked for the selected date.');
      }
    }

    List<BookingModel> newBookings = [];

    for (var seat in seatIds) {
      final student = seatAssignments[seat]!;
      final newBooking = BookingModel(
        id: Uuid().v4(),
        roomId: room.id,
        seatId: seat,
        studentRecordId: student.id,
        studentId: student.studentId,
        studentName: student.name,
        batch: student.batch,
        bookingDate: bookingDate,
        status: 'active',
        createdAt: DateTime.now(),
        bookedById: currentStudent.id,
        bookedByName: currentStudent.name,
      );
      newBookings.add(newBooking);
    }

    if (_useMock) {
      _mockBookings.addAll(newBookings);
      return newBookings;
    }

    try {
      final batch = _firestore.batch();
      for (var booking in newBookings) {
        final docRef = _firestore.collection('bookings').doc(booking.id);
        batch.set(docRef, booking.toJson());
      }
      await batch.commit();
      return newBookings;
    } catch (e) {
      debugPrint('Error inserting bookings to Firebase, falling back to mock: $e');
      _useMock = true;
      _mockBookings.addAll(newBookings);
      return newBookings;
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

  // Helper to fetch IDs of rooms that have NO available seats on a specific date
  Future<List<String>> _getFullyBookedRoomIds(DateTime date, List<RoomModel> allRooms) async {
    final formattedDate = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    List<BookingModel> bookingsForDate = [];

    if (_useMock) {
      bookingsForDate = _mockBookings.where((b) => b.bookingDate.toIso8601String().startsWith(formattedDate)).toList();
    } else {
      try {
        final snapshot = await _firestore.collection('bookings').get();
        final allBookings = snapshot.docs.map((doc) => BookingModel.fromJson(doc.data())).toList();
        bookingsForDate = allBookings.where((b) => b.bookingDate.toIso8601String().startsWith(formattedDate)).toList();
      } catch (e) {
        _useMock = true;
        bookingsForDate = _mockBookings.where((b) => b.bookingDate.toIso8601String().startsWith(formattedDate)).toList();
      }
    }

    // Group bookings by roomId to count booked seats
    Map<String, int> bookedSeatCounts = {};
    for (var b in bookingsForDate) {
      bookedSeatCounts[b.roomId] = (bookedSeatCounts[b.roomId] ?? 0) + 1;
    }

    List<String> fullyBookedRooms = [];
    for (var room in allRooms) {
      int totalSeats = room.seatmap?.length ?? room.capacity;
      if ((bookedSeatCounts[room.id] ?? 0) >= totalSeats && totalSeats > 0) {
        fullyBookedRooms.add(room.id);
      }
    }

    return fullyBookedRooms;
  }
}

