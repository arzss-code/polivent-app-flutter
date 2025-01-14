import 'package:flutter/material.dart';
import 'package:polivent_app/models/bottom_navbar.dart';
import 'package:polivent_app/screens/home/ticket/home_ticket.dart';
import 'package:polivent_app/screens/home/event/home_events.dart';
import 'package:polivent_app/screens/home/explore/home_explore.dart';
import 'package:polivent_app/screens/home/profile/home_profile.dart';
import 'package:polivent_app/screens/home/scan_qr_screen.dart';

class Home extends StatefulWidget {
  final int initialIndex;
  final String? debugInfo;
  final bool isFromQRScan;

  const Home({
    super.key,
    this.initialIndex = 0,
    this.debugInfo,
    this.isFromQRScan = false,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late int _currentIndex;
  late bool _isFromQRScan; // State lokal untuk mengelola isFromQRScan

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex; // Gunakan initialIndex dari widget
    _isFromQRScan = widget.isFromQRScan; // Inisialisasi state lokal
  }

  final List<Widget> _widgetOptions = <Widget>[
    const HomeExplore(),
    const HomeEvents(),
    const QRScanScreen(eventId: ''),
    const HomeTicket(),
    const HomeProfile(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index; // Perbarui indeks item yang aktif
      // Reset isFromQRScan ke false jika berpindah dari HomeTicket
      if (index != 3) {
        _isFromQRScan = false; // Reset state lokal
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentIndex == 2 // Jika index QRScan, tampilkan QRScanScreen
          ? const QRScanScreen(eventId: '')
          : _currentIndex == 3 // Jika index HomeTicket, tampilkan HomeTicket
              ? DefaultTabController(
                  length: 2,
                  initialIndex:
                      _isFromQRScan ? 1 : 0, // Set ke 1 jika dari QRScan
                  child: HomeTicket(
                      isFromQRScan: _isFromQRScan), // Pass state lokal
                )
              : _widgetOptions
                  .elementAt(_currentIndex), // Tampilkan widget lainnya
      bottomNavigationBar: BottomNavbar(
        initialIndex: _currentIndex, // Pastikan initialIndex sesuai
        onItemSelected: _onItemTapped,
      ),
    );
  }
}
