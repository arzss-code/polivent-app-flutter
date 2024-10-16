import 'package:polivent_app/models/ui_colors.dart';
import 'package:uicons_pro/uicons_pro.dart';
import 'package:flutter/material.dart';

class BottomNavbar extends StatefulWidget {
  final ValueChanged<int> onItemSelected;

  const BottomNavbar({super.key, required this.onItemSelected});

  @override
  BottomNavbarState createState() => BottomNavbarState();
}

class BottomNavbarState extends State<BottomNavbar> {
  int _currentIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    widget.onItemSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      decoration: const BoxDecoration(
        color: UIColor.solidWhite,
        // borderRadius: BorderRadius.only(
        //   topLeft: Radius.circular(14),
        //   topRight: Radius.circular(14),
        // ),
      ),
      child: BottomNavigationBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 13,
        unselectedFontSize: 13,
        selectedItemColor: UIColor.primary,
        unselectedItemColor: UIColor.typoGray2,
        showUnselectedLabels: true,
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(UIconsPro.solidRounded.navigation),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(UIconsPro.solidRounded.calendar),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(UIconsPro.solidRounded.ticket),
            label: 'Ticket',
          ),
          BottomNavigationBarItem(
            icon: Icon(UIconsPro.solidRounded.user),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
