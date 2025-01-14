import 'dart:async';
import 'dart:convert';
import 'package:polivent_app/screens/home/home.dart';
import 'package:polivent_app/screens/home/ticket/home_ticket.dart';
import 'package:polivent_app/services/data/registration_model.dart';
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
  final int initialIndex;

  const QRScanScreen({
    super.key,
    this.eventId,
    this.isStrictMode = false,
    this.initialIndex = 0,
  });

  @override
  _QRScanScreenState createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  // State Variables
  bool isScanned = false;
  bool isFlashOn = false;
  bool isScanEnabled = false;
  String? scannedEventId;
  final GlobalKey<HomeTicketState> homeTicketKey = GlobalKey();

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

  void _showConfirmationDialog(String eventId) async {
    try {
      // Debug print input eventId
      debugPrint('Input Event ID: $eventId');

      // Fetch semua registrasi pengguna
      final registrations = await _fetchUserRegistrations();

      // Debug print semua registrasi
      debugPrint('Total Registrations: ${registrations.length}');
      registrations.forEach((reg) {
        debugPrint('Registered Event: ${reg.eventId}, Title: ${reg.title}');
      });

      // Cari registrasi yang sesuai dengan event ID
      Registration? matchingRegistration;
      try {
        matchingRegistration = registrations.firstWhere(
          (reg) {
            // Debug print detailed comparison
            debugPrint(
                'Comparing: reg.eventId (${reg.eventId}) == eventId ($eventId)');
            debugPrint('reg.eventId type: ${reg.eventId.runtimeType}');
            debugPrint('eventId type: ${eventId.runtimeType}');
            return reg.eventId.toString() == eventId;
          },
        );
      } catch (e) {
        debugPrint('Tidak menemukan registrasi untuk event ID: $eventId');
        debugPrint('Error details: $e');
      }

      // Gunakan judul event dari registrasi yang cocok atau fallback
      final eventTitle = matchingRegistration?.title ?? 'Event';

      // Debug print hasil akhir
      debugPrint('Matching Registration: $matchingRegistration');
      debugPrint('Event Title: $eventTitle');

      // Tampilkan dialog konfirmasi dengan judul event
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
                    'Anda akan melakukan absensi pada\n$eventTitle',
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
    } catch (e) {
      debugPrint('Kesalahan total: $e');
      _showScanResult(
        isSuccess: false,
        message: 'Kesalahan: ${e.toString()}',
      );
      _resetScan();
    }
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

                    if (isSuccess) {
                      // Navigasi ke Home dan set isFromQRScan ke true
                      Navigator.of(context).popUntil((route) => route.isFirst);
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const Home(
                            initialIndex: 3, // Index untuk HomeTicket
                            debugInfo: 'Dari QR Scan',
                            isFromQRScan: true, // Set ke true
                          ),
                        ),
                      );
                    }
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

  Future<List<Registration>> _fetchUserRegistrations() async {
    try {
      final userData = await AuthService().getUserData();
      if (userData == null) {
        debugPrint('Gagal mendapatkan data pengguna');
        return [];
      }

      final accessToken = TokenService.getAccessTokenFromSharedPrefs();
      if (accessToken == null) {
        debugPrint('Token akses tidak ditemukan');
        return [];
      }

      final headers = {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };

      final response = await http.get(
        Uri.parse('$prodApiBaseUrl/registration?user_id=${userData.userId}'),
        headers: headers,
      );

      debugPrint('Fetch Registrations Response Code: ${response.statusCode}');
      debugPrint('Fetch Registrations Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Debug print raw data
        debugPrint('Raw Registration Data: $responseData');

        // Ekstrak list data dari response
        final List<dynamic> registrationList = responseData['data'] ?? [];

        // Konversi data ke list Registration
        final registrations = registrationList
            .map((json) => Registration.fromJson(json))
            .toList();

        // Debug print converted registrations
        debugPrint('Converted Registrations Count: ${registrations.length}');
        registrations.forEach((reg) {
          debugPrint(
              'Converted Registration: EventID: ${reg.eventId}, Title: ${reg.title}');
        });

        return registrations;
      } else {
        debugPrint('Gagal mengambil registrasi: ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('Kesalahan saat fetch registrasi: $e');
      return [];
    }
  }

  Future<void> _markAttendance(String eventId) async {
    try {
      // Fetch semua registrasi pengguna
      final registrations = await _fetchUserRegistrations();

      // Cari registrasi yang sesuai dengan event ID
      Registration? matchingRegistration;
      for (var reg in registrations) {
        if (reg.eventId.toString() == eventId) {
          matchingRegistration = reg;
          break;
        }
      }

      // Kirim request absensi
      final accessToken = TokenService.getAccessTokenFromSharedPrefs();
      final userData = await AuthService().getUserData();

      if (accessToken == null || userData == null) {
        _showScanResult(
            isSuccess: false,
            message: 'Token akses atau data pengguna tidak ditemukan');
        return;
      }

      final headers = {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };

      final response = await http.post(
        Uri.parse('$prodApiBaseUrl/registration?event_id=$eventId'),
        headers: headers,
        body: jsonEncode({
          'event_id': eventId.toString(),
          'user_id': userData.userId.toString(),
        }),
      );

      if (response.statusCode == 200) {
        // Fetch ulang registrasi untuk memastikan data terbaru
        final updatedRegistrations = await _fetchUserRegistrations();

        // Cari ulang registrasi yang cocok
        Registration? updatedMatchingRegistration;
        for (var reg in updatedRegistrations) {
          if (reg.eventId.toString() == eventId) {
            updatedMatchingRegistration = reg;
            break;
          }
        }

        // Gunakan judul event dari registrasi yang cocok atau fallback
        final eventTitle = updatedMatchingRegistration?.title ??
            matchingRegistration?.title ??
            'Event';

        // Tampilkan hasil scan berhasil
        _showScanResult(
          isSuccess: true,
          message: 'Absensi Berhasil',
          additionalInfo:
              'Anda telah berhasil melakukan absensi pada Event $eventTitle',
        );

        // Kirim notifikasi berhasil absen
        await _sendAttendanceNotification(eventId, eventTitle);

        // Debug print
        debugPrint('Absensi berhasil dicatat: ${response.body}');
      } else {
        final responseBody = json.decode(response.body);
        // Mapping pesan error yang lebih informatif
        String errorMessage = _getIndonesianErrorMessage(
          responseBody['message'] ?? '',
        );

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
        additionalInfo: 'Pastikan koneksi internet stabil',
      );
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
        body: 'Anda telah berhasil melakukan absensi pada Event $eventTitle',
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
