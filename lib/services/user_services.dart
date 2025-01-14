import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:polivent_app/config/app_config.dart';
import 'package:polivent_app/services/auth_services.dart';
import 'package:polivent_app/services/data/user_model.dart';
import 'package:polivent_app/services/token_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  final Dio _dio = Dio();

  // Metode Update Profile dengan Dio
  Future<void> updateUserProfile({
    String? username,
    String? about,
    File? avatarFile,
  }) async {
    try {
      // Ambil user data untuk mendapatkan user_id
      AuthService authService = AuthService();
      User currentUser = await authService.getUserData();

      // Ambil access token
      String? accessToken = await TokenService.getAccessToken();

      if (accessToken == null) {
        throw DioException(
          requestOptions: RequestOptions(),
          response: Response(
              requestOptions: RequestOptions(),
              statusCode: 401,
              data: {'message': 'No access token available'}),
          type: DioExceptionType.badResponse,
        );
      }

      // Persiapkan FormData
      FormData formData = FormData.fromMap({
        'username': username ?? currentUser.username,
        'about': about ?? currentUser.about,
        'email': currentUser.email,
        'role_name': currentUser.roleName,
        'user_id': currentUser.userId.toString(),

        // Tambahkan avatar jika ada
        if (avatarFile != null)
          'avatar': await MultipartFile.fromFile(avatarFile.path,
              filename: 'avatar_${currentUser.userId}.jpg'),

        // Tambahkan interests jika ada
        if (currentUser.interests != null && currentUser.interests!.isNotEmpty)
          'interests': currentUser.interests
      });

      // Kirim request dengan Dio
      final response = await _dio.post(
        '$prodApiBaseUrl/users?user_id=${currentUser.userId}',
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      // Debug print
      debugPrint('Update Profile Response: ${response.statusCode}');
      debugPrint('Update Profile Body: ${response.data}');

      // Periksa response
      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ Profile updated successfully');
        return;
      } else {
        // Tangani error dari server
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException catch (e) {
      // Tangani error Dio
      _handleDioError(e);
    } catch (e) {
      debugPrint('🚨 Unexpected error updating profile: $e');
      throw Exception('Error updating profile: $e');
    }
  }

  // Metode Update Interests dengan Dio
  Future<void> updateUserInterests(List<String> interests) async {
    try {
      // Ambil user data untuk mendapatkan user_id
      AuthService authService = AuthService();
      User currentUser = await authService.getUserData();

      // Ambil access token
      String? accessToken = await TokenService.getAccessToken();

      if (accessToken == null) {
        throw DioException(
          requestOptions: RequestOptions(),
          response: Response(
              requestOptions: RequestOptions(),
              statusCode: 401,
              data: {'message': 'No access token available'}),
          type: DioExceptionType.badResponse,
        );
      }

      // Simpan ke SharedPreferences sebagai fallback
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('user_interests', interests);

      // Kirim request dengan Dio
      final response = await _dio.post(
        '$prodApiBaseUrl/users?user_id=${currentUser.userId}',
        data: {
          'interests': interests,
          'user_id': currentUser.userId,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      // Debug print
      debugPrint('Interests Update Response: ${response.statusCode}');
      debugPrint('Interests Update Body: ${response.data}');

      // Tidak perlu throw error jika update interests gagal
      return;
    } on DioException catch (e) {
      // Log error
      debugPrint('🚨 Error updating interests: ${e.message}');

      // Tetap simpan di lokal storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('user_interests', interests);
    } catch (e) {
      debugPrint('🚨 Unexpected error updating interests: $e');
    }
  }

  // Metode Update Avatar dengan Dio
  Future<void> updateUserAvatar(File avatarFile) async {
    try {
      // Ambil user data untuk mendapatkan user_id
      AuthService authService = AuthService();
      User currentUser = await authService.getUserData();

      // Ambil access token
      String? accessToken = await TokenService.getAccessToken();

      if (accessToken == null) {
        throw DioException(
          requestOptions: RequestOptions(),
          response: Response(
              requestOptions: RequestOptions(),
              statusCode: 401,
              data: {'message': 'No access token available'}),
          type: DioExceptionType.badResponse,
        );
      }

      // Debug: Cetak informasi file
      debugPrint('Avatar File Path: ${avatarFile.path}');
      debugPrint('Avatar File Size: ${await avatarFile.length()} bytes');

      // Persiapkan FormData
      FormData formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(avatarFile.path,
            filename: 'avatar_${currentUser.userId}.jpg'),
        'user_id': currentUser.userId.toString(),
        'username': currentUser.username,
        'email': currentUser.email,
        'role_name': currentUser.roleName,
      });

      // Kirim request dengan Dio
      final response = await _dio.post(
        '$prodApiBaseUrl/users?user_id=${currentUser.userId}',
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      // Debug: Cetak response
      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.data}');

      // Periksa response
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['status'] == 'success') {
          debugPrint('✅ Avatar updated successfully');
          return;
        } else {
          throw DioException(
            requestOptions: response.requestOptions,
            response: response,
            type: DioExceptionType.badResponse,
          );
        }
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException catch (e) {
      _handleDioError(e);
    } catch (e, stackTrace) {
      // Debug: Cetak error lengkap
      debugPrint('🚨 Unexpected error updating avatar: $e');
      debugPrint('Stacktrace: $stackTrace');

      throw Exception('Error updating avatar: $e');
    }
  }

  // Metode untuk menangani error Dio
  void _handleDioError(DioException e) {
    String errorMessage = 'Terjadi kesalahan tidak terduga';

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        errorMessage = 'Waktu koneksi habis. Silakan coba lagi.';
        break;
      case DioExceptionType.sendTimeout:
        errorMessage = 'Waktu pengiriman habis. Silakan coba lagi.';
        break;
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Waktu penerimaan habis. Silakan coba lagi.';
        break;
      case DioExceptionType.badResponse:
        errorMessage = e.response?.data['message'] ?? 'Kesalahan dari server.';
        break;
      case DioExceptionType.cancel:
        errorMessage = 'Permintaan dibatalkan.';
        break;
      case DioExceptionType.unknown:
        errorMessage = 'Kesalahan jaringan atau server tidak dapat dijangkau.';
        break;
      case DioExceptionType.badCertificate:
        errorMessage =
            'Sertifikat tidak valid. Silakan periksa sertifikat Anda.';
        break;
      case DioExceptionType.connectionError:
        errorMessage =
            'Terjadi kesalahan koneksi. Silakan periksa koneksi internet Anda.';
        break;
    }

    debugPrint('🚨 Dio Error: $errorMessage');
    throw Exception(errorMessage);
  }
}

// Utility class untuk menyimpan preferensi pengguna
class UserPreferences {
  static Future<void> saveUserRoles(List<dynamic> roles) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        'user_roles', roles.map((role) => role.toString()).toList());
  }

  static Future<List<String>> getUserRoles() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('user_roles') ?? [];
  }

  // Method untuk mengecek apakah user adalah Member
  static Future<bool> isMember() async {
    final roles = await getUserRoles();
    return roles.contains('Member');
  }

  // Method untuk logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_roles');
    await TokenService.logout();
  }
}
