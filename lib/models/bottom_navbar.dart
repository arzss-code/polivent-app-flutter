import 'package:polivent_app/config/ui_colors.dart';
import 'package:uicons_pro/uicons_pro.dart';
import 'package:flutter/material.dart';

// Kelas StatefulWidget untuk bottom navbar kustom
class BottomNavbar extends StatefulWidget {
  final ValueChanged<int> onItemSelected;
  final int initialIndex; // Tambahkan parameter initialIndex

  const BottomNavbar(
      {super.key,
      required this.onItemSelected,
      this.initialIndex = 0 // Default ke 0
      });

  @override
  BottomNavbarState createState() => BottomNavbarState();
}

class BottomNavbarState extends State<BottomNavbar> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    // Gunakan initialIndex dari widget
    _currentIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index; // Perbarui indeks item yang aktif
    });
    widget.onItemSelected(index); // Panggil callback dengan indeks terpilih
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none, // Diperlukan untuk melayang di luar kontainer
      children: [
        // Kontainer utama bottom navbar
        Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 4),
          decoration:
              const BoxDecoration(color: UIColor.solidWhite, boxShadow: [
            // Efek bayangan untuk navbar
            BoxShadow(
              color: Color.fromARGB(20, 0, 0, 0),
              spreadRadius: 0,
              blurRadius: 8,
              blurStyle: BlurStyle.outer,
              offset: Offset(0, 0),
            ),
          ]),
          child: BottomNavigationBar(
            elevation: 0, // Hilangkan bayangan bawaan
            backgroundColor: Colors.transparent,
            type: BottomNavigationBarType.fixed, // Tata letak navbar tetap
            selectedFontSize: 13,
            unselectedFontSize: 13,
            selectedItemColor: UIColor.primary, // Warna item terpilih
            unselectedItemColor: UIColor.typoGray2, // Warna item tidak terpilih
            showUnselectedLabels: true,
            currentIndex: _currentIndex,
            onTap: _onItemTapped,
            items: <BottomNavigationBarItem>[
              // Item navigasi Explore
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Icon(UIconsPro.solidRounded.navigation),
                ),
                label: 'Explore',
              ),
              // Item navigasi Events
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Icon(UIconsPro.solidRounded.calendar),
                ),
                label: 'Events',
              ),
              // Item placeholder untuk tombol QR di tengah
              const BottomNavigationBarItem(
                icon: SizedBox.shrink(),
                label: '',
              ),
              // Item navigasi Ticket
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Icon(UIconsPro.solidRounded.ticket),
                ),
                label: 'Ticket',
              ),
              // Item navigasi Profile
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
        // Tombol QR mengambang di tengah
        Positioned(
          bottom: 24, // Atur posisi vertikal
          left: 0,
          right: 0,
          child: Column(
            children: [
              GestureDetector(
                // Tangani ketukan pada tombol QR
                onTap: () => _onItemTapped(2),
                child: Container(
                  width: 62,
                  height: 62,
                  decoration: const BoxDecoration(
                    color: UIColor.primary,
                    shape: BoxShape.circle, // Bentuk bulat
                  ),
                  child: Icon(
                    UIconsPro.solidRounded.QR,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(height: 6), // Jarak antara ikon dan teks
            ],
          ),
        ),
      ],
    );
  }
}
