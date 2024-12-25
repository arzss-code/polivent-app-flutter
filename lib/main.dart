import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_links/app_links.dart';

// Import service dan screen yang diperlukan
import 'package:polivent_app/models/ui_colors.dart';
import 'package:polivent_app/screens/home/event/detail_events.dart';
// import 'package:polivent_app/screens/home.dart';
import 'package:polivent_app/screens/auth/splash_screen.dart';
import 'package:polivent_app/services/token_util.dart';
import 'package:polivent_app/services/notification_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeApp();
  runApp(const PoliventApp());
}

Future<void> _initializeApp() async {
  // Inisialisasi notifikasi
  await NotificationService.initializeNotification();
  await NotificationService.requestNotificationPermissions();

  // Atur style system UI
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    statusBarColor: Colors.transparent,
  ));
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
    _initAppLinks();
  }

  Future<void> _initAppLinks() async {
    _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    });
  }

  void _handleDeepLink(Uri uri) {
    if (uri.pathSegments.isNotEmpty &&
        uri.pathSegments.first == 'event-detail') {
      final String? eventIdString = uri.queryParameters['id'];
      final int eventId = int.tryParse(eventIdString ?? '') ?? -1;

      if (eventId != -1) {
        _navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => DetailEvents(eventId: eventId),
          ),
        );
      }
    }
  }

  ThemeData _buildTheme(Brightness brightness) {
    return ThemeData(
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
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
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: UIColor.primaryColor, // Warna utama progress indicator
        circularTrackColor:
            UIColor.primaryColor.withOpacity(0.3), // Warna track
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(Brightness.light),
      title: 'Polivent',
      navigatorKey: _navigatorKey,
      initialRoute: '/',
      onGenerateRoute: (RouteSettings settings) {
        if (settings.name!.startsWith('/event/')) {
          final eventId = settings.name!.replaceFirst('/event/', '');
          return MaterialPageRoute(
            builder: (context) => DetailEvents(eventId: int.parse(eventId)),
          );
        }
        return null;
      },
      home: FutureBuilder<String?>(
        future: getToken(),
        builder: (context, snapshot) {
          // Tampilkan SplashScreen sebagai tampilan awal
          return const SplashScreen();
        },
      ),
    );
  }
}
