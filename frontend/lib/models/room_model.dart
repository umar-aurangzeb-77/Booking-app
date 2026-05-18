class RoomModel {
  final String id;
  final String name;
  final String? campus;
  final int? floor;
  final int capacity;
  final Map<String, dynamic>? metadata;
  final List<String> facilities;
  final List<String>? seatmap;
  final DateTime? createdAt;

  RoomModel({
    required this.id,
    required this.name,
    this.campus,
    this.floor,
    required this.capacity,
    this.metadata,
    this.facilities = const [],
    this.seatmap,
    this.createdAt,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      campus: json['campus'],
      floor: json['floor'],
      capacity: json['capacity'] ?? 0,
      metadata: json['metadata'],
      facilities: json['facilities'] != null ? List<String>.from(json['facilities']) : [],
      seatmap: json['seatmap'] != null ? List<String>.from(json['seatmap']) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (campus != null) 'campus': campus,
      if (floor != null) 'floor': floor,
      'capacity': capacity,
      if (metadata != null) 'metadata': metadata,
      'facilities': facilities,
      if (seatmap != null) 'seatmap': seatmap,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  RoomModel copyWith({
    String? id,
    String? name,
    String? campus,
    int? floor,
    int? capacity,
    Map<String, dynamic>? metadata,
    List<String>? facilities,
    List<String>? seatmap,
    DateTime? createdAt,
  }) {
    return RoomModel(
      id: id ?? this.id,
      name: name ?? this.name,
      campus: campus ?? this.campus,
      floor: floor ?? this.floor,
      capacity: capacity ?? this.capacity,
      metadata: metadata ?? this.metadata,
      facilities: facilities ?? this.facilities,
      seatmap: seatmap ?? this.seatmap,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
