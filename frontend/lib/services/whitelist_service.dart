import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/whitelisted_student_model.dart';

class WhitelistService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addToWhitelist(String name, int batch, String password) async {
    final id = Uuid().v4();
    final student = WhitelistedStudent(
      id: id,
      name: name,
      batch: batch,
      password: password,
      createdAt: DateTime.now(),
    );
    await _firestore.collection('whitelist').doc(id).set(student.toJson());
  }

  Future<List<WhitelistedStudent>> getWhitelist() async {
    final snapshot = await _firestore.collection('whitelist').get();
    return snapshot.docs.map((doc) => WhitelistedStudent.fromJson(doc.data())).toList();
  }

  Future<void> removeFromWhitelist(String id) async {
    await _firestore.collection('whitelist').doc(id).delete();
  }

  Future<WhitelistedStudent?> checkWhitelist(String name, int batch, String password) async {
    final snapshot = await _firestore
        .collection('whitelist')
        .where('name', isEqualTo: name)
        .where('batch', isEqualTo: batch)
        .where('password', isEqualTo: password)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return WhitelistedStudent.fromJson(snapshot.docs.first.data());
    }
    return null;
  }

  Future<void> clearWhitelist() async {
    try {
      final snapshot = await _firestore.collection('whitelist').get();
      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Error clearing whitelist in Firebase: $e');
    }
  }
}
