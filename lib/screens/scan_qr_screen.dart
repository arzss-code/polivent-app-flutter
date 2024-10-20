import 'package:flutter/material.dart';
// import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:polivent_app/models/ui_colors.dart'; // Untuk warna dan styling

class EventQRScanner extends StatefulWidget {
  const EventQRScanner({super.key});

  @override
  _EventQRScannerState createState() => _EventQRScannerState();
}

class _EventQRScannerState extends State<EventQRScanner> {
  // Life Cycle Method
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // remove leading(left) back icon
        centerTitle: true,
        backgroundColor: UIColor.solidWhite,
        scrolledUnderElevation: 0,
        title: const Text(
          "Scan QR for Attendance",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: UIColor.typoBlack,
          ),
        ),
      ),
      body: const Column(),
    );
  }

  // Fungsi untuk menandai absensi berdasarkan data QR yang dipindai
  void _markAttendance(String? qrCode) {
    if (qrCode != null) {
      // Lakukan sesuatu, misalnya simpan data ke server atau database
      // Bisa gunakan HTTP request atau simpan ke database lokal.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('QR Scanned: $qrCode')),
      );
    }
  }
}
