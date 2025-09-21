class User {
  final String id;
  final String email;
  final String name;
  final int totalSessions;
  final int totalItemsLetGo;
  final DateTime createdAt;
  final bool isChinese;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.totalSessions = 0,
    this.totalItemsLetGo = 0,
    required this.createdAt,
    this.isChinese = false,
  });

  User copyWith({
    String? id,
    String? email,
    String? name,
    int? totalSessions,
    int? totalItemsLetGo,
    DateTime? createdAt,
    bool? isChinese,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      totalSessions: totalSessions ?? this.totalSessions,
      totalItemsLetGo: totalItemsLetGo ?? this.totalItemsLetGo,
      createdAt: createdAt ?? this.createdAt,
      isChinese: isChinese ?? this.isChinese,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'totalSessions': totalSessions,
      'totalItemsLetGo': totalItemsLetGo,
      'createdAt': createdAt.toIso8601String(),
      'isChinese': isChinese,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      totalSessions: json['totalSessions'] ?? 0,
      totalItemsLetGo: json['totalItemsLetGo'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      isChinese: json['isChinese'] ?? false,
    );
  }
}
