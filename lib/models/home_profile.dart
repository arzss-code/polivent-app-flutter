// import 'package:event_proposal_app/models/search_events.dart';
import 'package:polivent_app/models/ui_colors.dart';
import 'package:polivent_app/screens/settings.dart';
import 'package:uicons_pro/uicons_pro.dart';
import 'package:flutter/material.dart';

class HomeProfile extends StatefulWidget {
  const HomeProfile({super.key});

  @override
  State<HomeProfile> createState() => _HomeProfile();
}

class _HomeProfile extends State<HomeProfile> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      AppBar(
        automaticallyImplyLeading: false, // remove leading(left) back icon
        centerTitle: true,
        backgroundColor: UIColor.solidWhite,
        scrolledUnderElevation: 0,
        title: const Text(
          "My Profile",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: UIColor.typoBlack,
          ),
        ),
        actions: [
          IconButton(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            icon: Icon(
              UIconsPro.regularRounded.settings,
              size: 20,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.center, // Elemen lain tetap di tengah
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 60, // Atur ukuran lingkaran di sini
                backgroundColor: Colors.grey[300],
                backgroundImage: const NetworkImage(
                    'https://i.ibb.co.com/hWCQWcp/profile-peter.jpg'), // Ganti dengan URL gambar Anda
              ),
              const SizedBox(height: 16),
              const Text(
                'Atsilla Arya',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Text(
                'atsiila_4.33.23.1.04@mhs.polines.ac.id',
                style: TextStyle(
                  fontSize: 14,
                  color: UIColor.typoGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 50),

              // Bagian "About Me" dan "Interests" rata kiri
              Align(
                alignment: Alignment.centerLeft, // Rata kiri
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Rata kiri
                  children: [
                    // Section "About Me"
                    const Text(
                      'About Me',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'I am a student with a strong interest in mobile app development, '
                      'UI/UX design, and gaming. I also enjoy competing in the fields '
                      'of technology and design, constantly striving to improve my skills.',
                      textAlign: TextAlign.left, // Teks rata kiri
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                    // const SizedBox(height: 2),
                    TextButton(
                      iconAlignment: IconAlignment.start,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.all(0),
                      ),
                      onPressed: () {},
                      child: const Text(
                        'Read More',
                        style: TextStyle(
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Section "Interests"
                    const Text(
                      'Interests',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Wrap(
                      spacing: 12.0,
                      runSpacing: 8.0,
                      children: [
                        InterestChip(label: 'Music'),
                        InterestChip(label: 'Workshop'),
                        InterestChip(label: 'Art'),
                        InterestChip(label: 'Sport'),
                        InterestChip(label: 'Food'),
                        InterestChip(label: 'Seminar'),
                        InterestChip(label: 'E-Sport'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      )
    ]);
  }
}

class InterestChip extends StatelessWidget {
  final String label;

  const InterestChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.blue, // Warna biru sesuai permintaan
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}
