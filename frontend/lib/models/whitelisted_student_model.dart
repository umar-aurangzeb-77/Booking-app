class WhitelistedStudent {
  final String id;
  final String name;
  final int batch;
  final String password;
  final DateTime createdAt;

  WhitelistedStudent({
    required this.id,
    required this.name,
    required this.batch,
    required this.password,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'batch': batch,
      'password': password,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory WhitelistedStudent.fromJson(Map<String, dynamic> json) {
    return WhitelistedStudent(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      batch: json['batch'] ?? 0,
      password: json['password'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }
}
