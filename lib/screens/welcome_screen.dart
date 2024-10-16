import 'package:polivent_app/models/ui_colors.dart';
import 'package:polivent_app/screens/login.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

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
                              'assets/images/welcome-image.png', // Ganti dengan path gambar Anda
                              fit: BoxFit.cover,
                            ),
                          ),
                          // Gradasi transparan
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    const Color.fromARGB(255, 255, 255, 255)
                                        .withOpacity(0.6),
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
                            horizontal: 22.0, vertical: 8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Keterangan aplikasi
                            const Text(
                              "Welcome to Polivent",
                              style: TextStyle(
                                fontSize: 24.0,
                                fontFamily: "Inter",
                                fontWeight: FontWeight.bold,
                                color: UIColor.primary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16.0),
                            const Text(
                              "Polivent is an event app designed specifically to make it easier for you to explore and join exciting Free events around Polines.  ",
                              style: TextStyle(
                                fontSize: 16.0,
                                fontFamily: "Inter",
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20.0),
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 110.0, vertical: 15.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  backgroundColor: const Color(0xff1886EA)),
                              child: const Text(
                                "Get Started",
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontFamily: "Inter",
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
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
