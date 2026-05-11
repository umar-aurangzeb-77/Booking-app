import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/room_model.dart';

class AdminRoomService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Local fallback if Firebase fails
  final List<RoomModel> _mockRooms = [];
  bool _useMock = false;

  AdminRoomService() {
    // Pre-populate with 100 mock rooms so the admin can instantly test scrolling and capacity
    if (_mockRooms.isEmpty) {
      for (int i = 1; i <= 100; i++) {
        _mockRooms.add(RoomModel(
          id: 'mock-room-$i',
          name: 'Room 1${i.toString().padLeft(2, '0')}',
          capacity: 20 + (i % 5) * 10,
          facilities: ['Projector', 'Whiteboard', if (i % 2 == 0) 'Air Conditioning'],
          createdAt: DateTime.now().subtract(Duration(days: i)),
        ));
      }
    }
  }

  Future<List<RoomModel>> fetchRooms() async {
    if (_useMock) {
      return _mockRooms;
    }

    try {
      final snapshot = await _firestore.collection('rooms').get().timeout(const Duration(seconds: 3));
      final rooms = snapshot.docs.map((doc) => RoomModel.fromJson(doc.data())).toList();
      return rooms;
    } catch (e) {
      debugPrint('Error fetching rooms from Firebase, falling back to mock. Error: $e');
      _useMock = true;
      return _mockRooms;
    }
  }

  Future<RoomModel?> getRoomById(String id) async {
    if (_useMock) {
      try {
        return _mockRooms.firstWhere((r) => r.id == id);
      } catch (_) {
        return null;
      }
    }

    try {
      final doc = await _firestore.collection('rooms').doc(id).get();
      if (doc.exists && doc.data() != null) {
        return RoomModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting room by ID: $e');
      return null;
    }
  }

  Future<RoomModel> addRoom(RoomModel room) async {
    final newRoom = room.copyWith(
      id: Uuid().v4(),
      createdAt: DateTime.now(),
    );

    if (_useMock) {
      _mockRooms.add(newRoom);
      return newRoom;
    }

    try {
      await _firestore.collection('rooms').doc(newRoom.id).set(newRoom.toJson()).timeout(const Duration(seconds: 3));
      return newRoom;
    } catch (e) {
      debugPrint('Error inserting room to Firebase: $e');
      _useMock = true;
      _mockRooms.add(newRoom);
      return newRoom;
    }
  }

  Future<RoomModel> updateRoom(RoomModel room) async {
    if (_useMock) {
      final index = _mockRooms.indexWhere((r) => r.id == room.id);
      if (index != -1) {
        _mockRooms[index] = room;
      }
      return room;
    }

    try {
      await _firestore.collection('rooms').doc(room.id).update(room.toJson());
      return room;
    } catch (e) {
      debugPrint('Error updating room in Firebase: $e');
      return room;
    }
  }

  Future<void> deleteRoom(String id) async {
    if (_useMock) {
      _mockRooms.removeWhere((r) => r.id == id);
      return;
    }

    try {
      await _firestore.collection('rooms').doc(id).delete();
    } catch (e) {
      debugPrint('Error deleting room from Firebase: $e');
    }
  }
}
