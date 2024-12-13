import 'package:polivent_app/models/ui_colors.dart';
import 'package:polivent_app/screens/detail_events.dart';
import 'package:polivent_app/screens/home.dart';
import 'package:polivent_app/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_links/app_links.dart';
import 'package:polivent_app/services/token_util.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    statusBarColor: Colors.transparent,
  ));
  runApp(const PoliventApp());
}

class PoliventApp extends StatefulWidget {
  const PoliventApp({super.key});

  @override
  _PoliventAppState createState() => _PoliventAppState();
}

class _PoliventAppState extends State<PoliventApp> {
  final AppLinks _appLinks = AppLinks();
  String _linkMessage = 'No link received yet';

  @override
  void initState() {
    super.initState();
    _initAppLinks();
  }

  Future<void> _initAppLinks() async {
    // Mendengarkan link yang diterima
    _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        setState(() {
          _linkMessage = 'Received link: $uri';
        });
        // Tambahkan logika untuk menavigasi berdasarkan link
        _handleDeepLink(uri);
      }
    });
  }

  void _handleDeepLink(Uri uri) {
    if (uri.pathSegments.isNotEmpty && uri.pathSegments.first == 'event') {
      final String eventIdString =
          uri.pathSegments[1]; // Misalnya, jika URI adalah /event/123
      final int eventId = int.parse(eventIdString); // Mengonversi String ke int

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DetailEvents(eventId: eventId),
        ),
      );
    }
  }

  ThemeData _buildTheme(Brightness brightness) {
    return ThemeData(
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: SmoothPageTransitionsBuilder(
            duration: Duration(milliseconds: 1000),
            inCurve: Curves.easeIn,
            outCurve: Curves.easeOut,
          ),
          TargetPlatform.iOS: SmoothPageTransitionsBuilder(),
        },
      ),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
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
      initialRoute: '/',
      onGenerateRoute: (RouteSettings settings) {
        // Cek apakah ada deep link yang diterima
        if (settings.name!.startsWith('/event/')) {
          final eventId = settings.name!.replaceFirst('/event/', '');
          return MaterialPageRoute(
            builder: (context) => DetailEvents(
                eventId:
                    int.parse(eventId)), // Navigasi ke DetailEvents dengan ID
          );
        }
        return null; // Kembali ke default route jika tidak ada yang cocok
      },
      home: FutureBuilder(
        future: getToken(), // Ambil token dari SharedPreferences
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Tampilkan SplashScreen sementara menunggu
            return const SplashScreen();
          } else if (snapshot.hasData && snapshot.data != null) {
            // Jika token ada, arahkan ke Home
            return const Home();
          } else {
            // Jika tidak ada token, tampilkan SplashScreen
            return const SplashScreen();
          }
        },
      ),
    );
  }
}

class SmoothPageTransitionsBuilder extends PageTransitionsBuilder {
  final Duration duration;
  final Curve inCurve;
  final Curve outCurve;

  const SmoothPageTransitionsBuilder({
    this.duration = const Duration(milliseconds: 1000),
    this.inCurve = Curves.easeIn,
    this.outCurve = Curves.easeOut,
  });

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Menggunakan SlideTransition tanpa FadeTransition
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0), // Halaman baru masuk dari kanan
        end: Offset.zero, // Halaman baru berada di posisi akhir
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: inCurve,
          reverseCurve: outCurve,
        ),
      ),
      child: child,
    );
  }
}
