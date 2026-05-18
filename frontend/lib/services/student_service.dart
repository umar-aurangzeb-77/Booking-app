import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/student_model.dart';

class StudentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Local fallback if Firebase is not ready
  final List<StudentModel> _mockStudents = [];
  bool _useMock = false;

  StudentService();

  Future<StudentModel?> findStudentByCredentials(String name, String studentId) async {
    if (_useMock) {
      try {
        return _mockStudents.firstWhere((s) => s.studentId == studentId && s.name == name);
      } catch (_) {
        return null;
      }
    }

    try {
      final snapshot = await _firestore
          .collection('students')
          .where('student_id', isEqualTo: studentId)
          .where('name', isEqualTo: name)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return StudentModel.fromJson(snapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      debugPrint('Error finding student in Firebase, checking mock: $e');
      _useMock = true;
      try {
        return _mockStudents.firstWhere((s) => s.studentId == studentId && s.name == name);
      } catch (_) {
        return null;
      }
    }
  }

  Future<StudentModel> createStudent(StudentModel student) async {
    final newStudent = student.copyWith(
      id: Uuid().v4(),
      createdAt: DateTime.now(),
    );

    if (_useMock) {
      _mockStudents.add(newStudent);
      return newStudent;
    }

    try {
      await _firestore.collection('students').doc(newStudent.id).set(newStudent.toJson());
      return newStudent;
    } catch (e) {
      debugPrint('Error inserting student to Firebase, falling back to mock: $e');
      _useMock = true;
      _mockStudents.add(newStudent);
      return newStudent;
    }
  }

  Future<StudentModel> findOrCreateStudent({
    required String name,
    required int batch,
    required String studentId,
  }) async {
    final existing = await findStudentByCredentials(name, studentId);
    if (existing != null) {
      return existing;
    }

    final newStudent = StudentModel(
      id: '', // Will be generated in createStudent
      name: name,
      batch: batch,
      studentId: studentId,
      createdAt: DateTime.now(),
    );

    return await createStudent(newStudent);
  }

  Future<List<StudentModel>> fetchAllStudents() async {
    if (_useMock) {
      return _mockStudents;
    }

    try {
      final snapshot = await _firestore.collection('students').get();
      return snapshot.docs.map((doc) => StudentModel.fromJson(doc.data())).toList();
    } catch (e) {
      debugPrint('Error fetching all students from Firebase, falling back to mock: $e');
      _useMock = true;
      return _mockStudents;
    }
  }
}
