// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:polivent_app/models/ui_colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QRScanScreen extends StatefulWidget {
  final String eventId;

  const QRScanScreen({super.key, required this.eventId});

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  bool isScanned = false;
  bool isFlashOn = false;
  final MobileScannerController cameraController = MobileScannerController();

  // Tambahkan URL API untuk absensi
  final String apiUrl = "https://polivent.my.id/api/attendance";

  void _onQRViewCreated(BarcodeCapture barcodeCapture) {
    if (!isScanned && barcodeCapture.barcodes.isNotEmpty) {
      final String? qrCode = barcodeCapture.barcodes.first.rawValue;

      if (qrCode != null) {
        setState(() => isScanned = true);

        // Aksi setelah QR berhasil discan
        if (qrCode == widget.eventId) {
          // Mengirim data ke API
          markAttendance(widget.eventId,
              'user123'); // Ganti 'user123' dengan user ID yang valid
        } else {
          setState(() => isScanned = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid QR Code for this event.')),
          );
        }
      }
    }
  }

  // Fungsi untuk mengirim data ke API untuk mencatat kehadiran
  Future<void> markAttendance(String eventId, String userId) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"event_id": eventId, "user_id": userId}),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Attendance marked successfully for event ID: $eventId")),
        );
        Navigator.pop(
            context); // Pindah dari tampilan pemindaian setelah sukses
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text("You have already marked attendance for this event.")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Failed to mark attendance. Please try again.")),
      );
    }
  }

  void _toggleFlash() {
    setState(() {
      isFlashOn = !isFlashOn;
      cameraController.toggleTorch();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code for Attendance'),
        backgroundColor: UIColor.solidWhite,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
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
                    'Align the QR code\nwithin the frame to scan',
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
}
