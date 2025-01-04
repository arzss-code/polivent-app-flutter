import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_links/app_links.dart';
import 'package:polivent_app/services/token_service.dart';
import 'package:timeago/timeago.dart' as timeago;

// Import service dan screen yang diperlukan
import 'package:polivent_app/models/timeago_id.dart';
import 'package:polivent_app/config/ui_colors.dart';
import 'package:polivent_app/screens/home/event/detail_events.dart';
import 'package:polivent_app/screens/auth/splash_screen.dart';
import 'package:polivent_app/screens/home/home.dart';
import 'package:polivent_app/services/notification/notification_services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi dependensi
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
    await TokenService.initSharedPreferences();
  } catch (e) {
    debugPrint('Initialization error: $e');
  }
}

Future<void> _configureSystemUI() async {
  // Atur style system UI
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.dark, // Icon status bar gelap
    systemNavigationBarColor: Colors.white, // Warna navigation bar putih
    systemNavigationBarIconBrightness:
        Brightness.dark, // Icon navigation bar gelap
    statusBarColor: Colors.transparent,
  ));

  // Atur orientasi layar
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

class PoliventApp extends StatefulWidget {
  const PoliventApp({super.key});

  @override
  PoliventAppState createState() => PoliventAppState();
}

class PoliventAppState extends State<PoliventApp> with WidgetsBindingObserver {
  final AppLinks _appLinks = AppLinks();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  // final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

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
    // Tangkap initial link saat aplikasi pertama kali dibuka
    final initialLink = await _appLinks.getInitialLink();
    if (initialLink != null) {
      _handleDeepLink(initialLink);
    }

    // Listen untuk link yang masuk selama aplikasi berjalan
    _appLinks.uriLinkStream.listen(
      (Uri? uri) {
        if (uri != null) {
          debugPrint('🔗 Deep Link Detected: $uri');
          _handleDeepLink(uri);
        }
      },
      onError: (error) {
        debugPrint('🚨 Deep Link Error: $error');
      },
    );
  }

  // Dalam fungsi _handleDeepLink di main.dart
  void _handleDeepLink(Uri uri) {
    try {
      debugPrint('🔍 Processing Deep Link: $uri');

      // Validasi host dan path
      if (uri.host == 'polivent.my.id' || uri.host == 'www.polivent.my.id') {
        // Ekstrak event ID dengan berbagai metode
        String? eventId;

        // Coba ambil dari path segments
        if (uri.pathSegments.length > 1 && uri.pathSegments[0] == 'event') {
          eventId = uri.pathSegments[1];
        }

        // Coba ambil dari query parameter
        if (eventId == null) {
          eventId = uri.queryParameters['id'];
        }

        // Konversi dan validasi event ID
        final parsedEventId = int.tryParse(eventId ?? '');

        if (parsedEventId != null) {
          debugPrint('✅ Valid Event ID: $parsedEventId');

          // Navigasi dengan safety
          Future.delayed(Duration.zero, () {
            Navigator.of(_navigatorKey.currentContext!).push(
              MaterialPageRoute(
                builder: (context) => DetailEvents(eventId: parsedEventId),
              ),
            );
          });
        } else {
          debugPrint('❌ Invalid Event ID');
        }
      }
    } catch (e) {
      debugPrint('🚨 Deep Link Handling Error: $e');
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
      scrollBehavior: const ScrollBehavior().copyWith(overscroll: false),
      theme: _buildTheme(Brightness.light),
      title: 'Polivent',
      navigatorKey: _navigatorKey,

      // Tambahkan konfigurasi lokalisasi
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      supportedLocales: const [
        Locale('id', 'ID'), // Bahasa Indonesia
        Locale('en', 'US'), // Bahasa Inggris
      ],
      initialRoute: '/',
      // Tambahkan dalam onGenerateRoute untuk mendukung deep linking
      onGenerateRoute: (RouteSettings settings) {
        // Existing route untuk event
        if (settings.name!.startsWith('/event/')) {
          final eventId = settings.name!.replaceFirst('/event/', '');
          return MaterialPageRoute(
            builder: (context) => DetailEvents(eventId: int.parse(eventId)),
          );
        }

        // Tambahkan route untuk deep link
        if (settings.name!
            .startsWith('https://polivent.my.id/event-detail?id=')) {
          final eventId = settings.name!
              .replaceFirst('https://polivent.my.id/event-detail?id=', '');
          return MaterialPageRoute(
            builder: (context) => DetailEvents(eventId: int.parse(eventId)),
          );
        }

        return null;
      },

      // Tambahkan builder untuk menangani error global
      builder: (context, child) {
        ErrorWidget.builder = (FlutterErrorDetails details) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 50,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Terjadi Kesalahan',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    details.exception.toString(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          );
        };

        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: 1.0, // Nonaktifkan scaling teks
          ),
          child: child!,
        );
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
      // Gunakan metode dari TokenService untuk validasi
      debugPrint('🔍 Checking Token Validity in Main App');

      // Langsung gunakan metode checkTokenValidity dari TokenService
      bool isValid = await TokenService.checkTokenValidity();

      debugPrint('✅ Token Validity Result: $isValid');
      return isValid;
    } catch (e) {
      debugPrint('🚨 Token Validity Check Error in Main App: $e');
      return false;
    }
  }
}

// Tambahkan extension untuk handling error global
extension GlobalErrorHandling on FlutterError {
  static void setCustomErrorWidget() {
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 50,
              ),
              const SizedBox(height: 16),
              Text(
                'Terjadi Kesalahan Tidak Terduga',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                details.exception.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      );
    };
  }
}
