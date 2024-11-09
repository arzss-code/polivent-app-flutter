// lib/models/auth_token.dart
class AuthToken {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;

  AuthToken({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  factory AuthToken.fromJson(Map<String, dynamic> json) {
    return AuthToken(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      expiresAt: DateTime.now().add(Duration(seconds: json['expires_in'])),
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
