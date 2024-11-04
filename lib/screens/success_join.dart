import 'package:flutter/material.dart';
import 'package:polivent_app/models/ui_colors.dart';
import 'ticket_screen.dart';

class SuccessJoinPopup extends StatelessWidget {
  const SuccessJoinPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(28),
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
          // const SizedBox(height: 8),
          const Text(
            'Congratulations!',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: UIColor.primaryColor),
          ),
          const SizedBox(height: 8),
          const Text(
            'You have successfully joined an event',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Navigate to the TicketScreen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TicketScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              fixedSize: const Size(250, 50),
              // padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              textStyle: const TextStyle(
                fontSize: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Text(
              'View E-Ticket',
              style: TextStyle(color: UIColor.solidWhite),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              // Close the popup
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey[200],
              fixedSize: const Size(250, 50),
              // padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              textStyle: const TextStyle(
                fontSize: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Text(
              'Back',
              style: TextStyle(color: UIColor.primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}
