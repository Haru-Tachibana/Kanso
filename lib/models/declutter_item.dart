class DeclutterItem {
  final String id;
  final String title;
  final String? description;
  final String? photoPath;
  final String? memo;
  final DateTime createdAt;
  final bool isKept;
  final bool isDiscarded;

  DeclutterItem({
    required this.id,
    required this.title,
    this.description,
    this.photoPath,
    this.memo,
    required this.createdAt,
    this.isKept = false,
    this.isDiscarded = false,
  });

  DeclutterItem copyWith({
    String? id,
    String? title,
    String? description,
    String? photoPath,
    String? memo,
    DateTime? createdAt,
    bool? isKept,
    bool? isDiscarded,
  }) {
    return DeclutterItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      photoPath: photoPath ?? this.photoPath,
      memo: memo ?? this.memo,
      createdAt: createdAt ?? this.createdAt,
      isKept: isKept ?? this.isKept,
      isDiscarded: isDiscarded ?? this.isDiscarded,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'photoPath': photoPath,
      'memo': memo,
      'createdAt': createdAt.toIso8601String(),
      'isKept': isKept,
      'isDiscarded': isDiscarded,
    };
  }

  factory DeclutterItem.fromJson(Map<String, dynamic> json) {
    return DeclutterItem(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      photoPath: json['photoPath'],
      memo: json['memo'],
      createdAt: DateTime.parse(json['createdAt']),
      isKept: json['isKept'] ?? false,
      isDiscarded: json['isDiscarded'] ?? false,
    );
  }
}
