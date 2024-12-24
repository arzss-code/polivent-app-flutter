import 'package:flutter/material.dart';
import 'package:polivent_app/screens/home.dart';
import 'package:polivent_app/screens/login.dart';
import 'package:polivent_app/screens/welcome_screen.dart';
import 'package:polivent_app/services/token.dart'; // Pastikan path benar

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Polivent App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(), // Mulai dari SplashScreen
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    _checkTokenAndNavigate();

    // Mulai animasi fade out setelah 2 detik
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _opacity = 0.0; // Mengubah opacity menjadi 0 (fade out)
      });

      // Setelah 1 detik (animasi fade out selesai), navigasi ke WelcomeScreen
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const WelcomeScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.ease;
                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);
                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
            ),
          );
        }
      });
    });
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
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Precache gambar secara background di didChangeDependencies untuk menghindari error MediaQuery
    precacheImage(const AssetImage('assets/images/welcome.png'), context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(seconds: 1), // Durasi animasi fade out
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset(
                'assets/images/logo-polivent.png', // Pastikan path gambar logo benar
                width: 150, // Ukuran logo
                height: 150,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
