import 'package:flutter/material.dart';
import 'ticketscreen.dart';

class SuccessJoinPopup extends StatelessWidget {
  const SuccessJoinPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Center(
        child: Icon(
          Icons.check_circle_outline,
          color: Colors.blue,
          size: 48,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          const Text(
            'Congratulations!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
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
              // Navigate to the E-Ticket view
              //Navigator.pushNamed(context, '/e-ticket');
              Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const TicketScreen()),
                      );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('View E-Ticket'),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              // Close the popup
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: const Text('Back'),
          ),
        ],
      ),
    );
  }
}
