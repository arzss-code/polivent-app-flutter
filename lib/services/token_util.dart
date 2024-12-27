// import 'dart:convert';

// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';
// import 'package:http/http.dart' as http;
// import 'package:polivent_app/config/app_config.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// const _storage = FlutterSecureStorage();
// const _accessTokenKey = 'access_token';
// const _refreshTokenKey = 'refresh_token';

// // Decode payload token
// Future<Map<String, dynamic>?> decodeTokenPayload(String token) async {
//   try {
//     return JwtDecoder.decode(token);
//   } catch (e) {
//     return null;
//   }
// }

// // Simpan access token
// Future<void> saveAccessToken(String token) async {
//   await _storage.write(key: _accessTokenKey, value: token);
// }

// // Simpan refresh token
// Future<void> saveRefreshToken(String token) async {
//   await _storage.write(key: _refreshTokenKey, value: token);
// }

// // Ambil access token
// Future<String?> getAccessToken() async {
//   return await _storage.read(key: _accessTokenKey);
// }

// // Ambil access token
// Future<String?> getToken() async {
//   final prefs = await SharedPreferences.getInstance();
//   return prefs.getString(_accessTokenKey);
// }

// // Ambil refresh token
// Future<String?> getRefreshToken() async {
//   return await _storage.read(key: _refreshTokenKey);
// }

// // Cek validitas access token
// Future<bool> isTokenValid() async {
//   final token = await getToken();
//   if (token == null) return false;

//   try {
//     return !JwtDecoder.isExpired(token);
//   } catch (e) {
//     return false;
//   }
// }

// // Hapus token
// Future<void> removeToken() async {
//   await _storage.delete(key: _accessTokenKey);
// }

// // Hapus refresh token
// Future<void> removeRefreshToken() async {
//   await _storage.delete(key: _refreshTokenKey);
// }

// // Cek apakah token sudah expired
// Future<bool> isTokenExpired() async {
//   final token = await getAccessToken();
//   if (token == null) return true;

//   try {
//     return JwtDecoder.isExpired(token);
//   } catch (e) {
//     return true;
//   }
// }

// // Decode token untuk mendapatkan payload
// Future<Map<String, dynamic>?> decodeToken() async {
//   final token = await getAccessToken();
//   if (token == null) return null;

//   try {
//     return JwtDecoder.decode(token);
//   } catch (e) {
//     return null;
//   }
// }

// // Refresh token
// Future<String?> newRefreshToken() async {
//   final refreshToken = await getRefreshToken();

//   if (refreshToken == null) return null;

//   try {
//     final response = await http.post(
//       Uri.parse('$devApiBaseUrl/refresh-token'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $refreshToken'
//       },
//     );

//     if (response.statusCode == 200) {
//       final jsonResponse = json.decode(response.body);

//       if (jsonResponse['status'] == 'success') {
//         final newToken = jsonResponse['data']['token'];
//         await saveAccessToken(newToken);
//         return newToken;
//       }
//     }

//     // Jika refresh token gagal, logout
//     await logout();
//     return null;
//   } catch (e) {
//     await logout();
//     return null;
//   }
// }

// // Logout dan hapus semua token
// Future<void> logout() async {
//   await removeToken();
//   await removeRefreshToken();
// }

// // Cek status autentikasi
// Future<bool> isAuthenticated() async {
//   final token = await getAccessToken();

//   if (token == null) return false;

//   try {
//     // Cek apakah token sudah expired
//     if (JwtDecoder.isExpired(token)) {
//       // Coba refresh token
//       final newToken = await newRefreshToken();
//       return newToken != null;
//     }
//     return true;
//   } catch (e) {
//     return false;
//   }
// }

// // Dapatkan user ID dari token
// Future<String?> getUserId() async {
//   final tokenPayload = await decodeToken();
//   return tokenPayload?['user_id'];
// }

// // Dapatkan roles dari token
// Future<List<String>> getUserRoles() async {
//   final tokenPayload = await decodeToken();

//   if (tokenPayload != null && tokenPayload.containsKey('roles')) {
//     return List<String>.from(tokenPayload['roles']);
//   }

//   return [];
// }
