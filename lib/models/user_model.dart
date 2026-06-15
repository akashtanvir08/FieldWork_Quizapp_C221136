import 'dart:convert';

class User {
  final String username;
  final String name;
  final String password;
  final String role; // 'student' or 'admin'
  final Map<String, int> highestScores; // subjectName -> highestScore
  final Map<String, int> lastScores;     // subjectName -> lastScore
  final Map<String, bool> lastPassStatus; // subjectName -> passed (true/false)

  User({
    required this.username,
    required this.name,
    required this.password,
    this.role = 'student',
    required this.highestScores,
    required this.lastScores,
    required this.lastPassStatus,
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'name': name,
      'password': password,
      'role': role,
      'highestScores': highestScores,
      'lastScores': lastScores,
      'lastPassStatus': lastPassStatus,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      username: map['username'] as String,
      name: map['name'] as String,
      password: map['password'] as String,
      role: map['role'] as String? ?? 'student',
      highestScores: Map<String, int>.from(map['highestScores'] ?? {}),
      lastScores: Map<String, int>.from(map['lastScores'] ?? {}),
      lastPassStatus: Map<String, bool>.from(map['lastPassStatus'] ?? {}),
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source) as Map<String, dynamic>);
}
