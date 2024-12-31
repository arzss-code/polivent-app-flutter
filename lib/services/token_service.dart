// import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:dio/dio.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';

// import 'package:polivent_app/config/app_config.dart';

// class TokenService {
//   static final Dio _dio = Dio();
//   static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

//   // Kunci konstan untuk penyimpanan
//   static const String _accessTokenKey = 'access_token';
//   static const String _refreshTokenKey = 'refresh_token';

//   // Method untuk memeriksa dan memvalidasi token
//   static Future<bool> checkTokenValidity() async {
//     try {
//       debugPrint('🔍 Checking Token Validity');

//       // Ambil token dari Secure Storage
//       String? accessToken = await getAccessToken();
//       String? refreshToken = await getRefreshToken();

//       debugPrint('Access Token: ${accessToken ?? 'Not found'}');
//       debugPrint('Refresh Token: ${refreshToken ?? 'Not found'}');

//       // Cek apakah token tersedia
//       if (accessToken == null || refreshToken == null) {
//         debugPrint('❌ Tokens are missing');
//         return false;
//       }

//       // Validasi token berdasarkan expiration
//       final isAccessTokenExpired = _isTokenExpired(accessToken);
//       final isRefreshTokenExpired = _isTokenExpired(refreshToken);

//       debugPrint('Access Token Expired: $isAccessTokenExpired');
//       debugPrint('Refresh Token Expired: $isRefreshTokenExpired');

//       // Jika refresh token sudah expired, kembalikan false
//       if (isRefreshTokenExpired) {
//         debugPrint('🕰️ Refresh Token Expired');
//         return false;
//       }

//       // Validasi tambahan dengan melakukan ping ke server
//       bool serverValidation = await _validateTokenWithServer(accessToken);

//       debugPrint('🌐 Server Token Validation: $serverValidation');
//       return serverValidation;
//     } catch (e) {
//       debugPrint('🚨 Token validation error: $e');
//       return false;
//     }
//   }

//   // Method untuk memeriksa apakah token sudah expired
//   static bool _isTokenExpired(String token) {
//     try {
//       final decodedToken = JwtDecoder.decode(token);
//       final expirationTime = decodedToken['exp'] as int;
//       final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;

//       return expirationTime < currentTime;
//     } catch (e) {
//       debugPrint('🚨 Token expiration check error: $e');
//       return true;
//     }
//   }

//   static Future<bool> _validateTokenWithServer(String accessToken) async {
//     try {
//       debugPrint('🌐 Validating token with server');

//       final response = await _dio.get(
//         '$prodApiBaseUrl/auth',
//         options: Options(
//           headers: {'Authorization': 'Bearer $accessToken'},
//           validateStatus: (status) => status != null && status < 500,
//         ),
//       );

//       debugPrint('Server Validation Response: ${response.statusCode}');

//       if (response.statusCode == 200) {
//         return true;
//       } else if (response.statusCode == 401) {
//         debugPrint('❌ Token is invalid or expired');
//         return false;
//       } else {
//         debugPrint('❌ Unexpected response status: ${response.statusCode}');
//         return false;
//       }
//     } catch (e) {
//       debugPrint('🚨 Server token validation error: $e');
//       return false;
//     }
//   }

//   // Method untuk logout dengan pembersihan komprehensif
//   static Future<void> logout() async {
//     try {
//       debugPrint('🚪 Logout initiated');

//       // Hapus token dari Secure Storage
//       await _secureStorage.deleteAll();

//       debugPrint('✅ Logout completed');
//     } catch (e) {
//       debugPrint('🚨 Logout error: $e');
//     }
//   }

//   // Method untuk menyimpan token
//   static Future<void> saveTokens(
//       {required String accessToken, required String refreshToken}) async {
//     try {
//       await _secureStorage.write(key: _accessTokenKey, value: accessToken);
//       await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
//       debugPrint('🔐 Tokens saved successfully in Secure Storage');

//       // Log token info
//       _logTokenInfo(accessToken);
//     } catch (e) {
//       debugPrint('🚨 Error saving tokens: $e');
//     }
//   }

//   // Method untuk mendapatkan token
//   static Future<String?> getAccessToken() async {
//     return await _secureStorage.read(key: _accessTokenKey);
//   }

//   static Future<String?> getRefreshToken() async {
//     return await _secureStorage.read(key: _refreshTokenKey);
//   }

//   // Metode untuk mendekode token
//   static Map<String, dynamic>? decodeToken(String token) {
//     try {
//       return JwtDecoder.decode(token);
//     } catch (e) {
//       debugPrint('🚨 Token decoding error: $e');
//       return null;
//     }
//   }

//   // Metode untuk mendapatkan User ID dari token
//   static Future<int?> getUserIdFromToken() async {
//     final accessToken = await getAccessToken();
//     if (accessToken != null) {
//       final decodedToken = decodeToken(accessToken);
//       return decodedToken?['user_id'];
//     }
//     return null;
//   }

//   // Logging informasi token
//   static void _logTokenInfo(String token) {
//     try {
//       final decoded = decodeToken(token);
//       if (decoded != null) {
//         debugPrint('Token Info:');
//         debugPrint('User  ID: ${decoded['user_id']}');
//         debugPrint('Roles: ${decoded['roles']}');
//         debugPrint(
//             'Issued At: ${DateTime.fromMillisecondsSinceEpoch(decoded['iat'] * 1000)}');
//         debugPrint(
//             'Expiration: ${DateTime.fromMillisecondsSinceEpoch(decoded['exp'] * 1000)}');
//       }
//     } catch (e) {
//       debugPrint('🚨 Token info logging error: $e');
//     }
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:polivent_app/config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static late SharedPreferences _prefs;

  // Inisialisasi SharedPreferences
  static Future<void> initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Kunci konstan untuk penyimpanan
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  static bool isValidTokenStructure(String token) {
    try {
      final parts = token.split('.');
      return parts.length == 3 &&
          parts[0].isNotEmpty &&
          parts[1].isNotEmpty &&
          parts[2].isNotEmpty;
    } catch (e) {
      debugPrint('🚨 Token structure check error: $e');
      return false;
    }
  }

// Method untuk menyimpan token di SharedPreferences
  static Future<void> saveTokensToSharedPrefs({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      await _prefs.setString(_accessTokenKey, accessToken);
      await _prefs.setString(_refreshTokenKey, refreshToken);
      debugPrint('💾 Tokens saved successfully in SharedPreferences');
    } catch (e) {
      debugPrint('🚨 Error saving tokens to SharedPreferences: $e');
    }
  }

  // Method untuk memeriksa dan memvalidasi token
  static Future<bool> checkTokenValidity() async {
    try {
      debugPrint('🔍 Checking Token Validity');

      // Ambil token dari Secure Storage
      String? accessToken = await getAccessToken();
      String? refreshToken = await getRefreshToken();

      debugPrint('Access Token: ${accessToken ?? 'Not found'}');
      debugPrint('Refresh Token: ${refreshToken ?? 'Not found'}');

      // Cek apakah token tersedia
      if (accessToken == null || refreshToken == null) {
        debugPrint('❌ Tokens are missing');
        return false;
      }

      // Validasi token berdasarkan expiration
      final isAccessTokenExpired = _isTokenExpired(accessToken);
      final isRefreshTokenExpired = _isTokenExpired(refreshToken);

      debugPrint('Access Token Expired: $isAccessTokenExpired');
      debugPrint('Refresh Token Expired: $isRefreshTokenExpired');

      // Jika refresh token sudah expired, kembalikan false
      if (isRefreshTokenExpired) {
        debugPrint('🕰️ Refresh Token Expired');
        return false;
      }

      // Validasi tambahan dengan melakukan ping ke server
      bool serverValidation = await _validateTokenWithServer(accessToken);

      debugPrint('🌐 Server Token Validation: $serverValidation');
      return serverValidation;
    } catch (e) {
      debugPrint('🚨 Token validation error: $e');
      return false;
    }
  }

  // Method untuk memeriksa apakah token sudah expired
  static bool _isTokenExpired(String token) {
    try {
      final decodedToken = JwtDecoder.decode(token);
      final expirationTime = decodedToken['exp'] as int;
      final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      return expirationTime < currentTime;
    } catch (e) {
      debugPrint('🚨 Token expiration check error: $e');
      return true;
    }
  }

  // Validasi token dengan server
  static Future<bool> _validateTokenWithServer(String accessToken) async {
    try {
      debugPrint('🌐 Validating token with server');

      final response = await http.get(
        Uri.parse('$prodApiBaseUrl/auth'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      debugPrint('Server Validation Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        debugPrint('❌ Token is invalid or expired');
        return false;
      } else {
        debugPrint('❌ Unexpected response status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('🚨 Server token validation error: $e');
      return false;
    }
  }

  // Method untuk logout dengan pembersihan komprehensif
  static Future<void> logout() async {
    try {
      debugPrint('🚪 Logout initiated');

      // Hapus access token dan refresh token dari Secure Storage
      await _secureStorage.delete(key: _accessTokenKey);
      await _secureStorage.delete(key: _refreshTokenKey);

      debugPrint('✅ Logout completed');
    } catch (e) {
      debugPrint('🚨 Logout error: $e');
    }
  }

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      debugPrint('📦 Saving Tokens');
      debugPrint(
          'Access Token Structure: ${accessToken.split('.').length} segments');
      debugPrint(
          'Refresh Token Structure: ${refreshToken.split('.').length} segments');

      // Simpan di Secure Storage
      await _secureStorage.write(key: _accessTokenKey, value: accessToken);
      await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);

      // Simpan di SharedPreferences
      await saveTokensToSharedPrefs(
          accessToken: accessToken, refreshToken: refreshToken);

      debugPrint('🔐 Tokens saved successfully');

      // Log token info
      _logTokenInfo(accessToken);
    } catch (e) {
      debugPrint('🚨 Error saving tokens: $e');
    }
  }

  // // Method untuk mendapatkan token (prioritas Secure Storage)
  // static Future<String?> getAccessToken() async {
  //   // Coba ambil dari Secure Storage terlebih dahulu
  //   String? secureToken = await _secureStorage.read(key: _accessTokenKey);

  //   // Jika tidak ada, coba dari SharedPreferences
  //   return secureToken ?? getAccessTokenFromSharedPrefs();
  // }

  // static Future<String?> getRefreshToken() async {
  //   // Coba ambil dari Secure Storage terlebih dahulu
  //   String? secureToken = await _secureStorage.read(key: _refreshTokenKey);

  //   // Jika tidak ada, coba dari SharedPreferences
  //   return secureToken ?? getRefreshTokenFromSharedPrefs();
  // }

  // Method untuk mendapatkan token dari SharedPreferences
  static String? getAccessTokenFromSharedPrefs() {
    return _prefs.getString(_accessTokenKey);
  }

  static String? getRefreshTokenFromSharedPrefs() {
    return _prefs.getString(_refreshTokenKey);
  }

  static Future<String?> getAccessToken() async {
    try {
      String? token = await _secureStorage.read(key: _accessTokenKey);
      debugPrint('🔑 Retrieved Access Token: $token');

      // Tambahkan validasi struktur token
      if (token != null && token.split('.').length == 3) {
        return token;
      } else {
        debugPrint('❌ Invalid token structure');
        return null;
      }
    } catch (e) {
      debugPrint('🚨 Error retrieving access token: $e');
      return null;
    }
  }

  static Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  // Metode untuk mendekode token
  static Map<String, dynamic>? decodeToken(String token) {
    try {
      return JwtDecoder.decode(token);
    } catch (e) {
      debugPrint('🚨 Token decoding error: $e');
      return null;
    }
  }

  // Metode untuk mendapatkan User ID dari token
  static Future<int?> getUserIdFromToken() async {
    final accessToken = await getAccessToken();
    if (accessToken != null) {
      final decodedToken = decodeToken(accessToken);
      return decodedToken?['user_id'];
    }
    return null;
  }

  // Method untuk menghapus token dari Secure Storage dan SharedPreferences
  static Future<void> removeTokens() async {
    try {
      debugPrint('🗑️ Removing tokens from storage');

      // Hapus dari Secure Storage
      await _secureStorage.delete(key: _accessTokenKey);
      await _secureStorage.delete(key: _refreshTokenKey);

      // Hapus dari SharedPreferences
      await _prefs.remove(_accessTokenKey);
      await _prefs.remove(_refreshTokenKey);

      debugPrint('✅ Tokens removed successfully');
    } catch (e) {
      debugPrint('🚨 Error removing tokens: $e');
    }
  }

  // Logging informasi token
  static void _logTokenInfo(String token) {
    try {
      final decoded = decodeToken(token);
      if (decoded != null) {
        debugPrint('Token Info:');
        debugPrint('User  ID: ${decoded['user_id']}');
        debugPrint('Roles: ${decoded['roles']}');
        debugPrint(
            'Issued At: ${DateTime.fromMillisecondsSinceEpoch(decoded['iat'] * 1000)}');
        debugPrint(
            'Expiration: ${DateTime.fromMillisecondsSinceEpoch(decoded['exp'] * 1000)}');
      }
    } catch (e) {
      debugPrint('🚨 Token info logging error: $e');
    }
  }
}
