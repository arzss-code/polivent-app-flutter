import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:http/http.dart' as http;
import 'package:polivent_app/config/app_config.dart';
import 'package:polivent_app/models/ui_colors.dart';
import 'package:polivent_app/services/auth_services.dart';
import 'package:polivent_app/services/token_service.dart';

class QRScanScreen extends StatefulWidget {
  final String? eventId;
  final bool isStrictMode;

  const QRScanScreen({Key? key, this.eventId, this.isStrictMode = false})
      : super(key: key);

  @override
  _QRScanScreenState createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  bool isScanned = false;
  bool isFlashOn = false;
  final MobileScannerController cameraController = MobileScannerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Scan QR Code Kehadiran'),
        backgroundColor: UIColor.solidWhite,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (barcodeCapture) {
              _onQRViewCreated(barcodeCapture);
            },
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.transparent, width: 2),
              ),
              child: Stack(
                children: [
                  // Top-left corner
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.blueAccent, width: 4),
                          left: BorderSide(color: Colors.blueAccent, width: 4),
                        ),
                      ),
                    ),
                  ),
                  // Top-right corner
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.blueAccent, width: 4),
                          right: BorderSide(color: Colors.blueAccent, width: 4),
                        ),
                      ),
                    ),
                  ),
                  // Bottom-left corner
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom:
                              BorderSide(color: Colors.blueAccent, width: 4),
                          left: BorderSide(color: Colors.blueAccent, width: 4),
                        ),
                      ),
                    ),
                  ),
                  // Bottom-right corner
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom:
                              BorderSide(color: Colors.blueAccent, width: 4),
                          right: BorderSide(color: Colors.blueAccent, width: 4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Posisikan QR code\npada frame scanner',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Image.asset(
                    'assets/images/logo-polivent.png',
                    width: 50,
                    alignment: Alignment.center,
                    scale: 1,
                  ),
                  IconButton(
                    alignment: Alignment.center,
                    onPressed: _toggleFlash,
                    icon: Icon(
                      isFlashOn ? Icons.flash_off : Icons.flash_on,
                    ),
                    style: IconButton.styleFrom(
                      fixedSize: const Size(40, 40),
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(BarcodeCapture barcodeCapture) async {
    if (!isScanned && barcodeCapture.barcodes.isNotEmpty) {
      final String? qrCode = barcodeCapture.barcodes.first.rawValue;

      if (qrCode != null) {
        setState(() => isScanned = true);

        try {
          // Proses dekode QR Base64
          final decodedQRCode = _decodeBase64QR(qrCode);

          if (decodedQRCode == null) {
            _showErrorSnackbar('Kode QR tidak valid');
            return;
          }

          // Ambil data pengguna
          final userData = await AuthService().getUserData();
          if (userData == null) {
            _showErrorSnackbar('Gagal mendapatkan data pengguna');
            return;
          }

          // Validasi QR Code
          if (_validateQRCode(decodedQRCode)) {
            // Mengirim data ke API
            await _markAttendance(decodedQRCode, userData.userId.toString());
          } else {
            _showErrorSnackbar('Kode QR tidak sesuai');
          }
        } catch (e) {
          _showErrorSnackbar('Kesalahan: ${e.toString()}');
        } finally {
          setState(() => isScanned = false);
        }
      }
    }
  }

  // Fungsi untuk dekode QR Base64
  String? _decodeBase64QR(String qrCode) {
    try {
      // Coba dekode Base64
      final decodedBytes = base64Decode(qrCode);
      final decodedString = utf8.decode(decodedBytes);

      debugPrint('Dekode QR Base64: $decodedString');
      return decodedString;
    } catch (e) {
      debugPrint('Kesalahan dekode Base64: $e');

      // Jika bukan Base64, kembalikan raw value
      return qrCode;
    }
  }

  bool _validateQRCode(String qrCode) {
    // Mode ketat: cocokkan dengan event ID yang diberikan
    if (widget.isStrictMode && widget.eventId != null) {
      bool isValid = qrCode == widget.eventId;
      debugPrint('Validasi Mode Ketat: $isValid');
      return isValid;
    }

    // Validasi format atau panjang QR Code
    bool isValid = qrCode.isNotEmpty && qrCode.length >= 5;
    debugPrint('Validasi Umum: $isValid');
    return isValid;
  }

  Future<void> _markAttendance(String eventId, String userId) async {
    try {
      // Ambil access token
      final accessToken = await TokenService.getAccessToken();

      if (accessToken == null) {
        _showErrorSnackbar('Token akses tidak ditemukan');
        return;
      }

      // Siapkan header
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };

      // Kirim request absensi
      final response = await http.post(
        Uri.parse('$prodApiBaseUrl/attendance'),
        headers: headers,
        body: jsonEncode({
          'event_id': eventId,
          'user_id': userId,
        }),
      );

      // Debug print response
      debugPrint('Kode Status Respons: ${response.statusCode}');
      debugPrint('Isi Respons: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        _showSuccessSnackbar('Absensi berhasil: ${responseBody['message']}');
      } else {
        final responseBody = jsonDecode(response.body);
        _showErrorSnackbar(
            'Gagal absensi: ${responseBody['error'] ?? 'Kesalahan tidak diketahui'}');
      }
    } catch (e) {
      debugPrint('Kesalahan lengkap: $e');
      _showErrorSnackbar('Kesalahan: ${e.toString()}');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _toggleFlash() {
    setState(() {
      isFlashOn = !isFlashOn;
      cameraController.toggleTorch();
    });
  }
} 

// Tambahkan di pubspec.yaml
// dependencies:
//   mobile_scanner: ^3.2.0
//   http: ^0.13.3