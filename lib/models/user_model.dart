class User {
  final int id;
  final String username;
  final int points;

  User({
    required this.id,
    required this.username,
    required this.points,
  });

  // Create a copy with optional parameter changes
  User copyWith({
    int? id,
    String? username,
    int? points,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      points: points ?? this.points,
    );
  }

  // Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'points': points,
    };
  }

  // Create from JSON from API
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      points: json['points'] ?? 0,
    );
  }
}
