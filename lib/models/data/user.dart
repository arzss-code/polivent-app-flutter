// lib/models/user.dart
class User {
  final int usersId;
  final String username;
  final String email;
  final String password; // Anda mungkin tidak ingin menyimpan password
  final String role;

  User({
    required this.usersId,
    required this.username,
    required this.email,
    required this.password,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      usersId: json['users_id'],
      username: json['username'],
      email: json['email'],
      password: json['password'], // Hati-hati dengan menyimpan password
      role: json['role'],
    );
  }
}
