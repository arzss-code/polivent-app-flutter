import 'package:polivent_app/models/ui_colors.dart';
import 'package:polivent_app/screens/login.dart';
import 'package:flutter/material.dart';

void initState() {}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIColor.solidWhite,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Bagian atas gambar dengan gradasi
              Positioned.fill(
                child: Column(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          // Gambar di bagian atas
                          Positioned.fill(
                            child: Image.asset(
                              'assets/images/welcome.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                          // Gradasi transparan
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment
                                      .bottomCenter, // Gradasi dimulai dari bawah
                                  end: Alignment.topCenter, // Menuju ke atas
                                  colors: [
                                    const Color.fromARGB(255, 255, 255, 255)
                                        .withOpacity(
                                            0.6), // Warna bagian bawah (lebih transparan)
                                    const Color.fromARGB(0, 255, 255,
                                        255), // Transparan di bagian atas
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Bagian bawah: teks keterangan dan tombol
                    SizedBox(
                      height: constraints.maxHeight * 0.40,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Keterangan aplikasi
                            const Text(
                              "Selamat datang di Polivent!",
                              style: TextStyle(
                                fontSize: 24.0,
                                fontFamily: "Inter",
                                fontWeight: FontWeight.w800,
                                color: UIColor.primary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16.0),
                            const Text(
                              "Polivent adalah aplikasi yang dirancang untuk memudahkan Anda dalam menjelajahi dan bergabung dengan Event Gratis di sekitar Polines  ",
                              style: TextStyle(
                                fontSize: 16.0,
                                fontFamily: "Inter",
                                color: UIColor.typoGray,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 36.0),
                            // Tombol Get Started
                            ElevatedButton(
                              onPressed: () {
                                // Aksi ketika tombol ditekan
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const LoginScreen(), // Ganti ke screen berikutnya
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                  fixedSize: Size(
                                    MediaQuery.of(context).size.width * 1,
                                    50,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  backgroundColor: UIColor.primaryColor),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Ayo Mulai",
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontFamily: "Inter",
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 8.0),
                                  Icon(
                                    Icons.arrow_forward,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
