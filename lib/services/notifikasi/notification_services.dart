import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:polivent_app/config/app_config.dart';
import 'package:polivent_app/models/ui_colors.dart';
import 'package:polivent_app/screens/home/explore/notification.dart';
import 'package:polivent_app/services/data/events_model.dart';
import 'package:polivent_app/services/data/user_model.dart';
import 'package:polivent_app/services/event_services.dart';
import 'package:polivent_app/services/notifikasi/notification_local.dart';
import 'package:polivent_app/services/token_service.dart';
import 'package:http/http.dart' as http;

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
    NotificationSchedule? schedule, // Tambahkan parameter ini
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
      schedule: schedule, // Tambahkan schedule di sini
    );
  }

  // Tambahkan metode untuk menyimpan notifikasi ke lokal
  static Future<void> saveNotificationToLocal({
    required String title,
    required String body,
    required Map<String, dynamic> payload,
  }) async {
    try {
      // Pilih tipe notifikasi berdasarkan payload
      NotificationType type = _determineNotificationType(payload);

      // Simpan ke penyimpanan lokal
      await LocalNotificationService.addNotification(
        title: title,
        message: body,
        type: type,
      );
    } catch (e) {
      debugPrint('Gagal menyimpan notifikasi lokal: $e');
    }
  }

// Tentukan tipe notifikasi berdasarkan payload
  static NotificationType _determineNotificationType(
      Map<String, dynamic> payload) {
    final type = payload['type']?.toString().toLowerCase();
    switch (type) {
      case 'success':
        return NotificationType.success;
      case 'error':
        return NotificationType.error;
      case 'warning':
        return NotificationType.warning;
      default:
        return NotificationType.info;
    }
  }

  // Method khusus untuk notifikasi keberhasilan absensi
  static Future<void> sendEventAttendanceNotification({
    required int eventId,
    required String eventTitle,
  }) async {
    await NotificationService.showGeneralNotification(
      title: 'Absensi Berhasil',
      body: 'Anda telah berhasil absen pada event id $eventId',
      payload: {
        'event_id': eventId.toString(),
        'type': 'event_attendance',
        'event_title': eventTitle,
      },
    );

    // Opsional: Tambahkan badge atau pencapaian
    try {} catch (e) {
      debugPrint('Gagal memperbarui badge: $e');
    }
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

class EventNotificationService {
  // Kirim notifikasi keberhasilan absensi
  static Future<void> sendEventAttendanceNotification({
    required Event event,
    required User user,
  }) async {
    try {
      // Kirim notifikasi dengan detail event yang spesifik
      await NotificationService.showGeneralNotification(
        title: 'Absensi Berhasil, ${user.username}!',
        body: 'Anda telah berhasil absen pada event "${event.title}"',
        payload: {
          'event_id': event.eventId.toString(),
          'type': 'event_attendance',
          'event_title': event.title,
          'event_location': event.location,
          'event_date': event.dateStart,
        },
      );

      // Rekam analitik kehadiran
      await _recordAttendanceAnalytics(event, user);
    } catch (e) {
      debugPrint('Gagal mengirim notifikasi absensi: $e');
    }
  }

  // Rekam analitik kehadiran
  static Future<void> _recordAttendanceAnalytics(Event event, User user) async {
    try {
      final accessToken = await TokenService.getAccessToken();

      await http.post(
        Uri.parse('$prodApiBaseUrl/analytics/attendance'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'event_id': event.eventId,
          'event_title': event.title,
          'user_id': user.userId,
          'username': user.username,
          'attendance_timestamp': DateTime.now().toIso8601String(),
          'event_details': {
            'location': event.location,
            'place': event.place,
            'date_start': event.dateStart,
            'date_end': event.dateEnd,
          },
        }),
      );
    } catch (e) {
      debugPrint('Gagal merekam analitik kehadiran: $e');
    }
  }

  // Kirim notifikasi pengingat event
  static Future<void> sendEventReminderNotification({
    required Event event,
    required User user,
    int daysBeforeEvent = 1,
  }) async {
    try {
      final eventStartDate = DateTime.parse(event.dateStart);
      final reminderDate =
          eventStartDate.subtract(Duration(days: daysBeforeEvent));

      await NotificationService.showGeneralNotification(
        title: 'Pengingat Event: ${event.title}',
        body: 'Event "${event.title}" akan dimulai dalam $daysBeforeEvent hari',
        payload: {
          'event_id': event.eventId.toString(),
          'type': 'event_reminder',
          'event_title': event.title,
          'event_location': event.location,
          'event_date': event.dateStart,
        },
        schedule: NotificationCalendar.fromDate(date: reminderDate),
      );
    } catch (e) {
      debugPrint('Gagal mengirim pengingat event: $e');
    }
  }

  // Kirim notifikasi status event
  static Future<void> sendEventStatusNotification({
    required Event event,
    required String status,
    String? additionalMessage,
  }) async {
    try {
      await NotificationService.showGeneralNotification(
        title: 'Update Status Event: ${event.title}',
        body: additionalMessage ??
            'Status event telah diperbarui menjadi $status',
        payload: {
          'event_id': event.eventId.toString(),
          'type': 'event_status_update',
          'event_title': event.title,
          'status': status,
        },
      );
    } catch (e) {
      debugPrint('Gagal mengirim notifikasi status event: $e');
    }
  }

  // Ambil statistik kehadiran pengguna
  static Future<UserAttendanceStats> getUserAttendanceStats(
      String userId) async {
    try {
      final accessToken = await TokenService.getAccessToken();
      final response = await http.get(
        Uri.parse('$prodApiBaseUrl/user/$userId/attendance-stats'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return UserAttendanceStats.fromJson(data);
      } else {
        throw Exception('Gagal mengambil statistik kehadiran');
      }
    } catch (e) {
      debugPrint('Error fetching attendance stats: $e');
      rethrow;
    }
  }
}

// Model untuk statistik kehadiran pengguna
class UserAttendanceStats {
  final int totalEventsAttended;
  final int uniqueEventsAttended;
  final double attendancePercentage;
  final List<AttendedEvent> recentEvents;

  UserAttendanceStats({
    required this.totalEventsAttended,
    required this.uniqueEventsAttended,
    required this.attendancePercentage,
    required this.recentEvents,
  });

  factory UserAttendanceStats.fromJson(Map<String, dynamic> json) {
    return UserAttendanceStats(
      totalEventsAttended: json['total_events_attended'] ?? 0,
      uniqueEventsAttended: json['unique_events_attended'] ?? 0,
      attendancePercentage: (json['attendance_percentage'] ?? 0.0).toDouble(),
      recentEvents: (json['recent_events'] as List?)
              ?.map((e) => AttendedEvent.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class AttendedEvent {
  final int eventId;
  final String eventTitle;
  final DateTime attendanceDate;
  final String location;

  AttendedEvent({
    required this.eventId,
    required this.eventTitle,
    required this.attendanceDate,
    required this.location,
  });

  factory AttendedEvent.fromJson(Map<String, dynamic> json) {
    return AttendedEvent(
      eventId: int.parse(json['event_id'].toString()),
      eventTitle: json['event_title'].toString(),
      attendanceDate: DateTime.parse(json['attendance_date'].toString()),
      location: json['location'].toString(),
    );
  }
}
