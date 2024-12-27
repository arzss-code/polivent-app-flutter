import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart';
import 'package:polivent_app/config/app_config.dart';
import 'package:polivent_app/services/data/user_model.dart';
import 'package:polivent_app/models/ui_colors.dart';
import 'package:polivent_app/screens/auth/login_screen.dart';
import 'package:polivent_app/services/token_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  final Dio _dio = Dio();
  final _storage = const FlutterSecureStorage();

  // Konstruktor dengan konfigurasi Dio
  AuthService() {
    _setupDioInterceptors();
  }

  // Setup Dio Interceptors
  void _setupDioInterceptors() {
    _dio.options.baseUrl = devApiBaseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Tambahkan token ke header jika tersedia
        final token = await _storage.read(key: 'access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        debugPrint('🚀 Request: ${options.method} ${options.path}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint('✅ Response: ${response.statusCode} ${response.data}');
        return handler.next(response);
      },
      onError: (DioException e, handler) async {
        debugPrint('❌ Error: ${e.type} ${e.message}');

        // Handle token expired
        if (e.response?.statusCode == 401) {
          try {
            await _refreshToken();
            // Ulangi request terakhir
            return handler.resolve(await _dio.fetch(e.requestOptions));
          } catch (refreshError) {
            // Logout jika refresh token gagal
            debugPrint('🔒 Token refresh failed');
            return handler.next(e);
          }
        }
        return handler.next(e);
      },
    ));
  }

  // Login dengan Dio
  Future<void> login(String email, String password) async {
    try {
      debugPrint('🔐 Attempting login for: $email');

      final response = await _dio.post('/auth', data: {
        'email': email,
        'password': password,
      });

      if (response.data['status'] == 'success') {
        final tokens = response.data['data'];
        await _saveTokens(tokens['access_token'], tokens['refresh_token']);
        debugPrint('✅ Login successful');
      } else {
        throw DioException(
          requestOptions: RequestOptions(),
          response: response,
          message: response.data['message'] ?? 'Login failed',
        );
      }
    } on DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      debugPrint('🚨 Unexpected login error: $e');
      rethrow;
    }
  }

  // Refresh Token
  Future<String?> _refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');

      if (refreshToken == null) {
        throw DioException(
            requestOptions: RequestOptions(),
            message: 'No refresh token available');
      }

      final response = await _dio
          .post('/auth/refresh', data: {'refresh_token': refreshToken});

      if (response.data['status'] == 'success') {
        final newTokens = response.data['data'];
        await _saveTokens(
            newTokens['access_token'], newTokens['refresh_token']);
        return newTokens['access_token'];
      } else {
        throw DioException(
            requestOptions: RequestOptions(), message: 'Token refresh failed');
      }
    } on DioException catch (e) {
      debugPrint('🔄 Token refresh error: ${e.message}');
      await logout(context as BuildContext); // Force logout on refresh failure
      rethrow;
    }
  }

  // Simpan Token
  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    try {
      await _storage.write(key: 'access_token', value: accessToken);
      await _storage.write(key: 'refresh_token', value: refreshToken);
      debugPrint('🔐 Tokens saved successfully');
    } catch (e) {
      debugPrint('🚨 Error saving tokens: $e');
    }
  }

  // Get User Data
  Future<User> getUserData() async {
    try {
      final response = await _dio.get('/auth');

      if (response.data['status'] == 'success') {
        return User.fromJson(response.data['data']);
      } else {
        throw DioException(
            requestOptions: RequestOptions(),
            message: response.data['message'] ?? 'Failed to fetch user data');
      }
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  Future<void> logout(BuildContext context) async {
    // bool isDialogShown = false;
    try {
      debugPrint('🚪 Logout initiated');

      // Hapus token dari server (opsional)
      await _dio.delete('/auth');

      // Hapus token lokal
      await _storage.deleteAll();

      // Clear shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('notifications');

      debugPrint('✅ Logout completed');

      // Metode 1: pushAndRemoveUntil
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) =>
            false, // Ini akan menghapus semua route sebelumnya
      );

      // Atau Metode 2: pushNamedAndRemoveUntil (jika Anda menggunakan named routes)
      // Navigator.of(context).pushNamedAndRemoveUntil(
      //   '/login',
      //   (Route<dynamic> route) => false
      // );
    } catch (e) {
      debugPrint('🚨 Logout error: $e');
    }
  }

  // Handler Error Dio
  void _handleDioError(DioException e) {
    String errorMessage = 'Terjadi kesalahan tidak terduga';

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        errorMessage = 'Koneksi timeout. Periksa koneksi internet Anda.';
        break;
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        switch (statusCode) {
          case 400:
            errorMessage = 'Permintaan tidak valid';
            break;
          case 401:
            errorMessage = 'Otentikasi gagal. Silakan login ulang.';
            break;
          case 403:
            errorMessage = 'Akses ditolak';
            break;
          case 404:
            errorMessage = 'Sumber tidak ditemukan';
            break;
          case 500:
            errorMessage = 'Kesalahan server internal';
            break;
        }
        break;
      case DioExceptionType.cancel:
        errorMessage = 'Permintaan dibatalkan';
        break;
      case DioExceptionType.unknown:
        if (e.error is SocketException) {
          errorMessage = 'Tidak ada koneksi internet';
        }
        break;
      case DioExceptionType.badCertificate:
        errorMessage = 'Sertifikat tidak valid';
        break;
      case DioExceptionType.connectionError:
        errorMessage = 'Terjadi kesalahan koneksi';
    }

    debugPrint('🚨 DioError: ${e.type} - $errorMessage');
    throw Exception(errorMessage);
  }

// Metode tambahan untuk clear data dengan debug print
  Future<void> _clearAllData(BuildContext context) async {
    try {
      debugPrint('🧹 Starting data clearing process');

      // Clear token dari secure storage
      await _storage.deleteAll();
      debugPrint('🔐 Tokens cleared from secure storage');

      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      debugPrint('💾 SharedPreferences cleared');

      // Navigasi ke login screen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );

      debugPrint('🚪 Navigated to login screen');
    } catch (e) {
      debugPrint('🚨 Error during data clearing: $e');
      // Fallback navigasi
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  // Future<void> updateUserProfile({
  //   String? username,
  //   String? about,
  //   File? avatarFile,
  // }) async {
  //   try {
  //     // Ambil user data untuk mendapatkan user_id
  //     User currentUser = await getUserData();

  //     String? accessToken = await TokenService.getAccessToken();

  //     if (accessToken == null) {
  //       throw Exception('No access token available');
  //     }

  //     // Buat multipart request
  //     var request = http.MultipartRequest('POST',
  //         Uri.parse('$prodApiBaseUrl/users?user_id=${currentUser.userId}'));

  //     // Tambahkan headers
  //     request.headers['Authorization'] = 'Bearer $accessToken';

  //     // Tambahkan field-field yang diperlukan
  //     request.fields['username'] = username ?? currentUser.username;
  //     request.fields['about'] = about ?? currentUser.about;
  //     request.fields['email'] = currentUser.email;
  //     request.fields['role_name'] = currentUser.roleName;
  //     request.fields['user_id'] = currentUser.userId.toString();

  //     // Tambahkan avatar jika ada
  //     if (avatarFile != null) {
  //       request.files.add(await http.MultipartFile.fromPath(
  //           'avatar', avatarFile.path,
  //           filename: 'avatar.jpg'));
  //     }

  //     // Tambahkan interests jika ada
  //     if (currentUser.interests != null && currentUser.interests!.isNotEmpty) {
  //       request.fields['interests'] = jsonEncode(currentUser.interests);
  //     }

  //     // Kirim request
  //     var response = await request.send();

  //     // Baca response
  //     var responseBody = await response.stream.bytesToString();

  //     // Debug print
  //     print('Response Status Code: ${response.statusCode}');
  //     print('Response Body: $responseBody');

  //     // Periksa response
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       // Anda bisa menambahkan pengecekan status di sini jika diperlukan
  //       return;
  //     } else {
  //       throw Exception(
  //           'Failed to update profile. Status code: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error updating profile: $e');
  //     throw Exception('Error updating profile: $e');
  //   }
  // }

  // Future<void> updateUserInterests(List<String> interests) async {
  //   try {
  //     // Ambil user data untuk mendapatkan user_id
  //     User currentUser = await getUserData();

  //     String? accessToken = await TokenService.getAccessToken();

  //     if (accessToken == null) {
  //       throw Exception('No access token available');
  //     }

  //     // Simpan ke SharedPreferences sebagai fallback
  //     final prefs = await SharedPreferences.getInstance();
  //     await prefs.setStringList('user_interests', interests);

  //     // Lakukan request update jika memungkinkan
  //     final response = await http.post(
  //       Uri.parse('$prodApiBaseUrl/users?user_id=${currentUser.userId}'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $accessToken',
  //       },
  //       body: jsonEncode({
  //         'interests': interests,
  //         'user_id': currentUser.userId,
  //       }),
  //     );

  //     // Cetak response untuk debugging
  //     print('Interests Update Response: ${response.body}');

  //     // Tidak perlu throw error jika update interests gagal
  //     return;
  //   } catch (e) {
  //     print('Error updating interests: $e');
  //     // Tetap simpan di lokal storage
  //     final prefs = await SharedPreferences.getInstance();
  //     await prefs.setStringList('user_interests', interests);
  //   }
  // }

  // Future<void> updateUserAvatar(File avatarFile) async {
  //   try {
  //     // Ambil user data untuk mendapatkan user_id
  //     User currentUser = await getUserData();

  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     String? accessToken = prefs.getString('access_token');

  //     if (accessToken == null) {
  //       throw Exception('No access token available');
  //     }

  //     // Gunakan multipart request untuk upload file
  //     var request = http.MultipartRequest(
  //         'POST', // Sesuaikan dengan metode yang digunakan di backend
  //         Uri.parse('$prodApiBaseUrl/users?user_id=${currentUser.userId}'));

  //     // Tambahkan headers
  //     request.headers['Authorization'] = 'Bearer $accessToken';

  //     // Debug: Cetak informasi file
  //     print('Avatar File Path: ${avatarFile.path}');
  //     print('Avatar File Size: ${await avatarFile.length()} bytes');

  //     // Tambahkan file
  //     request.files.add(await http.MultipartFile.fromPath(
  //         'avatar', avatarFile.path,
  //         filename: 'avatar_${currentUser.userId}.jpg'));

  //     // Tambahkan field tambahan yang mungkin diperlukan
  //     request.fields['user_id'] = currentUser.userId.toString();
  //     request.fields['username'] = currentUser.username;
  //     request.fields['email'] = currentUser.email;
  //     request.fields['role_name'] = currentUser.roleName;

  //     // Kirim request
  //     var response = await request.send();

  //     // Baca response
  //     var responseBody = await response.stream.bytesToString();

  //     // Debug: Cetak response
  //     print('Response Status Code: ${response.statusCode}');
  //     print('Response Body: $responseBody');

  //     // Parsing response
  //     var jsonData = jsonDecode(responseBody);

  //     // Periksa response
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       if (jsonData['status'] == 'success') {
  //         print('Avatar updated successfully');
  //         return;
  //       } else {
  //         throw Exception(jsonData['message'] ?? 'Failed to update avatar');
  //       }
  //     } else {
  //       throw Exception(
  //           'Failed to update avatar. Status code: ${response.statusCode}. Body: $responseBody');
  //     }
  //   } catch (e, stackTrace) {
  //     // Debug: Cetak error lengkap
  //     print('Error updating avatar: $e');
  //     print('Stacktrace: $stackTrace');

  //     throw Exception('Error updating avatar: $e');
  //   }
  // }

// Metode untuk menampilkan error dan pop dialog
  void _showErrorAndPop(BuildContext context, String message) {
    // Tutup loading dialog jika masih terbuka
    Navigator.of(context, rootNavigator: true).pop();

    // Tampilkan pesan error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
