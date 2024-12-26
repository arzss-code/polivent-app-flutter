import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:polivent_app/models/ui_colors.dart';

class NotificationService {
  // Inisialisasi notifikasi
  static Future<void> initializeNotification() async {
    await AwesomeNotifications().initialize(
      'resource://drawable/notification_icon',
      [
        NotificationChannel(
          channelKey: 'event_channel',
          channelName: 'Event Notifications',
          channelDescription: 'Notifikasi untuk event',
          defaultColor: UIColor.primaryColor,
          ledColor: UIColor.primaryColor,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          defaultPrivacy: NotificationPrivacy.Public,
          enableVibration: true,
        ),
        NotificationChannel(
          channelKey: 'general_channel',
          channelName: 'General Notifications',
          channelDescription: 'Notifikasi umum aplikasi',
          defaultColor: UIColor.primaryColor,
          importance: NotificationImportance.Low,
          channelShowBadge: true,
        ),
      ],
      debug: true,
    );
  }

  // Menampilkan notifikasi event
  static Future<void> showEventNotification({
    required int eventId,
    required String eventTitle,
    required DateTime eventDate,
  }) async {
    // Notifikasi pendaftaran
    await AwesomeNotifications().createNotification(
      content: NotificationContent( 
        id: eventId,
        channelKey: 'event_channel',
        title: 'Pendaftaran Berhasil',
        body: 'Anda berhasil mendaftar event $eventTitle',
        icon: 'resource://drawable/notification_icon',
        color: UIColor.primaryColor,
        payload: {
          'event_id': eventId.toString(),
          'type': 'event_registration',
          'event_title': eventTitle,
        },
      ),
    );

    // Notifikasi pengingat event
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: eventId + 1000,
        channelKey: 'event_channel',
        title: 'Pengingat Event',
        body: 'Event $eventTitle akan dimulai besok',
        icon: 'resource://drawable/notification_icon',
        color: UIColor.primaryColor,
        payload: {
          'event_id': eventId.toString(),
          'type': 'event_reminder',
          'event_title': eventTitle,
        },
      ),
      schedule: NotificationCalendar.fromDate(
        date: eventDate.subtract(const Duration(days: 1)),
      ),
    );
  }

  // Menampilkan notifikasi umum
  static Future<void> showGeneralNotification({
    required String title,
    required String body,
    Map<String, String>? payload,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'general_channel',
        title: title,
        body: body,
        icon: 'resource://drawable/notification_icon',
        color: UIColor.primaryColor,
        payload: payload ??
            {
              'type': 'general_info',
            },
      ),
    );
  }

  // Request izin notifikasi
  static Future<void> requestNotificationPermissions() async {
    await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  // Cek status izin notifikasi
  static Future<bool> checkNotificationPermission() async {
    return await AwesomeNotifications().isNotificationAllowed();
  }

  // Buka pengaturan notifikasi
  static Future<void> openNotificationSettings() async {
    await AwesomeNotifications().showNotificationConfigPage();
  }

  // Batalkan semua notifikasi
  static Future<void> cancelAll() async {
    await AwesomeNotifications().cancelAll();
  }

  // Batalkan notifikasi spesifik
  static Future<void> cancelNotification(int id) async {
    await AwesomeNotifications().cancel(id);
  }

  // Atur listener untuk notifikasi
  static void setNotificationListeners({
    required Future<void> Function(ReceivedAction) onActionReceived,
    required Future<void> Function(ReceivedNotification) onNotificationCreated,
    required Future<void> Function(ReceivedNotification)
        onNotificationDisplayed,
  }) {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceived,
      onNotificationCreatedMethod: onNotificationCreated,
      onNotificationDisplayedMethod: onNotificationDisplayed,
    );
  }

  // Contoh method untuk jadwal notifikasi berulang
  static Future<void> scheduleRepeatingNotification({
    required int id,
    required String title,
    required String body,
    required NotificationSchedule schedule,
    String channelKey = 'general_channel',
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: channelKey,
        title: title,
        body: body,
        icon: 'resource://drawable/notification_icon',
        color: UIColor.primaryColor,
      ),
      schedule: schedule,
    );
  }

  // Buat jadwal notifikasi harian
  static NotificationSchedule createDailySchedule({
    required int hour,
    required int minute,
  }) {
    return NotificationCalendar(
      hour: hour,
      minute: minute,
      second: 0,
      repeats: true,
    );
  }

  // Buat jadwal notifikasi mingguan
  static NotificationSchedule createWeeklySchedule({
    required int weekday,
    required int hour,
    required int minute,
  }) {
    return NotificationCalendar(
      weekday: weekday,
      hour: hour,
      minute: minute,
      second: 0,
      repeats: true,
    );
  }
}
