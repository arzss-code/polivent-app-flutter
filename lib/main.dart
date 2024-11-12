import 'package:polivent_app/models/ui_colors.dart';
import 'package:polivent_app/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarBrightness: Brightness.dark,
    statusBarIconBrightness:
        Brightness.dark, // Menetapkan warna ikon status bar
    systemNavigationBarColor:
        Colors.transparent, // Menetapkan warna navigation bar
    statusBarColor: Colors.transparent, // Set the status bar color
  ));
  runApp(const PoliventApp());
}

class PoliventApp extends StatelessWidget {
  const PoliventApp({super.key});

  ThemeData _buildTheme(Brightness brightness) {
    return ThemeData(
      // Penggunaan:
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: SmoothPageTransitionsBuilder(
            duration: Duration(milliseconds: 1000),
            inCurve: Curves.easeOutQuint,
            outCurve: Curves.easeInQuint,
          ),
          TargetPlatform.iOS: SmoothPageTransitionsBuilder(),
        },
      ),
      splashFactory: NoSplash
          .splashFactory, //! Hilangkan splash effect  saat menekan navbar
      highlightColor: Colors.transparent,
      // const Color(0x2260A2FF), //! Hilangkan highlight color saat menekan navbar
      fontFamily: "Inter",
      brightness: brightness,
      textTheme: (ThemeData(brightness: brightness).textTheme),
      textSelectionTheme: const TextSelectionThemeData(
          cursorColor: UIColor.primaryColor,
          selectionColor: Color.fromARGB(98, 24, 133, 234),
          selectionHandleColor: UIColor.primaryColor),
      scaffoldBackgroundColor: UIColor.white,
      primaryColor: UIColor.primaryColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(Brightness.light),
      title: 'Polivent',
      home: const SplashScreen(),
    );
  }
}

// Versi dengan kontrol lebih detail
class SmoothPageTransitionsBuilder extends PageTransitionsBuilder {
  final Duration duration;
  final Curve inCurve;
  final Curve outCurve;

  const SmoothPageTransitionsBuilder({
    this.duration = const Duration(milliseconds: 1000),
    this.inCurve = Curves.ease,
    this.outCurve = Curves.ease,
  });

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: inCurve,
          reverseCurve: outCurve,
        ),
      ),
      child: FadeTransition(
        opacity: animation.drive(
          Tween<double>(begin: 0.0, end: 1.0).chain(
            CurveTween(curve: inCurve),
          ),
        ),
        child: child,
      ),
    );
  }
}
