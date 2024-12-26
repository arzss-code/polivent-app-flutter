class User {
  final int userId;
  final String username;
  final String email;
  final String avatar;
  final String about;
  final List<String>? interests; // Tetap gunakan nullable
  final String roleName;

  User({
    required this.userId,
    required this.username,
    required this.email,
    required this.avatar,
    required this.about,
    this.interests,
    required this.roleName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'],
      username: json['username'],
      email: json['email'],
      avatar: json['avatar'] ?? '', // Berikan default kosong
      about: json['about'] ?? '', // Berikan default kosong
      interests: _parseInterests(json), // Method parsing khusus
      roleName: json['role_name'],
    );
  }

  // Method statis untuk parsing interests
  static List<String>? _parseInterests(Map<String, dynamic> json) {
    // Coba beberapa kemungkinan key
    if (json['interests'] != null) {
      return List<String>.from(json['interests']);
    }
    if (json['interest'] != null) {
      return List<String>.from(json['interest']);
    }
    return null;
  }
}
