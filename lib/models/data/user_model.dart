class User {
  final int userId;
  final String username;
  final String email;
  final String about;
  final String? roles;

  User({
    required this.userId,
    required this.username,
    required this.email,
    required this.about,
    this.roles,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId:
          json['user_id'] != null ? int.parse(json['user_id'].toString()) : 0,
      username: json['username']?.toString() ?? 'Anonymous',
      email: json['email']?.toString() ?? '',
      about: json['about']?.toString() ?? '',
      roles: json['roles'] ?? 'Member', // Default role jika null
    );
  }

  // Konversi ke JSON untuk penyimpanan lokal
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'email': email,
      'about': about,
      'roles': roles,
    };
  }
}


