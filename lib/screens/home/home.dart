// import 'package:flutter/material.dart';
// import 'package:polivent_app/services/token_service.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:polivent_app/models/bottom_navbar.dart';
// import 'package:polivent_app/screens/home/ticket/home_ticket.dart';
// import 'package:polivent_app/screens/home/event/home_events.dart';
// import 'package:polivent_app/screens/home/explore/home_explore.dart';
// import 'package:polivent_app/screens/home/profile/home_profile.dart';
// import 'package:polivent_app/screens/auth/login_screen.dart';
// import 'package:polivent_app/screens/home/scan_qr_screen.dart';

// class Home extends StatefulWidget {
//   const Home({super.key});

//   @override
//   State<Home> createState() => _HomeState();
// }

// class _HomeState extends State<Home> {
//   int _currentIndex = 0;
//   bool _isTokenValid = false;
//   bool _isLoading = true;

//   final List<Widget> _widgetOptions = <Widget>[
//     const HomeExplore(),
//     const HomeEvents(),
//     const QRScanScreen(eventId: ''),
//     const EventHistoryPage(),
//     const HomeProfile(),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _checkTokenAndNavigate();
//   }

//   Future<void> _checkTokenAndNavigate() async {
//     try {
//       debugPrint('🔍 Checking Token Validity in Home');

//       // Cek validitas token menggunakan TokenService
//       final isTokenValid = await TokenService.checkTokenValidity();

//       debugPrint('✅ Token Validity Result: $isTokenValid');

//       if (mounted) {
//         setState(() {
//           _isTokenValid = isTokenValid;
//           _isLoading = false;
//         });

//         if (!isTokenValid) {
//           debugPrint('🚨 Token Invalid, Navigating to Login');

//           // Hapus token menggunakan TokenService
//           await TokenService.logout();

//           // Navigate ke login
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => const LoginScreen()),
//           );
//         }
//       }
//     } catch (e) {
//       debugPrint('🚨 Token Validation Error: $e');

//       if (mounted) {
//         setState(() {
//           _isTokenValid = false;
//           _isLoading = false;
//         });

//         // Tampilkan pesan error
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error checking token: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );

//         // Navigate ke login
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const LoginScreen()),
//         );
//       }
//     }
//   }

//   void _onItemTapped(int index) {
//     // Tambahkan pengecekan token sebelum navigasi
//     if (!_isTokenValid) {
//       _checkTokenAndNavigate();
//       return;
//     }

//     setState(() {
//       _currentIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Tampilkan loading selama token dicek
//     if (_isLoading) {
//       return const Scaffold(
//         body: Center(
//           child: CircularProgressIndicator(),
//         ),
//       );
//     }

//     // Jika token tidak valid, arahkan ke login
//     if (!_isTokenValid) {
//       return const LoginScreen();
//     }

//     return Scaffold(
//       body: _widgetOptions.elementAt(_currentIndex),
//       bottomNavigationBar: BottomNavbar(
//         onItemSelected: _onItemTapped,
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:polivent_app/models/bottom_navbar.dart';
import 'package:polivent_app/screens/home/ticket/home_ticket.dart';
import 'package:polivent_app/screens/home/event/home_events.dart';
import 'package:polivent_app/screens/home/explore/home_explore.dart';
import 'package:polivent_app/screens/home/profile/home_profile.dart';
import 'package:polivent_app/screens/home/scan_qr_screen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    const HomeExplore(),
    const HomeEvents(),
    const QRScanScreen(eventId: ''),
    const EventHistoryPage(),
    const HomeProfile(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_currentIndex),
      bottomNavigationBar: BottomNavbar(
        onItemSelected: _onItemTapped,
      ),
    );
  }
}
