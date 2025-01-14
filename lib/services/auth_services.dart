import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:polivent_app/services/user_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:polivent_app/config/app_config.dart';
import 'package:polivent_app/services/data/user_model.dart';
import 'package:polivent_app/screens/auth/login_screen.dart';
import 'package:polivent_app/services/token_service.dart';

class AuthService {
  final Dio _dio = Dio();

  // Konstruktor dengan konfigurasi Dio
  AuthService() {
    _setupDioInterceptors();
  }

  // Setup Dio Interceptors dengan logging yang detail
  void _setupDioInterceptors() {
    _dio.options.baseUrl = devApiBaseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 15);

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          final token = await TokenService.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
            debugPrint('🔑 Adding Token to Request: $token');
          }

          // Detailed request logging
          debugPrint('🚀 Request Details:');
          debugPrint('Method: ${options.method}');
          debugPrint('Path: ${options.path}');
          debugPrint('Base URL: ${options.baseUrl}');
          debugPrint('Headers: ${options.headers}');
          debugPrint('Request Data: ${options.data}');

          return handler.next(options);
        } catch (e) {
          debugPrint('🚨 Request Interceptor Error: $e');
          return handler.next(options);
        }
      },
      onResponse: (response, handler) {
        try {
          // Detailed response logging
          debugPrint('✅ Response Details:');
          debugPrint('Status Code: ${response.statusCode}');
          debugPrint('Status Message: ${response.statusMessage}');
          debugPrint('Response Data: ${response.data}');

          return handler.next(response);
        } catch (e) {
          debugPrint('🚨 Response Interceptor Error: $e');
          return handler.next(response);
        }
      },
      onError: (DioException e, handler) async {
        // Comprehensive error logging
        debugPrint('❌ Detailed Error Breakdown:');
        debugPrint('Error Type: ${e.type}');
        debugPrint('Error Message: ${e.message}');
        debugPrint('Response Status Code: ${e.response?.statusCode}');
        debugPrint('Response Data: ${e.response?.data}');
        debugPrint('Request Path: ${e.requestOptions.path}');

        // Tangani kasus token expired
        if (e.response?.statusCode == 401) {
          debugPrint('🔒 Token Expired or Invalid');

          try {
            // Coba refresh token
            bool refreshResult = await _refreshTokenAndRetry(e);

            if (refreshResult) {
              // Jika refresh berhasil, ulangi request
              return handler.resolve(await _retryRequest(e.requestOptions));
            } else {
              // Jika refresh gagal, logout
              debugPrint('🚨 Token Refresh Failed');
              return handler.next(e);
            }
          } catch (refreshError) {
            debugPrint('🚨 Token Refresh Error: $refreshError');
            return handler.next(e);
          }
        }

        return handler.next(e);
      },
    ));
  }

  Future<bool> login(String email, String password) async {
    try {
      debugPrint('🔐 Login Attempt Started');
      debugPrint('📧 Email: $email');

      // Validasi input sederhana
      if (email.isEmpty || password.isEmpty) {
        debugPrint('❌ Validation Error: Email or Password is empty');
        throw DioException(
            requestOptions: RequestOptions(),
            response: Response(
                requestOptions: RequestOptions(),
                data: {'message': 'Email dan password tidak boleh kosong'}),
            message: 'Validation Error');
      }

      final response = await _dio.post('/auth', data: {
        'email': email,
        'password': password,
      });

      debugPrint('🌐 Login Response Received');
      debugPrint('Response Status: ${response.data['status']}');

      if (response.data['status'] == 'success') {
        final tokens = response.data['data'];
        final accessToken = tokens['access_token'];

        // Decode token untuk mendapatkan roles
        Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);
        List<dynamic> userRoles = decodedToken['roles'] ?? [];

        // Cek apakah 'Member' ada di dalam roles
        if (!userRoles.contains('Member')) {
          debugPrint('❌ Login Failed: Unauthorized roles');
          throw DioException(
            requestOptions: RequestOptions(),
            response: response,
            message: 'Hanya Member yang dapat login',
          );
        }

        // Logging token info (tanpa menampilkan token penuh)
        debugPrint('🔐 Tokens Received:');
        debugPrint('Access Token $accessToken');
        debugPrint('Refresh Token ${tokens['refresh_token']}');

        await TokenService.saveTokens(
            accessToken: accessToken, refreshToken: tokens['refresh_token']);

        // Simpan roles pengguna
        await UserPreferences.saveUserRoles(userRoles);

        debugPrint('✅ Login Successful');
        return true;
      } else {
        // Handle error response dari server
        final errorMessage = response.data['message'] ?? 'Login failed';
        debugPrint('❌ Login Failed: $errorMessage');

        throw DioException(
          requestOptions: RequestOptions(),
          response: response,
          message: errorMessage,
        );
      }
    } on DioException catch (e) {
      // Tangani error Dio dengan detail
      _handleDioError(e);
      return false;
    } catch (e) {
      debugPrint('🚨 Unexpected Login Error: $e');
      return false;
    }
  }

  // Method untuk refresh token dan retry request
  Future<bool> _refreshTokenAndRetry(DioException error) async {
    try {
      debugPrint('🔄 Attempting Token Refresh');

      // Gunakan metode refresh token dari TokenService
      bool refreshResult = await TokenService.refreshToken();

      if (refreshResult) {
        debugPrint('✅ Token Refresh Successful');
        return true;
      } else {
        debugPrint('❌ Token Refresh Failed');
        return false;
      }
    } catch (e) {
      debugPrint('🚨 Token Refresh Error: $e');
      return false;
    }
  }

  // Method untuk mengulang request dengan token baru
  Future<Response> _retryRequest(RequestOptions requestOptions) async {
    try {
      debugPrint('🔁 Retrying Request');

      // Ambil token baru
      String? newToken = await TokenService.getAccessToken();

      if (newToken != null) {
        requestOptions.headers['Authorization'] = 'Bearer $newToken';
      }

      // Buat ulang request
      return await _dio.fetch(requestOptions);
    } catch (e) {
      debugPrint('🚨 Request Retry Error: $e');
      rethrow;
    }
  }

  // Get User Data dengan error handling
  Future<User> getUserData() async {
    try {
      debugPrint('👤 Fetching User Data');

      final response = await _dio.get('/auth');

      debugPrint('👤 User Data Response Received');
      debugPrint('Response Status: ${response.data['status']}');

      if (response.data['status'] == 'success') {
        final userData = User.fromJson(response.data['data']);
        debugPrint('👤 User Data Parsed Successfully');
        debugPrint('User ID: ${userData.userId}');
        debugPrint('Username: ${userData.username}');

        return userData;
      } else {
        final errorMessage =
            response.data['message'] ?? 'Failed to fetch user data';
        debugPrint('❌ User Data Fetch Failed: $errorMessage');

        throw DioException(
            requestOptions: RequestOptions(), message: errorMessage);
      }
    } on DioException catch (e) {
      debugPrint('🚨 User Data Fetch DioError: ${e.message}');
      _handleDioError(e);
      throw Exception('Failed to fetch user data');
    } catch (e) {
      debugPrint('🚨 Unexpected User Data Fetch Error: $e');
      throw Exception('Unexpected error fetching user data');
    }
  }

  // Logout dengan error handling menggunakan DELETE
  Future<void> logout(BuildContext context) async {
    try {
      debugPrint('🚪 Logout Process Started');

      final token = await TokenService.getAccessToken();
      if (token == null) {
        debugPrint('🚨 No Access Token Found');
        _navigateToLogin(context);
        return;
      }

      try {
        debugPrint('🌐 Attempting Logout with token: $token');

        final response = await _dio.delete(
          '/auth',
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ),
        );

        debugPrint('Logout Response Status: ${response.statusCode}');
        debugPrint('Logout Response Data: ${response.data}');

        if (response.data['status'] == 'success') {
          debugPrint('✅ Server Logout Successful');
        } else {
          debugPrint(
              '❌ Server Logout Failed: ${response.data['message'] ?? 'Unknown error'}');
        }
      } on DioException catch (e) {
        debugPrint('🚨 Logout Request Error: ${e.message}');
        debugPrint('Error Response: ${e.response?.data}');
      } finally {
        // Selalu lakukan logout lokal
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('notifications');
        await TokenService.logout();
        _navigateToLogin(context);
      }
    } catch (e) {
      debugPrint('🚨 Unexpected Logout Error: $e');
      await TokenService.logout();
      _navigateToLogin(context);
    }
  }

  // Navigasi ke layar login
  void _navigateToLogin(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }

  // Tangani error Dio
  void _handleDioError(DioException e) {
    debugPrint('❌ Dio Error: ${e.message}');
    if (e.response != null) {
      debugPrint('Response Data: ${e.response?.data}');
    }
  }
}
