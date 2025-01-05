import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;

// Import konfigurasi dan layanan
import 'package:polivent_app/config/app_config.dart';
import 'package:polivent_app/config/ui_colors.dart';
import 'package:polivent_app/services/auth_services.dart';
import 'package:polivent_app/services/notification/notification_services.dart';
import 'package:polivent_app/services/token_service.dart';

class QRScanScreen extends StatefulWidget {
  final String? eventId;
  final bool isStrictMode;

  const QRScanScreen({super.key, this.eventId, this.isStrictMode = false});

  @override
  _QRScanScreenState createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  // State Variables
  bool isScanned = false;
  bool isFlashOn = false;
  bool isScanEnabled = false;
  String? scannedEventId;

  // Kontroller untuk mobile scanner
  final MobileScannerController cameraController = MobileScannerController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(context),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      title: const Text('Scan QR Code Kehadiran'),
      backgroundColor: UIColor.solidWhite,
      centerTitle: true,
    );
  }

  Widget _buildBody(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildCameraScanner(),
        _buildScannerFrame(),
        _buildScanButton(),
        _buildBottomControls(),
      ],
    );
  }

  Widget _buildCameraScanner() {
    return MobileScanner(
      controller: cameraController,
      onDetect: (barcodeCapture) {
        if (isScanEnabled) {
          _onQRViewCreated(barcodeCapture);
        }
      },
    );
  }

  Widget _buildScannerFrame() {
    return Center(
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.transparent, width: 2.0),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            // 4 Siku Scanner
            Positioned(
              top: 0,
              left: 0,
              child: Container(width: 30, height: 4, color: Colors.blue),
            ),
            Positioned(
              top: 0,
              left: 0,
              child: Container(width: 4, height: 30, color: Colors.blue),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(width: 30, height: 4, color: Colors.blue),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(width: 4, height: 30, color: Colors.blue),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(width: 30, height: 4, color: Colors.blue),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(width: 4, height: 30, color: Colors.blue),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(width: 30, height: 4, color: Colors.blue),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(width: 4, height: 30, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanButton() {
    return Positioned(
      bottom: 100,
      left: 0,
      right: 0,
      child: Center(
        child: Visibility(
          visible: !isScanned,
          child: ElevatedButton(
            onPressed: _startScan,
            style: ElevatedButton.styleFrom(
              backgroundColor: UIColor.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Mulai Scan',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            'assets/images/logo-polivent.png',
            width: 50,
            alignment: Alignment.center,
            scale: 1,
          ),
          Row(
            children: [
              _buildFlashButton(),
              const SizedBox(width: 10),
              _buildResetButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFlashButton() {
    return IconButton(
      alignment: Alignment.center,
      onPressed: _toggleFlash,
      icon: Icon(
        isFlashOn ? Icons.flash_off : Icons.flash_on,
      ),
      style: IconButton.styleFrom(
        fixedSize: const Size(40, 40),
        foregroundColor: Colors.white,
        backgroundColor: UIColor.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }

  Widget _buildResetButton() {
    return IconButton(
      alignment: Alignment.center,
      onPressed: _resetScan,
      icon: const Icon(Icons.refresh),
      style: IconButton.styleFrom(
        fixedSize: const Size(40, 40),
        foregroundColor: Colors.white,
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }

  void _onQRViewCreated(BarcodeCapture barcodeCapture) async {
    if (isScanEnabled && barcodeCapture.barcodes.isNotEmpty) {
      final String? qrCode = barcodeCapture.barcodes.first.rawValue;

      if (qrCode != null) {
        setState(() {
          isScanned = true;
          isScanEnabled = false;
        });

        try {
          final decodedQRCode = _decodeBase64QR(qrCode);

          if (decodedQRCode == null) {
            _showScanResult(isSuccess: false, message: 'Kode QR tidak valid');
            _resetScan();
            return;
          }

          final userData = await AuthService().getUserData();
          if (userData == null) {
            _showScanResult(
                isSuccess: false, message: 'Gagal mendapatkan data pengguna');
            _resetScan();
            return;
          }

          if (_validateQRCode(decodedQRCode)) {
            _showConfirmationDialog(decodedQRCode);
          } else {
            _showScanResult(isSuccess: false, message: 'Kode QR tidak sesuai');
          }
        } catch (e) {
          _showScanResult(
              isSuccess: false, message: 'Kesalahan: ${e.toString()}');
        }
      }
    }
  }

  void _showConfirmationDialog(String eventId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.qr_code_scanner,
                  size: 80,
                  color: UIColor.primaryColor,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Konfirmasi Absensi',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: UIColor.primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Anda akan melakukan absensi untuk Event ID: $eventId',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _resetScan();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: UIColor.primaryColor,
                      ),
                      child: const Text('Batal'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _markAttendance(eventId);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: UIColor.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Konfirmasi',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showScanResult({
    required bool isSuccess,
    required String message,
    String? additionalInfo,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSuccess ? Icons.check_circle : Icons.error,
                  size: 80,
                  color: isSuccess ? Colors.green : Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  isSuccess ? 'Berhasil' : 'Gagal',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isSuccess ? Colors.green : Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (additionalInfo != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    additionalInfo,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _resetScan();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: UIColor.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Tutup',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<String> _fetchEventTitle(int eventId) async {
    try {
      final response = await http.get(
        Uri.parse('$prodApiBaseUrl/available_events?event_id=$eventId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        return responseBody['title'] ?? 'Event';
      } else {
        return 'Event';
      }
    } catch (e) {
      debugPrint('Gagal mengambil judul event: $e');
      return 'Event';
    }
  }

  Future<void> _markAttendance(String eventId) async {
    try {
      final accessToken = TokenService.getAccessTokenFromSharedPrefs();

      if (accessToken == null) {
        _showScanResult(
            isSuccess: false, message: 'Token akses tidak ditemukan');
        return;
      }

      final userData = await AuthService().getUserData();
      if (userData == null) {
        _showScanResult(
            isSuccess: false, message: 'Gagal mendapatkan data pengguna');
        return;
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };

      final body = {
        'event_id': eventId.toString(),
        'user_id': userData.userId.toString(),
      };

      final response = await http.post(
        Uri.parse('$prodApiBaseUrl/registration?event_id=$eventId'),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        // Parse response untuk mendapatkan detail event
        final responseBody = json.decode(response.body);
        // Ambil detail event dari endpoint lain jika tidak ada di response
        final eventTitle =
            responseBody['title'] ?? await _fetchEventTitle(int.parse(eventId));

        // Tampilkan hasil scan berhasil
        _showScanResult(
            isSuccess: true,
            message: 'Absensi Berhasil',
            additionalInfo:
                'Anda telah berhasil melakukan absensi pada $eventTitle');

        // Kirim notifikasi berhasil absen
        await _sendAttendanceNotification(eventId, eventTitle);

        // Debug print
        debugPrint('Absensi berhasil dicatat: ${response.body}');
      } else {
        final responseBody = json.decode(response.body);
        // Mapping pesan error yang lebih informatif
        String errorMessage =
            _getIndonesianErrorMessage(responseBody['message'] ?? '');
        _showScanResult(
          isSuccess: false,
          message: 'Absensi Gagal',
          additionalInfo: errorMessage,
        );
        debugPrint('Gagal mencatat absensi: ${response.body}');
      }
    } catch (e) {
      _showScanResult(
          isSuccess: false,
          message: 'Kesalahan: ${e.toString()}',
          additionalInfo: 'Pastikan koneksi internet stabil');
      debugPrint('Kesalahan: $e');
    }
  }

// Method untuk menerjemahkan pesan error
  String _getIndonesianErrorMessage(String originalMessage) {
    switch (originalMessage) {
      case 'Attendance already recorded or invalid event':
        return 'Maaf, Anda sudah pernah melakukan absensi untuk event ini';
      case 'Event has not started':
        return 'Maaf, event belum dimulai. Absensi tidak dapat dilakukan';
      case 'Event has ended':
        return 'Waduh, event sudah berakhir. Periode absensi telah ditutup';
      case 'Invalid QR code':
        return 'Kode QR tidak valid. Silakan periksa kembali';
      case 'User not registered':
        return 'Anda belum terdaftar untuk event ini';
      default:
        return 'Terjadi kesalahan. Silakan coba lagi atau hubungi panitia';
    }
  }

// Method baru untuk mengirim notifikasi keberhasilan absensi
  Future<void> _sendAttendanceNotification(
      String eventId, String eventTitle) async {
    try {
      // Kirim notifikasi berhasil absen
      await NotificationService.sendEventAttendanceNotification(
        eventId: int.parse(eventId),
        eventTitle: eventTitle,
      );

      // Simpan notifikasi ke lokal untuk ditampilkan di menu notifikasi
      await NotificationService.saveNotificationToLocal(
        title: 'Absensi Berhasil',
        body: 'Anda telah berhasil absen pada $eventTitle',
        payload: {
          'event_id': eventId,
          'type': 'attendance_success',
        },
      );
    } catch (e) {
      debugPrint('Gagal mengirim notifikasi absensi: $e');
    }
  }

  void _startScan() {
    if (!isScanned) {
      setState(() {
        isScanEnabled = true;
      });
    }
  }

  void _resetScan() {
    setState(() {
      isScanned = false;
      isScanEnabled = false;
      scannedEventId = null;
    });
  }

  bool _validateQRCode(String qrCode) {
    if (widget.isStrictMode && widget.eventId != null) {
      return qrCode == widget.eventId;
    }
    return qrCode.isNotEmpty;
  }

  void _toggleFlash() {
    setState(() {
      isFlashOn = !isFlashOn;
      cameraController.toggleTorch();
    });
  }

  String? _decodeBase64QR(String qrCode) {
    try {
      final decodedBytes = base64Decode(qrCode);
      return utf8.decode(decodedBytes);
    } catch (e) {
      return qrCode;
    }
  }
}
