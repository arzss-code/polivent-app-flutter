import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:polivent_app/services/token_service.dart';
import 'package:timeago/timeago.dart' as timeago;

// Import service dan screen yang diperlukan
import 'package:polivent_app/models/timeago_id.dart';
import 'package:polivent_app/models/ui_colors.dart';
import 'package:polivent_app/screens/home/event/detail_events.dart';
import 'package:polivent_app/screens/auth/splash_screen.dart';
import 'package:polivent_app/screens/home/home.dart';
import 'package:polivent_app/services/token_service.dart';
import 'package:polivent_app/services/notification_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi dependensi kritis
  await _initializeApp();

  // Set lokalisasi timeago
  timeago.setLocaleMessages('id', IdLocaleMessages());

  // Jalankan aplikasi
  runApp(const PoliventApp());
}

Future<void> _initializeApp() async {
  try {
    // Inisialisasi layanan kritis
    await Future.wait([
      NotificationService.initializeNotification(),
      NotificationService.requestNotificationPermissions(),
      _configureSystemUI(),
    ]);
  } catch (e) {
    debugPrint('Initialization error: $e');
  }
}

Future<void> _configureSystemUI() async {
  // Atur style system UI
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    statusBarColor: Colors.transparent,
  ));

  // Atur orientasi layar
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

class PoliventApp extends StatefulWidget {
  const PoliventApp({Key? key}) : super(key: key);

  @override
  _PoliventAppState createState() => _PoliventAppState();
}

class _PoliventAppState extends State<PoliventApp> with WidgetsBindingObserver {
  final AppLinks _appLinks = AppLinks();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initAppLinks();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _initAppLinks() async {
    _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    }, onError: (error) {
      debugPrint('Deep link error: $error');
    });
  }

  void _handleDeepLink(Uri uri) {
    try {
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
    } catch (e) {
      debugPrint('Deep link handling error: $e');
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
        selectionHandleColor: UIColor.primaryColor,
      ),
      scaffoldBackgroundColor: UIColor.white,
      primaryColor: UIColor.primaryColor,
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: UIColor.primaryColor,
        circularTrackColor: UIColor.primaryColor.withOpacity(0.3),
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
      home: FutureBuilder<bool>(
        future: _checkTokenValidity(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }

          // Tentukan halaman awal berdasarkan validitas token
          return snapshot.data == true ? const Home() : const SplashScreen();
        },
      ),
    );
  }

  Future<bool> _checkTokenValidity() async {
    try {
      // Periksa keberadaan dan validitas token
      final accessToken = await _secureStorage.read(key: 'access_token');
      final refreshToken = await _secureStorage.read(key: 'refresh_token');

      if (accessToken == null || refreshToken == null) {
        return false;
      }

      // Gunakan TokenService untuk validasi token
      return await TokenService.checkTokenValidity();
    } catch (e) {
      debugPrint('Token validity check error: $e');
      return false;
    }
  }
}
