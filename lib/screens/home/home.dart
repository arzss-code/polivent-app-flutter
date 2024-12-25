import 'package:flutter/material.dart';
import 'package:polivent_app/services/token.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'package:polivent_app/config/app_config.dart';
import 'package:polivent_app/models/bottom_navbar.dart';
import 'package:polivent_app/screens/home/ticket/home_ticket.dart';
import 'package:polivent_app/screens/home/event/home_events.dart';
import 'package:polivent_app/screens/home/explore/home_explore.dart';
import 'package:polivent_app/screens/home/profile/home_profile.dart';
import 'package:polivent_app/screens/auth/login_screen.dart';
import 'package:polivent_app/screens/home/scan_qr_screen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  bool _isTokenValid = true;

  final List<Widget> _widgetOptions = <Widget>[
    const HomeExplore(),
    const HomeEvents(),
    const QRScanScreen(eventId: ''),
    const HomeTicket(),
    const HomeProfile(),
  ];

  @override
  void initState() {
    super.initState();
    // _checkTokenStatus();
    _checkTokenAndNavigate();
  }

  Future<void> _checkTokenAndNavigate() async {
    final isTokenValid = await TokenService.checkTokenValidity();

    if (!isTokenValid) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  // Future<void> _checkTokenStatus() async {
  //   try {
  //     // Ambil refresh token dari SharedPreferences
  //     final prefs = await SharedPreferences.getInstance();
  //     final refreshToken = prefs.getString('refresh_token');

  //     if (refreshToken == null) {
  //       navigateToLogin();
  //       return;
  //     }

  //     // Lakukan request sederhana untuk mengecek token
  //     final response = await http.get(
  //       Uri.parse(
  //           '$devApiBaseUrl/auth'), // Ganti dengan endpoint profil atau endpoint aman lainnya
  //       headers: {
  //         'Authorization': 'Bearer $refreshToken',
  //         'Content-Type': 'application/json',
  //       },
  //     ).timeout(
  //       const Duration(seconds: 10),
  //       onTimeout: () {
  //         // Tangani timeout
  //         navigateToLogin();
  //         throw Exception('Token check timeout');
  //       },
  //     );

  //     if (response.statusCode != 200) {
  //       // Token tidak valid
  //       navigateToLogin();
  //     }
  //   } catch (e) {
  //     // Error dalam proses pengecekan token
  //     print('Token check error: $e');
  //     navigateToLogin();
  //   }
  // }

  // void navigateToLogin() {
  //   setState(() {
  //     _isTokenValid = false;
  //   });

  //   // Hapus token yang tersimpan
  //   _clearTokens();

  //   // Navigasi ke halaman login
  //   Navigator.pushReplacement(
  //     context,
  //     MaterialPageRoute(builder: (context) => const LoginScreen()),
  //   );
  // }

  Future<void> _clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('email');
    await prefs.remove('password');
  }

  void _onItemTapped(int index) {
    // Cek validitas token sebelum pindah halaman
    if (!_isTokenValid) {
      _checkTokenAndNavigate();
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Jika token tidak valid, tampilkan layar loading
    if (!_isTokenValid) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: _widgetOptions.elementAt(_currentIndex),
      bottomNavigationBar: BottomNavbar(
        onItemSelected: _onItemTapped,
      ),
    );
  }
}
