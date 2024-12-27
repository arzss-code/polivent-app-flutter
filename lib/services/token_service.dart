import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import 'package:polivent_app/config/app_config.dart';
import 'package:polivent_app/screens/home/home.dart';
import 'package:polivent_app/screens/auth/login_screen.dart';

class TokenService {
  static final Dio _dio = Dio();
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // Kunci konstan untuk penyimpanan
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  // Method untuk memeriksa dan memvalidasi token
  static Future<bool> checkTokenValidity() async {
    try {
      debugPrint('🔍 Checking Token Validity');

      // Ambil token dari Secure Storage
      String? accessToken = await _secureStorage.read(key: _accessTokenKey);
      String? refreshToken = await _secureStorage.read(key: _refreshTokenKey);

      debugPrint('Access Token: ${accessToken ?? 'Not found'}');
      debugPrint('Refresh Token: ${refreshToken ?? 'Not found'}');

      // Cek apakah token tersedia
      if (accessToken == null || refreshToken == null) {
        debugPrint('❌ Tokens are missing');
        return false;
      }

      // Periksa apakah refresh token sudah expired
      if (JwtDecoder.isExpired(refreshToken)) {
        debugPrint('🕰️ Refresh Token Expired');

        // Coba refresh token
        final newTokens = await _refreshToken(refreshToken);

        if (newTokens != null) {
          debugPrint('🔄 Token refreshed successfully');
          return true;
        }

        debugPrint('❌ Token refresh failed');
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

  // Method untuk refresh token dengan penanganan error yang lebih baik
  static Future<Map<String, String>?> _refreshToken(String refreshToken) async {
    try {
      debugPrint('🔄 Attempting to refresh token');

      final response = await _dio.post(
        '$prodApiBaseUrl/auth',
        data: {
          'refresh_token': refreshToken,
        },
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      debugPrint('Refresh Token Response: ${response.statusCode}');
      debugPrint('Refresh Token Response Data: ${response.data}');

      if (response.statusCode == 200) {
        // Sesuaikan dengan struktur response API Anda
        final newAccessToken = response.data['data']['access_token'];
        final newRefreshToken =
            response.data['data']['refresh_token'] ?? refreshToken;

        // Simpan token baru di Secure Storage
        await _secureStorage.write(key: _accessTokenKey, value: newAccessToken);
        await _secureStorage.write(
            key: _refreshTokenKey, value: newRefreshToken);

        debugPrint('✅ New tokens saved successfully');

        return {
          'access_token': newAccessToken,
          'refresh_token': newRefreshToken
        };
      } else {
        debugPrint('❌ Token refresh failed: ${response.data}');
        return null;
      }
    } catch (e) {
      debugPrint('🚨 Refresh token error: $e');
      return null;
    }
  }

  // Validasi token dengan server
  static Future<bool> _validateTokenWithServer(String accessToken) async {
    try {
      debugPrint('🌐 Validating token with server');

      final response = await _dio.get(
        '$prodApiBaseUrl/auth',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      debugPrint('Server Validation Response: ${response.statusCode}');

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('🚨 Server token validation error: $e');
      return false;
    }
  }

  // Method untuk logout dengan pembersihan komprehensif
  static Future<void> logout() async {
    try {
      debugPrint('🚪 Logout initiated');

      // Hapus token dari Secure Storage
      await _secureStorage.deleteAll();

      // Optional: Panggil logout di server jika diperlukan
      try {
        await _dio.post('$prodApiBaseUrl/auth/logout');
      } catch (serverLogoutError) {
        debugPrint('🚨 Server logout error: $serverLogoutError');
      }

      debugPrint('✅ Logout completed');
    } catch (e) {
      debugPrint('🚨 Logout error: $e');
    }
  }

  // Method untuk menyimpan token
  static Future<void> saveTokens(
      {required String accessToken, required String refreshToken}) async {
    try {
      await _secureStorage.write(key: _accessTokenKey, value: accessToken);
      await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
      debugPrint('🔐 Tokens saved successfully in Secure Storage');
    } catch (e) {
      debugPrint('🚨 Error saving tokens: $e');
    }
  }

  // Method untuk mendapatkan token
  static Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _accessTokenKey);
  }

  static Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }
}
