import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import 'package:polivent_app/config/app_config.dart';

const _storage = FlutterSecureStorage();
const _accessTokenKey = 'access_token';
const _refreshTokenKey = 'refresh_token';

// Simpan token
Future<void> saveToken(String token) async {
  await _storage.write(key: _accessTokenKey, value: token);
}

// Ambil token
Future<String?> getToken() async {
  return await _storage.read(key: _accessTokenKey);
}

// Decode payload token
Future<Map<String, dynamic>?> decodeTokenPayload(String token) async {
  try {
    return JwtDecoder.decode(token);
  } catch (e) {
    return null;
  }
}

// Hapus token
Future<void> removeToken() async {
  await _storage.delete(key: _accessTokenKey);
}

// Simpan refresh token
Future<void> saveRefreshToken(String refreshToken) async {
  await _storage.write(key: _refreshTokenKey, value: refreshToken);
}

// Ambil refresh token
Future<String?> getRefreshToken() async {
  return await _storage.read(key: _refreshTokenKey);
}

// Hapus refresh token
Future<void> removeRefreshToken() async {
  await _storage.delete(key: _refreshTokenKey);
}

// Cek apakah token sudah expired
Future<bool> isTokenExpired() async {
  final token = await getToken();
  if (token == null) return true;

  try {
    return JwtDecoder.isExpired(token);
  } catch (e) {
    return true;
  }
}

// Decode token untuk mendapatkan payload
Future<Map<String, dynamic>?> decodeToken() async {
  final token = await getToken();
  if (token == null) return null;

  try {
    return JwtDecoder.decode(token);
  } catch (e) {
    return null;
  }
}

// Refresh token
Future<String?> refreshToken() async {
  final refreshToken = await getRefreshToken();

  if (refreshToken == null) return null;

  try {
    final response = await http.post(
      Uri.parse('$devApiBaseUrl/refresh-token'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $refreshToken'
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      if (jsonResponse['status'] == 'success') {
        final newToken = jsonResponse['data']['token'];
        await saveToken(newToken);
        return newToken;
      }
    }

    // Jika refresh token gagal, logout
    await logout();
    return null;
  } catch (e) {
    await logout();
    return null;
  }
}

// Logout dan hapus semua token
Future<void> logout() async {
  await removeToken();
  await removeRefreshToken();
}

// Cek status autentikasi
Future<bool> isAuthenticated() async {
  final token = await getToken();

  if (token == null) return false;

  try {
    // Cek apakah token sudah expired
    if (JwtDecoder.isExpired(token)) {
      // Coba refresh token
      final newToken = await refreshToken();
      return newToken != null;
    }
    return true;
  } catch (e) {
    return false;
  }
}

// Dapatkan user ID dari token
Future<String?> getUserId() async {
  final tokenPayload = await decodeToken();
  return tokenPayload?['user_id'];
}

// Dapatkan roles dari token
Future<List<String>> getUserRoles() async {
  final tokenPayload = await decodeToken();

  if (tokenPayload != null && tokenPayload.containsKey('roles')) {
    return List<String>.from(tokenPayload['roles']);
  }

  return [];
}
