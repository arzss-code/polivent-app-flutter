import 'package:flutter/material.dart';
import 'package:polivent_app/screens/detail_events.dart';
import 'package:polivent_app/screens/edit_profile.dart';
import 'package:polivent_app/screens/help.dart';
import 'package:polivent_app/screens/home.dart';
import 'package:polivent_app/screens/login.dart';
// import 'package:polivent_app/screens/scan_qr_screen.dart';
import 'package:polivent_app/screens/select_interest.dart';
import 'package:polivent_app/screens/settings.dart';
import 'package:polivent_app/screens/splash_screen.dart';
import 'package:polivent_app/screens/success_join.dart';
import 'package:polivent_app/screens/ticket_screen.dart';
import 'package:polivent_app/screens/welcome_screen.dart';

// Jika ada halaman untuk admin
import 'package:polivent_app/screens/adminDashboard.dart';

// Routes untuk user
Map<String, WidgetBuilder> userRoutes = {
  '/welcome': (context) => const WelcomeScreen(),
  '/splash': (context) => const SplashScreen(),
  '/login': (context) => const LoginScreen(),
  '/home': (context) => const HomeScreen(),
  '/edit_profile': (context) => const EditProfileScreen(),
  '/help': (context) => const HelpScreen(),
  // '/scan_qr': (context) => const QRScanScreen(
  //       eventId: '',
  //     ),
  '/select_interest': (context) => const SelectInterestScreen(),
  '/settings': (context) => const SettingsScreen(),
  '/success_join': (context) => const SuccessJoinPopup(),
  '/ticket': (context) => const TicketScreen(),
};

// Fungsi untuk route dengan argumen
Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/detail_events':
      final args = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
        builder: (context) => DetailEvents(eventId: args['eventId']),
      );
    // Tambahkan case lain untuk route lainnya
    default:
      return MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      );
  }
}

// Routes untuk admin
Map<String, WidgetBuilder> adminRoutes = {
  '/welcome': (context) => const WelcomeScreen(),
  '/splash': (context) => const SplashScreen(),
  '/login': (context) => const LoginScreen(),
  '/admin_dashboard': (context) =>
      const AdminDashboardScreen(), // Dashboard khusus admin
  // Tambahkan route lain yang hanya bisa diakses oleh admin
};
