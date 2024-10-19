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
    return Stack(
      clipBehavior: Clip.none, // Needed for floating outside the container
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 4),
          decoration:
              const BoxDecoration(color: UIColor.solidWhite, boxShadow: [
            BoxShadow(
              color: Color.fromARGB(20, 0, 0, 0),
              spreadRadius: 0,
              blurRadius: 8,
              blurStyle: BlurStyle.outer,
              offset: Offset(0, 0),
            ),
          ]),
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
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Icon(UIconsPro.solidRounded.navigation),
                ),
                label: 'Explore',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Icon(UIconsPro.solidRounded.calendar),
                ),
                label: 'Events',
              ),
              // Placeholder for center QR scan icon
              const BottomNavigationBarItem(
                icon: SizedBox.shrink(),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Icon(UIconsPro.solidRounded.ticket),
                ),
                label: 'Ticket',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Icon(UIconsPro.solidRounded.user),
                ),
                label: 'Profile',
              ),
            ],
          ),
        ),
        // Floating QR button in the center with text
        Positioned(
          bottom:
              24, // Adjust to control vertical position, floating above navbar
          left: 0,
          right: 0,
          child: Column(
            children: [
              GestureDetector(
                onTap: () => _onItemTapped(2), // Trigger QR scan tap
                child: Container(
                  width: 62,
                  height: 62,
                  decoration: const BoxDecoration(
                    color: UIColor.primary,
                    shape: BoxShape.circle,
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: Colors.black.withOpacity(0.2),
                    //     spreadRadius: 3,
                    //     blurRadius: 8,
                    //     offset: Offset(0, 3), // Shadow position
                    //   ),
                    // ],
                  ),
                  child: Icon(
                    UIconsPro.solidRounded.QR,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(height: 6), // Space between icon and text
              // const Text(
              //   'Scan QR',
              //   style: TextStyle(
              //     color: UIColor.typoGray2,
              //     fontSize: 13,
              //   ),
              // ),
            ],
          ),
        ),
      ],
    );
  }
}
