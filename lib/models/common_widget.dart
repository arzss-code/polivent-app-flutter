// lib/widgets/common_widgets.dart
import 'package:flutter/material.dart';
import 'package:polivent_app/screens/auth/login_screen.dart';
import 'package:polivent_app/models/ui_colors.dart';
import 'package:polivent_app/services/auth_services.dart';
import 'package:polivent_app/services/token_service.dart';

class CommonWidgets {
  // Widget Error Umum
  static Widget buildErrorWidget({
    required BuildContext context,
    required String errorMessage,
    VoidCallback? onRetry,
    bool showRetryButton = true,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 80,
            ),
            const SizedBox(height: 20),
            const Text(
              'Terjadi Kesalahan',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: UIColor.typoBlack,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: UIColor.typoGray,
              ),
            ),
            const SizedBox(height: 20),
            if (showRetryButton)
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: UIColor.primaryColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                child: const Text(
                  'Coba Lagi',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Widget Sesi Berakhir
  static void showSessionExpiredDialog(BuildContext context) {
    // Pastikan kita tidak menampilkan dialog berulang kali
    if (ModalRoute.of(context)?.isCurrent != true) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Row(
              children: const [
                Icon(
                  Icons.warning_rounded,
                  color: Colors.orange,
                  size: 30,
                ),
                SizedBox(width: 10),
                Text(
                  'Sesi Berakhir',
                  style: TextStyle(
                    color: UIColor.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Sesi Anda telah berakhir. Silakan login kembali untuk melanjutkan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: UIColor.typoBlack,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _forceLogout(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: UIColor.primaryColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 12),
                  ),
                  child: const Text(
                    'Login Ulang',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Metode internal untuk logout
  static Future<void> _forceLogout(BuildContext context) async {
    try {
      // Hapus token dari penyimpanan
      await TokenService.removeTokens();

      // Tunggu hingga dialog ditutup
      Navigator.of(context).pop();

      // Navigasi ke halaman login dengan aman
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      });
    } catch (e) {
      print('Logout error: $e');

      // Fallback navigasi
      Future.microtask(() {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      });
    }
  }

  // Metode untuk menangani error HTTP
  static void handleHttpError(
    BuildContext context, {
    required int statusCode,
    String? customMessage,
  }) {
    // Pastikan kita tidak dalam proses navigasi
    if (!context.mounted) return;

    switch (statusCode) {
      case 401: // Unauthorized
        showSessionExpiredDialog(context);
        break;
      case 403: // Forbidden
        _showSnackBar(context, customMessage ?? 'Anda tidak memiliki akses',
            Colors.orange);
        break;
      case 404: // Not Found
        _showSnackBar(context, customMessage ?? 'Sumber data tidak ditemukan',
            Colors.blue);
        break;
      case 500: // Internal Server Error
        _showSnackBar(
            context,
            customMessage ?? 'Kesalahan server. Silakan coba lagi.',
            Colors.red);
        break;
      default:
        _showSnackBar(context,
            customMessage ?? 'Terjadi kesalahan tidak dikenal', Colors.grey);
    }
  }

  // Metode helper untuk menampilkan SnackBar
  static void _showSnackBar(
      BuildContext context, String message, Color backgroundColor) {
    // Hapus SnackBar yang sedang aktif
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    // Tampilkan SnackBar baru
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Metode untuk menampilkan loading
  static void showLoadingDialog(BuildContext context,
      {String message = 'Memuat...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(UIColor.primaryColor),
                ),
                const SizedBox(height: 20),
                Text(
                  message,
                  style: const TextStyle(
                    color: UIColor.typoBlack,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
