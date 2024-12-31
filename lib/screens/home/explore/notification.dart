import 'dart:async';
import 'dart:convert';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:polivent_app/models/ui_colors.dart';
import 'package:polivent_app/services/notifikasi/notification_local.dart';
import 'package:polivent_app/services/notifikasi/notification_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<NotificationItem> notifications = [];
  bool _notificationsEnabled = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationPreference();
    _loadNotifications();
    _initNotificationListeners();
  }

  Future<void> _fetchNotifications() async {
    try {
      setState(() {
        _isLoading = true;
      });

      notifications = await LocalNotificationService.getNotifications();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat notifikasi: $e')),
      );
    }
  }

  void _initNotificationListeners() {
    // Gunakan metode setListeners
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: _onActionReceivedMethod,
      onNotificationCreatedMethod: _onNotificationCreatedMethod,
      onNotificationDisplayedMethod: _onNotificationDisplayedMethod,
    );
  }

  @pragma("vm:entry-point")
  static Future<void> _onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    // Simpan notifikasi ke SharedPreferences
    await _saveNotificationFromAction(receivedAction);
  }

  static Future<void> _saveNotificationFromAction(
      ReceivedAction receivedAction) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Ambil daftar notifikasi yang sudah ada
    List<String>? savedNotifications =
        prefs.getStringList('notifications') ?? [];

    // Buat NotificationItem dari ReceivedAction
    final notificationItem = {
      'title': receivedAction.title ?? 'Notifikasi',
      'message': receivedAction.body ?? '',
      'time': DateTime.now().toIso8601String(),
      'type': receivedAction.payload?['type'] ?? 'info',
      'isNew': true,
    };

    // Tambahkan notifikasi baru
    savedNotifications.insert(0, json.encode(notificationItem));

    // Simpan kembali ke SharedPreferences
    await prefs.setStringList('notifications', savedNotifications);
  }

  Future<void> _markNotificationAsRead(NotificationItem notification) async {
    notification.isNew = false;
    await LocalNotificationService.addNotification(
      title: notification.title,
      message: notification.message,
      type: notification.type,
    );
    setState(() {
      // Update tampilan
    });
  }

  @pragma("vm:entry-point")
  static Future<void> _onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    debugPrint('Notifikasi Dibuat: ${receivedNotification.id}');
  }

  @pragma("vm:entry-point")
  static Future<void> _onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    debugPrint('Notifikasi Ditampilkan: ${receivedNotification.id}');
  }

  NotificationType _getNotificationType(String type) {
    switch (type) {
      case 'event_registration':
        return NotificationType.success;
      case 'event_reminder':
        return NotificationType.reminder;
      case 'info':
        return NotificationType.info;
      case 'error':
        return NotificationType.error;
      default:
        return NotificationType.info;
    }
  }

  void _loadNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedNotifications = prefs.getStringList('notifications');

    if (savedNotifications != null) {
      setState(() {
        notifications = savedNotifications.map((jsonString) {
          final Map<String, dynamic> map = json.decode(jsonString);
          return NotificationItem(
            title: map['title'],
            message: map['message'],
            time: DateTime.parse(map['time']),
            type: _getNotificationType(map['type']),
            isNew: map['isNew'] ?? true,
          );
        }).toList();
      });
    }
  }

  void _saveNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> notificationJsonList = notifications.map((notification) {
      return json.encode({
        'title': notification.title,
        'message': notification.message,
        'time': notification.time.toIso8601String(),
        'type': notification.type.toString().split('.').last,
        'isNew': notification.isNew,
      });
    }).toList();

    await prefs.setStringList('notifications', notificationJsonList);
  }

  void _loadNotificationPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    });
  }

  void removeNotification(int index) {
    setState(() {
      notifications.removeAt(index);
      _saveNotifications();
    });
  }

  void _clearAllNotifications() {
    setState(() async {
      notifications.clear();
      _saveNotifications();
      await LocalNotificationService.clearAllNotifications();
      _fetchNotifications();
    });
    // Gunakan method dari NotificationService untuk menghapus notifikasi sistem
    NotificationService.cancelAll();
  }

  @override
  void dispose() {
    super.dispose();
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
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.red),
            onPressed: _clearAllNotifications,
            tooltip: 'Hapus Semua Notifikasi',
          ),
        ],
      ),
      body: !_notificationsEnabled
          ? const Center(
              child: Text(
                'Notifikasi dinonaktifkan',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : notifications.isEmpty
              ? const EmptyNotification()
              : ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    return Dismissible(
                      key: Key(notifications[index].title + index.toString()),
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

// Sisanya tetap sama seperti implementasi sebelumnya
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

// NotificationCard dan NotificationItem tetap sama seperti sebelumnya

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
      case NotificationType.warning:
        iconData = Icons.warning;
        color = Colors.orange;
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

// class NotificationItem {
//   final String title;
//   final String message;
//   final DateTime time;
//   final NotificationType type;
//   final bool isNew;

//   NotificationItem({
//     required this.title,
//     required this.message,
//     required this.time,
//     required this.type,
//     required this.isNew,
//   });
// }

// enum NotificationType { reminder, success, info, error }
