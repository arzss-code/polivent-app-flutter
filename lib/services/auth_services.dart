import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:polivent_app/config/app_config.dart';
import 'package:polivent_app/services/data/user_model.dart';
import 'package:polivent_app/models/ui_colors.dart';
import 'package:polivent_app/screens/auth/login_screen.dart';
import 'package:polivent_app/services/token_util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final Dio _dio = Dio();
  final _storage = const FlutterSecureStorage();

  bool rememberMe = false;

  static const _TokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  Future<void> login(String email, String password) async {
    try {
      debugPrint('Attempting to log in with email: $email');

      final response = await http.post(
        Uri.parse('$devApiBaseUrl/auth'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      // Cek status code dari response
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        debugPrint('Response JSON: $jsonData');

        if (jsonData['status'] == 'success') {
          final accessToken = jsonData['data']['access_token'];
          final refreshToken = jsonData['data']['refresh_token'];

          debugPrint('Access Token: $accessToken');
          debugPrint('Refresh Token: $refreshToken');

          await _saveToken(accessToken, refreshToken);
        } else {
          // Tangani kesalahan yang dikembalikan oleh server
          throw Exception(
              jsonData['message'] ?? 'Login failed. Please try again.');
        }
      } else {
        // Tangani kesalahan berdasarkan status code
        switch (response.statusCode) {
          case 400:
            throw Exception('Invalid request. Please check your input.');
          case 401:
            throw Exception(
                'Unauthorized. Please check your email and password.');
          case 500:
            throw Exception('Server error. Please try again later.');
          default:
            throw Exception(
                'Login failed. Please check your connection and try again.');
        }
      }
    } catch (e) {
      // Tangani kesalahan jaringan
      debugPrint('Error occurred: $e');
      throw Exception(
          'Login failed. Please check your internet connection and try again.');
    }
  }

  Future<void> _saveToken(String accessToken, String refreshToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
  }

  Future<User> getUserData() async {
    try {
      // Ambil access token dari SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? refreshToken = prefs.getString('refresh_token');

      refreshToken ??= prefs.getString('refresh_token');

      // Lakukan request get user data
      final response = await http.get(
        Uri.parse('$devApiBaseUrl/auth'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $refreshToken',
        },
      );

      // Cek status code dari response
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData['status'] == 'success') {
          return User.fromJson(jsonData['data']);
        } else {
          throw Exception(jsonData['message'] ?? 'Failed to fetch user data');
        }
      } else if (response.statusCode == 401) {
        // Token expired, coba refresh token
        await newRefreshToken();

        // Ulangi request setelah refresh token
        return getUserData();
      } else {
        // Tangani kesalahan berdasarkan status code
        throw Exception(
            'Failed to fetch user data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Tangani kesalahan jaringan atau parsing
      throw Exception('Failed to fetch user data: $e');
    }
  }

  // Check Login (GET)
  Future<User?> checkLogin() async {
    try {
      final response = await _dio.get('$prodApiBaseUrl/auth',
          options: Options(headers: {
            'Authorization':
                'Bearer ${await _storage.read(key: _refreshTokenKey)}'
          }));

      if (response.data['status'] == 'success') {
        return User.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> logout(BuildContext context) async {
    // Tambahkan flag untuk mengontrol proses
    bool isDialogShown = false;

    try {
      // Tampilkan loading indicator dengan flag
      isDialogShown = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(UIColor.primaryColor),
            ),
          );
        },
      );

      // Ambil token dari secure storage dengan penanganan error yang lebih baik
      final accessToken = await _storage.read(key: 'access_token') ?? '';
      final refreshToken = await _storage.read(key: 'refresh_token') ?? '';

      // Jika kedua token kosong, langsung clear data
      if (accessToken.isEmpty && refreshToken.isEmpty) {
        await _clearAllData(context);
        return;
      }

      try {
        // Kirim request logout ke backend
        final response = await http.delete(
          Uri.parse('$devApiBaseUrl/auth'),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw TimeoutException('Logout request timed out');
          },
        );

        // Cek status response
        if (response.statusCode == 200 || response.statusCode == 401) {
          // Berhasil logout atau token sudah tidak valid
          await _clearAllData(context);
        } else {
          // Gagal logout
          throw Exception('Logout failed: ${response.body}');
        }
      } on TimeoutException {
        _showErrorAndPop(context, 'Request timed out. Please try again.');
      } on SocketException {
        _showErrorAndPop(
            context, 'Network error. Please check your connection.');
      } catch (e) {
        _showErrorAndPop(
            context, 'An unexpected error occurred: ${e.toString()}');
      }
    } catch (e) {
      // Log error untuk debugging
      print('Logout error: $e');

      // Coba clear data walau error
      try {
        await _clearAllData(context);
      } catch (clearError) {
        print('Error clearing data: $clearError');
      }
    } finally {
      // Tutup dialog hanya jika sebelumnya dibuka
      if (isDialogShown && Navigator.of(context).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
  }

// Metode clear data dengan error handling tambahan
  Future<void> _clearAllData(BuildContext context) async {
    try {
      //Hapus semua data dari secure storage
      await _storage.deleteAll();

      // Hapus token dari shared preferences jika ada
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      // await prefs.remove('password');

      // Tutup loading dialog jika masih terbuka
      if (Navigator.of(context).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      // Navigasi ke login dan hapus semua rute
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      print('Critical error during logout: $e');

      // Force navigation even if clear data fails
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  Future<void> updateUserProfile({
    String? username,
    String? about,
    File? avatarFile,
  }) async {
    try {
      // Ambil user data untuk mendapatkan user_id
      User currentUser = await getUserData();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('access_token');

      if (accessToken == null) {
        throw Exception('No access token available');
      }

      // Buat multipart request
      var request = http.MultipartRequest('POST',
          Uri.parse('$prodApiBaseUrl/users?user_id=${currentUser.userId}'));

      // Tambahkan headers
      request.headers['Authorization'] = 'Bearer $accessToken';

      // Tambahkan field-field yang diperlukan
      request.fields['username'] = username ?? currentUser.username;
      request.fields['about'] = about ?? currentUser.about;
      request.fields['email'] = currentUser.email;
      request.fields['role_name'] = currentUser.roleName;
      request.fields['user_id'] = currentUser.userId.toString();

      // Tambahkan avatar jika ada
      if (avatarFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
            'avatar', avatarFile.path,
            filename: 'avatar.jpg'));
      }

      // Tambahkan interests jika ada
      if (currentUser.interests != null && currentUser.interests!.isNotEmpty) {
        request.fields['interests'] = jsonEncode(currentUser.interests);
      }

      // Kirim request
      var response = await request.send();

      // Baca response
      var responseBody = await response.stream.bytesToString();

      // Debug print
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: $responseBody');

      // Periksa response
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Anda bisa menambahkan pengecekan status di sini jika diperlukan
        return;
      } else {
        throw Exception(
            'Failed to update profile. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating profile: $e');
      throw Exception('Error updating profile: $e');
    }
  }

  Future<void> updateUserInterests(List<String> interests) async {
    try {
      // Ambil user data untuk mendapatkan user_id
      User currentUser = await getUserData();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('access_token');

      if (accessToken == null) {
        throw Exception('No access token available');
      }

      // Simpan ke SharedPreferences sebagai fallback
      await prefs.setStringList('user_interests', interests);

      // Lakukan request update jika memungkinkan
      final response = await http.post(
        Uri.parse('$prodApiBaseUrl/users?user_id=${currentUser.userId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'interests': interests,
          'user_id': currentUser.userId,
        }),
      );

      // Cetak response untuk debugging
      print('Interests Update Response: ${response.body}');

      // Tidak perlu throw error jika update interests gagal
      return;
    } catch (e) {
      print('Error updating interests: $e');
      // Tetap simpan di lokal storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('user_interests', interests);
    }
  }

  Future<void> updateUserAvatar(File avatarFile) async {
    try {
      // Ambil user data untuk mendapatkan user_id
      User currentUser = await getUserData();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('access_token');

      if (accessToken == null) {
        throw Exception('No access token available');
      }

      // Gunakan multipart request untuk upload file
      var request = http.MultipartRequest(
          'POST', // Sesuaikan dengan metode yang digunakan di backend
          Uri.parse('$prodApiBaseUrl/users?user_id=${currentUser.userId}'));

      // Tambahkan headers
      request.headers['Authorization'] = 'Bearer $accessToken';

      // Debug: Cetak informasi file
      print('Avatar File Path: ${avatarFile.path}');
      print('Avatar File Size: ${await avatarFile.length()} bytes');

      // Tambahkan file
      request.files.add(await http.MultipartFile.fromPath(
          'avatar', avatarFile.path,
          filename: 'avatar_${currentUser.userId}.jpg'));

      // Tambahkan field tambahan yang mungkin diperlukan
      request.fields['user_id'] = currentUser.userId.toString();
      request.fields['username'] = currentUser.username;
      request.fields['email'] = currentUser.email;
      request.fields['role_name'] = currentUser.roleName;

      // Kirim request
      var response = await request.send();

      // Baca response
      var responseBody = await response.stream.bytesToString();

      // Debug: Cetak response
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: $responseBody');

      // Parsing response
      var jsonData = jsonDecode(responseBody);

      // Periksa response
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (jsonData['status'] == 'success') {
          print('Avatar updated successfully');
          return;
        } else {
          throw Exception(jsonData['message'] ?? 'Failed to update avatar');
        }
      } else {
        throw Exception(
            'Failed to update avatar. Status code: ${response.statusCode}. Body: $responseBody');
      }
    } catch (e, stackTrace) {
      // Debug: Cetak error lengkap
      print('Error updating avatar: $e');
      print('Stacktrace: $stackTrace');

      throw Exception('Error updating avatar: $e');
    }
  }

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

  // // Dio Interceptor untuk Token Management
  // Dio getDioWithInterceptors() {
  //   _dio.interceptors.clear();

  //   _dio.interceptors
  //       .add(InterceptorsWrapper(onRequest: (options, handler) async {
  //     final token = await _storage.read(key: _accessTokenKey);
  //     if (token != null) {
  //       options.headers['Authorization'] = 'Bearer $token';
  //     }
  //     return handler.next(options);
  //   }, onError: (DioException e, handler) async {
  //     if (e.response?.statusCode == 401) {
  //       final newToken = await newRefreshToken();
  //       if (newToken != null) {
  //         e.requestOptions.headers['Authorization'] = 'Bearer $newToken';
  //         return handler.resolve(await _dio.fetch(e.requestOptions));
  //       }
  //     }
  //     return handler.next(e);
  //   }));

  //   return _dio;
  // }
}
