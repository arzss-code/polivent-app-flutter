import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:polivent_app/models/ui_colors.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<NotificationItem> notifications = [
    NotificationItem(
      title: 'Pengingat Event',
      message: 'Event "Workshop UI/UX" akan dimulai dalam 1 jam',
      time: DateTime.now().add(const Duration(hours: 1)),
      type: NotificationType.reminder,
      isNew: true,
    ),
    NotificationItem(
      title: 'Pendaftaran Berhasil',
      message: 'Anda telah berhasil mendaftar pada event "Seminar Teknologi"',
      time: DateTime.now().subtract(const Duration(hours: 2)),
      type: NotificationType.success,
      isNew: false,
    ),
    // Tambahkan notifikasi lain sesuai kebutuhan
  ];

  void removeNotification(int index) {
    setState(() {
      notifications.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: UIColor.solidWhite,
        scrolledUnderElevation: 0,
        title: const Text(
          "Notifikasi",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: UIColor.typoBlack,
          ),
        ),
      ),
      body: notifications.isEmpty
          ? const EmptyNotification()
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key(notifications[index].title),
                  onDismissed: (direction) {
                    removeNotification(index);
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20.0),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: NotificationCard(
                    title: notifications[index].title,
                    message: notifications[index].message,
                    time: notifications[index].time,
                    type: notifications[index].type,
                    isNew: notifications[index].isNew,
                  ),
                );
              },
            ),
    );
  }
}

class EmptyNotification extends StatelessWidget {
  const EmptyNotification({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/no-notification.png',
            width: 200,
            height: 200,
          ),
          const Text(
            'Belum Ada Notifikasi',
            style: TextStyle(
              color: UIColor.primaryColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Anda belum memiliki notifikasi apapun saat ini',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String title;
  final String message;
  final DateTime time;
  final NotificationType type;
  final bool isNew;

  const NotificationCard({
    super.key,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    required this.isNew,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Card(
        color: isNew ? Colors.blue.shade50 : Colors.white,
        elevation: 1,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIcon(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: UIColor.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd MMM yyyy, HH:mm').format(time),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    IconData iconData;
    Color color;

    switch (type) {
      case NotificationType.reminder:
        iconData = Icons.event;
        color = UIColor.primaryColor;
        break;
      case NotificationType.success:
        iconData = Icons.check_circle;
        color = Colors.green;
        break;
      case NotificationType.info:
        iconData = Icons.info;
        color = Colors.blue;
        break;
      case NotificationType.error:
        iconData = Icons.error;
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: color, size: 24),
    );
  }
}

class NotificationItem {
  final String title;
  final String message;
  final DateTime time;
  final NotificationType type;
  final bool isNew;

  NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    required this.isNew,
  });
}

enum NotificationType { reminder, success, info, error }

// EmptyNotification class remains the same