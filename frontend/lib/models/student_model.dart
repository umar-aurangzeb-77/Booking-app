class StudentModel {
  final String id;
  final String name;
  final int batch;
  final String studentId;
  final DateTime createdAt;

  StudentModel({
    required this.id,
    required this.name,
    required this.batch,
    required this.studentId,
    required this.createdAt,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'].toString(),
      name: json['name'],
      batch: json['batch'] is String ? int.parse(json['batch']) : json['batch'],
      studentId: json['student_id'].toString(),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) ?? DateTime.now() : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'batch': batch,
      'student_id': studentId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  StudentModel copyWith({
    String? id,
    String? name,
    int? batch,
    String? studentId,
    DateTime? createdAt,
  }) {
    return StudentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      batch: batch ?? this.batch,
      studentId: studentId ?? this.studentId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
