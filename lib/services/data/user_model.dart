class User {
  final int userId;
  final String username;
  final String email;
  final String avatar;
  final String about;

  User({
    required this.userId,
    required this.username,
    required this.email,
    required this.avatar,
    required this.about,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'],
      username: json['username'],
      email: json['email'],
      avatar: json['avatar'],
      about: json['about'],
    );
  }
}
