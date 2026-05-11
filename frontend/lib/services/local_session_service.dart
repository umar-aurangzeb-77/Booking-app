import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/student_model.dart';

class LocalSessionService {
  static const String _studentKey = 'current_student_session';

  Future<void> saveCurrentStudent(StudentModel student) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(student.toJson());
    await prefs.setString(_studentKey, jsonString);
  }

  Future<StudentModel?> getCurrentStudent() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_studentKey);
    if (jsonString != null) {
      try {
        final json = jsonDecode(jsonString);
        return StudentModel.fromJson(json);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<void> clearCurrentStudent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_studentKey);
  }
}
