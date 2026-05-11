class BookingModel {
  final String id;
  final String roomId;
  final String studentRecordId;
  final String studentId;
  final String studentName;
  final int batch;
  final DateTime bookingDate;
  final String status;
  final DateTime createdAt;

  BookingModel({
    required this.id,
    required this.roomId,
    required this.studentRecordId,
    required this.studentId,
    required this.studentName,
    required this.batch,
    required this.bookingDate,
    required this.status,
    required this.createdAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'].toString(),
      roomId: json['room_id'].toString(),
      studentRecordId: json['student_record_id'].toString(),
      studentId: json['student_id'].toString(),
      studentName: json['student_name'].toString(),
      batch: json['batch'] is String ? int.parse(json['batch']) : json['batch'],
      bookingDate: DateTime.parse(json['booking_date']),
      status: json['status'] ?? 'Active',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_id': roomId,
      'student_record_id': studentRecordId,
      'student_id': studentId,
      'student_name': studentName,
      'batch': batch,
      'booking_date': "${bookingDate.year}-${bookingDate.month.toString().padLeft(2, '0')}-${bookingDate.day.toString().padLeft(2, '0')}",
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  BookingModel copyWith({
    String? id,
    String? roomId,
    String? studentRecordId,
    String? studentId,
    String? studentName,
    int? batch,
    DateTime? bookingDate,
    String? status,
    DateTime? createdAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      studentRecordId: studentRecordId ?? this.studentRecordId,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      batch: batch ?? this.batch,
      bookingDate: bookingDate ?? this.bookingDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
