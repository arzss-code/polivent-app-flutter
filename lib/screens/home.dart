import 'package:polivent_app/models/bottom_navbar.dart';
import 'package:polivent_app/models/home_ticket.dart';
import 'package:polivent_app/models/home_events.dart';
import 'package:polivent_app/models/home_explore.dart';
import 'package:polivent_app/models/home_profile.dart';
import 'package:flutter/material.dart';
import 'package:polivent_app/screens/scan_qr_screen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  final List<Widget> _widgetOptions = <Widget>[
    const HomeExplore(),
    const HomeEvents(),
    const QRScanScreen(
      eventId: '',
    ),
    const HomeTicket(),
    const HomeProfile(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //! membuat EXPLORE tidak memiliki appbar
      body: _widgetOptions.elementAt(_currentIndex),
      bottomNavigationBar: BottomNavbar(
        onItemSelected: _onItemTapped,
      ),
    );
  }
}
