import 'package:flutter/material.dart';
import 'package:polivent_app/models/ui_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: UIColor.primaryColor,
        scaffoldBackgroundColor:
            UIColor.primaryColor, // Background biru untuk layar utama
        textTheme: ThemeData.light().textTheme.copyWith(
              bodyLarge: const TextStyle(color: UIColor.primaryColor),
            ),
      ),
      home: const TicketScreen(),
    );
  }
}

class TicketScreen extends StatelessWidget {
  const TicketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Ticket'),
        centerTitle: true,
        backgroundColor: UIColor.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ClipPath(
            clipper: TicketClipper(),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: UIColor.solidWhite, // Warna kotak tiket putih
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(0)),
                    child: Image.network(
                      "https://i.ibb.co.com/pW4RQff/poster-techomfest.jpg",
                      fit: BoxFit.cover,
                      width: 300,
                      height: 400,
                    ),
                  ),
                  CustomPaint(
                    painter: DashedLinePainter(),
                    child: const SizedBox(
                      width: double.infinity,
                      height: 20,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Seminar : Techcomfest',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color.fromARGB(255, 0, 0, 0),
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'GKT Lt.2',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: const Color.fromARGB(255, 0, 0, 0),
                                  ),
                        ),
                        const Divider(
                          height: 20,
                          thickness: 1,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Name',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color:
                                            const Color.fromARGB(255, 0, 0, 0),
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Atsiila Arya',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            const Color.fromARGB(255, 0, 0, 0),
                                      ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Text(
                                  'Time',
                                  style: TextStyle(color: Colors.black),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '9:00 PM',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            const Color.fromARGB(255, 0, 0, 0),
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Date',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color:
                                            const Color.fromARGB(255, 0, 0, 0),
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Jan 12 2024',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            const Color.fromARGB(255, 0, 0, 0),
                                      ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Text('Seat',
                                    style: TextStyle(color: Colors.black)),
                                const SizedBox(height: 4),
                                Text(
                                  'Open seating',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            const Color.fromARGB(255, 0, 0, 0),
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double radius = 5.0;
    double cutoutWidth = 5.0;
    double dashMargin = 5.0;

    Path path = Path();

    path.moveTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);
    path.lineTo(size.width - radius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, radius);
    path.lineTo(size.width, size.height * 0.60 - dashMargin);
    path.arcToPoint(
      Offset(size.width, size.height * 0.66 + dashMargin),
      radius: Radius.circular(cutoutWidth),
      clockwise: false,
    );
    path.lineTo(size.width, size.height - radius);
    path.quadraticBezierTo(
        size.width, size.height, size.width - radius, size.height);
    path.lineTo(radius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - radius);
    path.lineTo(0, size.height * 0.66 + dashMargin);
    path.arcToPoint(
      Offset(0, size.height * 0.60 - dashMargin),
      radius: Radius.circular(cutoutWidth),
      clockwise: false,
    );
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = const Color.fromARGB(255, 0, 0, 0)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    var dashWidth = 5;
    var dashSpace = 5;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
