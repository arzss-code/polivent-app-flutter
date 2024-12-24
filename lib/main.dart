import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_links/app_links.dart';

// Import service dan screen yang diperlukan
import 'package:polivent_app/models/ui_colors.dart';
import 'package:polivent_app/screens/detail_events.dart';
import 'package:polivent_app/screens/home.dart';
import 'package:polivent_app/screens/splash_screen.dart';
import 'package:polivent_app/services/token_util.dart';
import 'package:polivent_app/services/notification_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi notifikasi
  await NotificationService.initializeNotification();

  // Request izin notifikasi
  await NotificationService.requestNotificationPermissions();

  // Atur style system UI
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
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();

    // Inisialisasi deep links
    _initAppLinks();
  }

  // Method untuk handle deep links
  Future<void> _initAppLinks() async {
    _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    });
  }

  // Handler untuk deep links
  void _handleDeepLink(Uri uri) {
    if (uri.pathSegments.isNotEmpty && uri.pathSegments.first == 'event') {
      final String eventIdString = uri.pathSegments[1];
      final int eventId = int.parse(eventIdString);

      // Navigasi ke halaman detail event
      _navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => DetailEvents(eventId: eventId),
        ),
      );
    }
  }

  // Build theme method
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
      navigatorKey: _navigatorKey, // Tambahkan navigator key
      initialRoute: '/',
      onGenerateRoute: (RouteSettings settings) {
        if (settings.name!.startsWith('/event/')) {
          final eventId = settings.name!.replaceFirst('/event/', '');
          return MaterialPageRoute(
            builder: (context) => DetailEvents(eventId: int.parse(eventId)),
          );
        }
        return null; // Kembali ke default route jika tidak ada yang cocok
      },
      home: FutureBuilder(
        future: getToken(), // Ambil token dari SharedPreferences
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          } else if (snapshot.hasData && snapshot.data != null) {
            return const Home();
          } else {
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
