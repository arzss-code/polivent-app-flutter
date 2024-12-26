import 'package:flutter/material.dart';
import 'package:polivent_app/screens/home/home.dart';
import 'package:polivent_app/screens/auth/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:dio/dio.dart';

class TokenService {
  // Method untuk memeriksa dan memvalidasi token
  static Future<bool> checkTokenValidity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');
    final refreshToken = prefs.getString('refresh_token');

    // Cek apakah token tersedia
    if (accessToken == null || refreshToken == null) {
      return false;
    }

    try {
      // Periksa apakah access token sudah expired
      if (JwtDecoder.isExpired(refreshToken)) {
        // Coba refresh token
        final newRefreshToken = await _refreshToken(refreshToken);

        if (newRefreshToken != null) {
          // Simpan access token baru
          await prefs.setString('refresh_token', newRefreshToken);
          return true;
        }

        return false;
      }

      return true;
    } catch (e) {
      print('Token validation error: $e');
      return false;
    }
  }

  // Method untuk refresh token
  static Future<String?> _refreshToken(String refreshToken) async {
    try {
      final dio = Dio();
      final response = await dio.post(
        'https://your-api-url.com/refresh-token', // Ganti dengan URL refresh token Anda
        data: {
          'refresh_token': refreshToken,
        },
      );

      if (response.statusCode == 200) {
        // Sesuaikan dengan struktur response API Anda
        final newAccessToken = response.data['access_token'];
        final newRefreshToken = response.data['refresh_token'] ?? refreshToken;

        // Simpan token baru
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', newAccessToken);
        await prefs.setString('refresh_token', newRefreshToken);

        return newAccessToken;
      }
    } catch (e) {
      print('Refresh token error: $e');
    }

    return null;
  }

  // Method untuk logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }
}

// Dalam SplashScreen atau InitialScreen
class InitialScreen extends StatefulWidget {
  const InitialScreen({Key? key}) : super(key: key);

  @override
  _InitialScreenState createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  @override
  void initState() {
    super.initState();
    _checkTokenAndNavigate();
  }

  Future<void> _checkTokenAndNavigate() async {
    final isTokenValid = await TokenService.checkTokenValidity();

    if (isTokenValid) {
      // Token valid, navigasi ke Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
      );
    } else {
      // Token tidak valid, navigasi ke Login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tampilkan splash screen atau loading indicator
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
