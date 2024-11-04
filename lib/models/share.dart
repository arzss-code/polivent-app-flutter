import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ShareBottomSheet extends StatefulWidget {
  final String eventName;
  final String eventDate;
  final String eventLocation;

  const ShareBottomSheet({
    super.key,
    required this.eventName,
    required this.eventDate,
    required this.eventLocation,
  });

  @override
  State<ShareBottomSheet> createState() => _ShareBottomSheetState();
}

class _ShareBottomSheetState extends State<ShareBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Share',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildShareItem(
                icon: Icons.copy,
                label: 'Copy Link',
                onTap: () {
                  // Implement copy link functionality
                },
              ),
              _buildShareItem(
                icon: Icons.whatshot_sharp,
                label: 'WhatsApp',
                onTap: () {
                  shareEvent(
                      widget.eventName, widget.eventDate, widget.eventLocation);
                },
              ),
              _buildShareItem(
                icon: Icons.tiktok,
                label: 'TikTok',
                onTap: () {
                  shareEvent(
                      widget.eventName, widget.eventDate, widget.eventLocation);
                },
              ),
              _buildShareItem(
                icon: Icons.camera_alt,
                label: 'Instagram',
                onTap: () {
                  shareEvent(
                      widget.eventName, widget.eventDate, widget.eventLocation);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              textStyle: const TextStyle(
                fontSize: 16,
              ),
            ),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void shareEvent(String eventName, String eventDate, String eventLocation) {
    Share.share(
      'Check out this event: $eventName on $eventDate at $eventLocation',
      subject: 'Event Invitation: $eventName',
    );
  }

  Widget _buildShareItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }
}
