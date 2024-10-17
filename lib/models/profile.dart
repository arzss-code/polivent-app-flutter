import 'package:flutter/material.dart';

class HomeProfile extends StatefulWidget {
  const HomeProfile({super.key});

  @override
  State<HomeProfile> createState() => _HomeProfileState();
}

class _HomeProfileState extends State<HomeProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
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
                fontSize: 22,
                fontWeight: FontWeight.bold,
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
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Read More',
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Section "Interests"
                  const Text(
                    'Interests',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: [
                      InterestChip(label: 'Seminar'),
                      InterestChip(label: 'Competition'),
                      InterestChip(label: 'Workshop'),
                      InterestChip(label: 'Music'),
                      InterestChip(label: 'Art'),
                      InterestChip(label: 'Sport'),
                      InterestChip(label: 'Food'),
                      InterestChip(label: 'E-Sport'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
      shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(24)), // Menggunakan border radius (10),
      backgroundColor: Colors.blue, // Warna biru sesuai permintaan
    );
  }
}
