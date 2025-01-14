import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:polivent_app/screens/home/home.dart';
import 'package:polivent_app/screens/auth/login_screen.dart';
import 'package:polivent_app/screens/auth/welcome_screen.dart';
import 'package:polivent_app/services/token_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Inisialisasi AnimationController
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _animation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    // Jalankan pengecekan token
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Tambahkan delay minimal untuk menampilkan splash screen
      await Future.delayed(const Duration(seconds: 2));

      // Cek apakah ini pertama kali membuka aplikasi
      final prefs = await SharedPreferences.getInstance();

      // Debug: Cetak semua key yang ada di SharedPreferences
      debugPrint('All SharedPreferences keys: ${prefs.getKeys()}');

      final isFirstInstall = prefs.getBool('is_first_install') ?? true;

      debugPrint('Is First Install: $isFirstInstall');

      // Cek validitas token
      final isTokenValid = await _checkTokenValidity();

      debugPrint('Is Token Valid: $isTokenValid');

      if (!mounted) {
        debugPrint('Widget is not mounted, stopping navigation');
        return;
      }

      if (isFirstInstall) {
        // Ini pertama kali install aplikasi
        debugPrint('First time installing app, navigating to WelcomeScreen');

        await prefs.setBool('is_first_install', false);

        // Mulai animasi fade out
        await _animationController.forward();

        if (!mounted) {
          debugPrint('Widget not mounted after animation');
          return;
        }

        // Navigasi ke WelcomeScreen
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const WelcomeScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeOut;
              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);
              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            },
          ),
        );
      } else if (isTokenValid) {
        // Token valid, navigasi ke Home
        debugPrint('Token valid, navigating to Home');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
      } else {
        // Navigasi ke Login
        debugPrint('Token invalid, navigating to Login');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      // Tangani error dengan navigasi ke Login
      debugPrint('Error in initializeApp: $e');

      if (!mounted) {
        debugPrint('Widget not mounted during error handling');
        return;
      }

      await _animationController.forward();

      if (!mounted) {
        debugPrint('Widget not mounted after animation during error');
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  Future<bool> _checkTokenValidity() async {
    try {
      debugPrint('🔍 Checking Token Validity in Splash Screen');

      // Cek keberadaan token terlebih dahulu
      final accessToken = await TokenService.getAccessToken();
      final refreshToken = await TokenService.getRefreshToken();

      if (accessToken == null || refreshToken == null) {
        debugPrint('❌ No tokens found');
        return false;
      }

      // Gunakan metode checkTokenValidity
      final isValid = await TokenService.checkTokenValidity();

      debugPrint('✅ Token Validity: $isValid');
      return isValid;
    } catch (e) {
      debugPrint('🚨 Token Validation Error: $e');
      return false;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Precache gambar
    precacheImage(const AssetImage('assets/images/welcome.png'), context);
    precacheImage(const AssetImage('assets/images/logo-polivent.png'), context);
  }

  @override
  void dispose() {
    // Pastikan untuk dispose AnimationController
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Opacity(
              opacity: _animation.value,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset(
                    'assets/images/logo-polivent.png',
                    width: 150,
                    height: 150,
                  ),
                  const SizedBox(height: 20),
                  // const CircularProgressIndicator(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
