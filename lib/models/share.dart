import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:icons_plus/icons_plus.dart';

class ShareBottomSheet {
  static void show(
    BuildContext context, {
    required String eventName,
    required String eventDate,
    required String eventLocation,
    required String eventDescription,
    required String eventLink,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return _ShareOptions(
          eventName: eventName,
          eventDate: eventDate,
          eventLocation: eventLocation,
          eventDescription: eventDescription,
          eventLink: eventLink,
        );
      },
    );
  }
}

class _ShareOptions extends StatelessWidget {
  final String eventName;
  final String eventDate;
  final String eventLocation;
  final String eventDescription;
  final String eventLink;

  const _ShareOptions({
    Key? key,
    required this.eventName,
    required this.eventDate,
    required this.eventLocation,
    required this.eventDescription,
    required this.eventLink,
  }) : super(key: key);

  // Fungsi untuk menyalin link ke clipboard
  void _copyLink(BuildContext context) {
    String textToCopy =
        '$eventName\nDate: $eventDate\nLocation: $eventLocation\nDescription: $eventDescription\nMore info: $eventLink';
    Clipboard.setData(ClipboardData(text: textToCopy));

    // Menampilkan SnackBar di bagian atas layar
    _showTopSnackBar(context, 'Event details copied to clipboard!');
  }

  // Fungsi untuk menampilkan SnackBar di bagian atas layar
  void _showTopSnackBar(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 40.0,
        left: 20.0,
        right: 20.0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    overlay?.insert(overlayEntry);

    // Menghilangkan SnackBar setelah 2 detik
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  // Fungsi untuk membuka URL
  Future<void> _launchUrl(String platform, String message) async {
    final encodedMessage = Uri.encodeComponent(message);
    String url = '';

    switch (platform) {
      case 'whatsapp':
        url = 'https://wa.me/?text=$encodedMessage';
        break;
      case 'tiktok':
        url = 'https://www.tiktok.com/share?url=$eventLink';
        break;
      case 'instagram':
        url = 'https://www.instagram.com/?text=$encodedMessage';
        break;
    }

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    String shareMessage =
        '$eventName\nDate: $eventDate\nLocation: $eventLocation\nDetails: $eventDescription\nJoin here: $eventLink';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Share',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ShareIcon(
                icon: Icons.link,
                label: 'Copy Link',
                onTap: () => _copyLink(context),
              ),
              _ShareIcon(
                icon: Bootstrap.whatsapp,
                label: 'WhatsApp',
                onTap: () => _launchUrl('whatsapp', shareMessage),
              ),
              _ShareIcon(
                icon: Bootstrap.tiktok,
                label: 'TikTok',
                onTap: () => _launchUrl('tiktok', shareMessage),
              ),
              _ShareIcon(
                icon: Bootstrap.instagram,
                label: 'Instagram',
                onTap: () => _launchUrl('instagram', shareMessage),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _ShareIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ShareIcon({
    required this.icon,
    required this.label,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 40),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

