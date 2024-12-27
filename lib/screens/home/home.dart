import 'package:flutter/material.dart';
import 'package:polivent_app/services/token_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool _isTokenValid = false; // Ubah default menjadi false

  final List<Widget> _widgetOptions = <Widget>[
    const HomeExplore(),
    const HomeEvents(),
    const QRScanScreen(eventId: ''),
    const EventHistoryPage(),
    const HomeProfile(),
  ];

  @override
  void initState() {
    super.initState();
    _checkTokenAndNavigate();
  }

  Future<void> _checkTokenAndNavigate() async {
    try {
      final isTokenValid = await TokenService.checkTokenValidity();

      if (mounted) {
        setState(() {
          _isTokenValid = isTokenValid;
        });

        if (!isTokenValid) {
          // Hapus token yang tidak valid
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('access_token');
          await prefs.remove('refresh_token');

          // Navigate ke login
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      }
    } catch (e) {
      // Handle error saat pengecekan token
      if (mounted) {
        setState(() {
          _isTokenValid = false;
        });

        // Optional: Tampilkan pesan error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error checking token: $e')),
        );

        // Navigate ke login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
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
    // Jika token sedang dicek, tampilkan loading
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
