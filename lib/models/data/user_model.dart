class User {
  final int userId;
  final String username;
  final String email;
  final String about;

  User({
    required this.userId,
    required this.username,
    required this.email,
    required this.about,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId:
          json['user_id'] != null ? int.parse(json['user_id'].toString()) : 0,
      username: json['username']?.toString() ?? 'Anonymous',
      email: json['email']?.toString() ?? '',
      about: json['about']?.toString() ?? '',
    );
  }
}
