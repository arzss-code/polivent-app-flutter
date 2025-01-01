import 'package:flutter/material.dart';
import 'package:polivent_app/models/ui_colors.dart';
// import 'ticket_screen.dart';

class SuccessJoinPopup extends StatelessWidget {
  const SuccessJoinPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: UIColor.solidWhite,
      contentPadding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      title: const Center(
        child: Icon(
          Icons.check_circle,
          color: Colors.blue,
          size: 150,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Selamat!',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: UIColor.primaryColor),
          ),
          const SizedBox(height: 8),
          const Text(
            'Anda telah berhasil bergabung dengan acara ini.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          // ElevatedButton(
          //   onPressed: () {
          //     // Navigate to the TicketScreen
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => const TicketScreen()),
          //     );
          //   },
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: Colors.blue,
          //     fixedSize: const Size(250, 50),
          //     textStyle: const TextStyle(
          //       fontSize: 16,
          //     ),
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(24),
          //     ),
          //   ),
          //   child: const Text(
          //     'Lihat E-Tiket',
          //     style: TextStyle(color: UIColor.solidWhite),
          //   ),
          // ),
          // const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              // Close the popup
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey[200],
              fixedSize: const Size(250, 50),
              textStyle: const TextStyle(
                fontSize: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Text(
              'Tutup',
              style: TextStyle(color: UIColor.primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}
