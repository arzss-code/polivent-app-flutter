import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:polivent_app/config/ui_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:icons_plus/icons_plus.dart';

class ShareBottomSheet {
  static void show(
    BuildContext context, {
    required String eventName,
    required String eventPoster,
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
          eventPoster: eventPoster,
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
  final String eventPoster;
  final String eventDate;
  final String eventLocation;
  final String eventDescription;
  final String eventLink;

  const _ShareOptions({
    required this.eventName,
    required this.eventPoster,
    required this.eventDate,
    required this.eventLocation,
    required this.eventDescription,
    required this.eventLink,
  });

  void _copyLink(BuildContext context) {
    String textToCopy =
        '$eventName\n$eventPoster\nDate: $eventDate\nLocation: $eventLocation\nDescription: $eventDescription\nMore info: $eventLink';
    Clipboard.setData(ClipboardData(text: textToCopy));
    _showTopSnackBar(context, 'Event details copied to clipboard!');
  }

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

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

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
        url = 'https://www.instagram.com/create/story/?media=$encodedMessage';
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
        '$eventName\n\nDate: $eventDate\nLocation: $eventLocation\nDetails: $eventDescription\n\nJoin here: $eventLink';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // // Menampilkan poster acara
          // ClipRRect(
          //   borderRadius: BorderRadius.circular(10),
          //   child: Image.network(
          //     eventPoster,
          //     height: 150,
          //     width: double.infinity,
          //     fit: BoxFit.cover,
          //   ),
          // ),
          // const SizedBox(height: 16),
          Text(
            eventName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Date: $eventDate\nLocation: $eventLocation',
            style: const TextStyle(fontSize: 14, color: UIColor.typoGray),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Share this event:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ShareIcon(
                icon: Icons.copy,
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
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              fixedSize: Size(
                MediaQuery.of(context).size.width * 0.8,
                50,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              // backgroundColor: UIColor.primaryColor
            ),
            child: const Text('Cancel',
                style: TextStyle(color: UIColor.primaryColor, fontSize: 14)),
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
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(12),
            child: Icon(icon, size: 35, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
