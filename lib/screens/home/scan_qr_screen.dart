// import 'dart:async';
// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:http/http.dart' as http;

// // Import konfigurasi dan layanan
// import 'package:polivent_app/config/app_config.dart';
// import 'package:polivent_app/models/ui_colors.dart';
// import 'package:polivent_app/services/auth_services.dart';
// import 'package:polivent_app/services/token_service.dart';

// class QRScanScreen extends StatefulWidget {
//   final String? eventId;
//   final bool isStrictMode;

//   const QRScanScreen({Key? key, this.eventId, this.isStrictMode = false})
//       : super(key: key);

//   @override
//   _QRScanScreenState createState() => _QRScanScreenState();
// }

// class _QRScanScreenState extends State<QRScanScreen> {
//   // State Variables
//   bool isScanned = false;
//   bool isFlashOn = false;
//   bool isScanEnabled = false;
//   String? scannedEventId;
//   String? scanResultMessage;
//   dynamic scanResult;

//   // Kontroller untuk mobile scanner
//   final MobileScannerController cameraController = MobileScannerController();

//   @override
//   void initState() {
//     super.initState();
//     // Inisialisasi tambahan jika diperlukan
//   }

//   @override
//   void dispose() {
//     // Pastikan kontroller ditutup dengan benar
//     cameraController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: _buildAppBar(),
//       body: _buildBody(context),
//     );
//   }

//   // Build App Bar
//   AppBar _buildAppBar() {
//     return AppBar(
//       automaticallyImplyLeading: false,
//       title: const Text('Scan QR Code Kehadiran'),
//       backgroundColor: UIColor.solidWhite,
//       centerTitle: true,
//     );
//   }

//   // Build Body dengan Stack
//   Widget _buildBody(BuildContext context) {
//     return Stack(
//       fit: StackFit.expand,
//       children: [
//         // Tampilan Kamera
//         _buildCameraScanner(),

//         // Frame Scanner
//         _buildScannerFrame(),

//         // Tombol Scan
//         _buildScanButton(),

//         // Hasil Scan
//         _buildScanResult(context),

//         // Kontrol Bawah
//         _buildBottomControls(),
//       ],
//     );
//   }

//   // Widget Kamera Scanner
//   Widget _buildCameraScanner() {
//     return MobileScanner(
//       controller: cameraController,
//       onDetect: (barcodeCapture) {
//         if (isScanEnabled) {
//           _onQRViewCreated(barcodeCapture);
//         }
//       },
//     );
//   }

//   // Widget Frame Scanner
//   Widget _buildScannerFrame() {
//     return Center(
//       child: Container(
//         width: 250,
//         height: 250,
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.transparent, width: 2.0),
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Stack(
//           children: [
//             // 4 Siku Scanner (Kode sebelumnya)
//             // ... (4 corner widgets)
//             // Siku kiri atas
//             Positioned(
//               top: 0,
//               left: 0,
//               child: Container(
//                 width: 30,
//                 height: 4,
//                 color: Colors.blue,
//               ),
//             ),
//             Positioned(
//               top: 0,
//               left: 0,
//               child: Container(
//                 width: 4,
//                 height: 30,
//                 color: Colors.blue,
//               ),
//             ),

//             // Siku kanan atas
//             Positioned(
//               top: 0,
//               right: 0,
//               child: Container(
//                 width: 30,
//                 height: 4,
//                 color: Colors.blue,
//               ),
//             ),
//             Positioned(
//               top: 0,
//               right: 0,
//               child: Container(
//                 width: 4,
//                 height: 30,
//                 color: Colors.blue,
//               ),
//             ),

//             // Siku kiri bawah
//             Positioned(
//               bottom: 0,
//               left: 0,
//               child: Container(
//                 width: 30,
//                 height: 4,
//                 color: Colors.blue,
//               ),
//             ),
//             Positioned(
//               bottom: 0,
//               left: 0,
//               child: Container(
//                 width: 4,
//                 height: 30,
//                 color: Colors.blue,
//               ),
//             ),

//             // Siku kanan bawah
//             Positioned(
//               bottom: 0,
//               right: 0,
//               child: Container(
//                 width: 30,
//                 height: 4,
//                 color: Colors.blue,
//               ),
//             ),
//             Positioned(
//               bottom: 0,
//               right: 0,
//               child: Container(
//                 width: 4,
//                 height: 30,
//                 color: Colors.blue,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Tombol Scan
//   Widget _buildScanButton() {
//     return Positioned(
//       bottom: 100,
//       left: 0,
//       right: 0,
//       child: Center(
//         child: Visibility(
//           visible: !isScanned,
//           child: ElevatedButton(
//             onPressed: _startScan,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: UIColor.primaryColor,
//               padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//             child: const Text(
//               'Mulai Scan',
//               style: TextStyle(
//                 fontSize: 18,
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // Hasil Scan
//   Widget _buildScanResult(BuildContext context) {
//     if (scanResult == null) return const SizedBox.shrink();

//     return Positioned(
//       bottom: 200,
//       left: 0,
//       right: 0,
//       child: Center(
//         child: Container(
//           width: MediaQuery.of(context).size.width * 0.9,
//           padding: const EdgeInsets.all(16),
//           margin: const EdgeInsets.symmetric(horizontal: 20),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(10),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.2),
//                 spreadRadius: 2,
//                 blurRadius: 5,
//               ),
//             ],
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Hasil Scan:',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: UIColor.primaryColor,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Text(
//                 const JsonEncoder.withIndent('  ').convert(scanResult),
//                 style: const TextStyle(
//                   fontSize: 12,
//                   fontFamily: 'monospace',
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Kontrol Bawah
//   Widget _buildBottomControls() {
//     return Positioned(
//       bottom: 20,
//       left: 20,
//       right: 20,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Image.asset(
//             'assets/images/logo-polivent.png',
//             width: 50,
//             alignment: Alignment.center,
//             scale: 1,
//           ),
//           Row(
//             children: [
//               _buildFlashButton(),
//               const SizedBox(width: 10),
//               _buildResetButton(),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // Tombol Flash
//   Widget _buildFlashButton() {
//     return IconButton(
//       alignment: Alignment.center,
//       onPressed: _toggleFlash,
//       icon: Icon(
//         isFlashOn ? Icons.flash_off : Icons.flash_on,
//       ),
//       style: IconButton.styleFrom(
//         fixedSize: const Size(40, 40),
//         foregroundColor: Colors.white,
//         backgroundColor: Colors.blueAccent,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(24),
//         ),
//       ),
//     );
//   }

//   // Tombol Reset
//   Widget _buildResetButton() {
//     return IconButton(
//       alignment: Alignment.center,
//       onPressed: _resetScan,
//       icon: const Icon(Icons.refresh),
//       style: IconButton.styleFrom(
//         fixedSize: const Size(40, 40),
//         foregroundColor: Colors.white,
//         backgroundColor: Colors.green,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(24),
//         ),
//       ),
//     );
//   }

//   void _onQRViewCreated(BarcodeCapture barcodeCapture) async {
//     if (isScanEnabled && barcodeCapture.barcodes.isNotEmpty) {
//       final String? qrCode = barcodeCapture.barcodes.first.rawValue;

//       if (qrCode != null) {
//         setState(() {
//           isScanned = true;
//           isScanEnabled = false;
//         });

//         try {
//           debugPrint('Raw QR Code: $qrCode');

//           final decodedQRCode = _decodeBase64QR(qrCode);

//           if (decodedQRCode == null) {
//             _showScanResult('Kode QR tidak valid', isError: true);
//             _resetScan();
//             return;
//           }

//           final userData = await AuthService().getUserData();
//           if (userData == null) {
//             _showScanResult('Gagal mendapatkan data pengguna', isError: true);
//             _resetScan();
//             return;
//           }

//           if (_validateQRCode(decodedQRCode)) {
//             _showConfirmationDialog(decodedQRCode);
//           } else {
//             _showScanResult('Kode QR tidak sesuai', isError: true);
//           }
//         } catch (e) {
//           _showScanResult('Kesalahan: ${e.toString()}', isError: true);
//         }
//       }
//     }
//   }

//   void _showConfirmationDialog(String eventId) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Konfirmasi Absensi'),
//           content: Text(
//               'Apakah Anda yakin ingin melakukan absensi untuk Event ID: $eventId?'),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 _resetScan();
//               },
//               child: const Text('Batal'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 _markAttendance(eventId);
//               },
//               child: const Text('Konfirmasi'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showScanResult(String message, {bool isError = false}) {
//     setState(() {
//       scanResult = {
//         'message': message,
//         'isError': isError,
//         'timestamp': DateTime.now().toIso8601String(),
//       };
//     });
//   }

//   Future<void> _markAttendance(String eventId) async {
//     try {
//       // Ambil access token
//       final accessToken = TokenService.getAccessTokenFromSharedPrefs();

//       if (accessToken == null) {
//         _showScanResult('Token akses tidak ditemukan', isError: true);
//         return;
//       }

//       // Validasi struktur token
//       if (!TokenService.isValidTokenStructure(accessToken)) {
//         _showScanResult('Token tidak valid', isError: true);
//         return;
//       }

//       // Validasi token belum expired
//       if (TokenService.decodeToken(accessToken) == null) {
//         _showScanResult('Token tidak dapat didekode', isError: true);
//         return;
//       }

//       // Siapkan header
//       final headers = {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $accessToken',
//       };

//       // Ambil data pengguna
//       final userData = await AuthService().getUserData();
//       if (userData == null) {
//         _showScanResult('Gagal mendapatkan data pengguna', isError: true);
//         return;
//       }

//       // Siapkan body request HANYA dengan event_id
//       final body = {
//         'event_id': eventId.toString(),
//         'user_id': userData.userId.toString(),
//       };

//       // Debug print dalam format JSON yang rapi
//       debugPrint('===== DEBUG REQUEST =====');
//       debugPrint('Request URL: $prodApiBaseUrl/registration?event_id=$eventId');
//       debugPrint('Request Headers:');
//       debugPrint(JsonEncoder.withIndent('  ').convert({
//         'Content-Type': headers['Content-Type'],
//         'Authorization': 'Bearer [TOKEN_REDACTED]'
//       }));
//       debugPrint('Request Body:');
//       debugPrint(JsonEncoder.withIndent('  ').convert(body));

//       // Kirim request registrasi
//       final response = await http.post(
//         Uri.parse('$prodApiBaseUrl/registration?event_id=$eventId'),
//         headers: headers,
//         body: jsonEncode(body),
//       );

//       // Debug print response
//       debugPrint('\n===== DEBUG RESPONSE =====');
//       debugPrint('Status Code: ${response.statusCode}');
//       debugPrint('Response Headers:');
//       debugPrint(JsonEncoder.withIndent('  ').convert(response.headers));
//       debugPrint('Response Body:');

//       // Parsing response body
//       dynamic responseBody;
//       try {
//         responseBody = jsonDecode(response.body);
//         debugPrint(JsonEncoder.withIndent('  ').convert(responseBody));
//       } catch (e) {
//         debugPrint('Gagal parsing response body: ${response.body}');
//         responseBody = response.body;
//       }

//       // Simpan hasil scan dengan informasi lengkap
//       setState(() {
//         scanResult = {
//           'request': {
//             'url': '$prodApiBaseUrl/registration?event_id=$eventId',
//             'method': 'POST',
//             'headers': headers,
//             'body': body,
//           },
//           'response': {
//             'statusCode': response.statusCode,
//             'headers': response.headers,
//             'body': responseBody,
//           },
//           'timestamp': DateTime.now().toIso8601String(),
//         };
//       });

//       // Proses respons
//       if (response.statusCode == 200) {
//         _showScanResult(
//             'Registrasi berhasil: ${responseBody['message'] ?? 'Sukses'}');
//       } else {
//         _showScanResult(
//             'Gagal registrasi: ${responseBody['error'] ?? 'Kesalahan tidak diketahui'}',
//             isError: true);
//       }
//     } catch (e, stackTrace) {
//       // Debug error yang komprehensif
//       debugPrint('===== ERROR DETAILS =====');
//       debugPrint('Error: $e');
//       debugPrint('Stack Trace:');
//       debugPrint(stackTrace.toString());

//       _showScanResult('Kesalahan: ${e.toString()}', isError: true);
//     }
//   }

//   void _startScan() {
//     if (!isScanned) {
//       setState(() {
//         isScanEnabled = true;
//       });
//     }
//   }

//   void _resetScan() {
//     setState(() {
//       isScanned = false;
//       isScanEnabled = false;
//       scannedEventId = null;
//       scanResultMessage = null;
//       scanResult = null;
//     });
//   }

//   // Validasi QR Code dengan fleksibilitas
//   bool _validateQRCode(String qrCode) {
//     // Mode ketat: cocokkan dengan event ID yang diberikan
//     if (widget.isStrictMode && widget.eventId != null) {
//       bool isValid = qrCode == widget.eventId;
//       debugPrint('Validasi Mode Ketat: $isValid');
//       return isValid;
//     }

//     // Validasi umum - pastikan QR code tidak kosong
//     bool isValid = qrCode.isNotEmpty;
//     debugPrint('Validasi Umum: $isValid');
//     debugPrint('Isi QR Code: $qrCode');
//     return isValid;
//   }

//   void _toggleFlash() {
//     setState(() {
//       isFlashOn = !isFlashOn;
//       cameraController.toggleTorch();
//     });
//   }

//   String? _decodeBase64QR(String qrCode) {
//     try {
//       // Dekode Base64
//       final decodedBytes = base64Decode(qrCode);
//       final decodedString = utf8.decode(decodedBytes);

//       // Validasi dan konversi ke string
//       debugPrint('Decoded QR (Base64): $decodedString');
//       return decodedString;
//     } catch (e) {
//       // Jika dekode Base64 gagal, coba parsing langsung
//       debugPrint('Gagal dekode Base64: $e');
//       return qrCode;
//     }
//   }
// }

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;

// Import konfigurasi dan layanan
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
                Icon(
                  Icons.qr_code_scanner,
                  size: 80,
                  color: UIColor.primaryColor,
                ),
                const SizedBox(height: 16),
                Text(
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

  Future<void> _markAttendance(String eventId) async {
    try {
      final accessToken = TokenService.getAccessTokenFromSharedPrefs();

      if (accessToken == null) {
        _showScanResult(
            isSuccess: false, message: 'Token akses tidak ditemukan');
        return;
      }

      if (!TokenService.isValidTokenStructure(accessToken)) {
        _showScanResult(isSuccess: false, message: 'Token tidak valid');
        return;
      }

      if (TokenService.decodeToken(accessToken) == null) {
        _showScanResult(
            isSuccess: false, message: 'Token tidak dapat didekode');
        return;
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };

      final userData = await AuthService().getUserData();
      if (userData == null) {
        _showScanResult(
            isSuccess: false, message: 'Gagal mendapatkan data pengguna');
        return;
      }

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
        _showScanResult(isSuccess: true, message: 'Absensi berhasil dicatat.');
        debugPrint('Absensi berhasil dicatat: ${response.body}');
      } else {
        _showScanResult(isSuccess: false, message: 'Gagal mencatat absensi');
        debugPrint('Gagal mencatat absensi: ${response.body}');
      }
    } catch (e) {
      _showScanResult(isSuccess: false, message: 'Kesalahan: ${e.toString()}');
      debugPrint('Kesalahan: $e');
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
