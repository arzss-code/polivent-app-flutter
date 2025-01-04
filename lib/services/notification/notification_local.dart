import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationItem {
  final String title;
  final String message;
  final DateTime time;
  final NotificationType type;
  bool isNew;

  NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    this.isNew = true,
  });

  // Konversi ke Map
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'message': message,
      'time': time.toIso8601String(),
      'type': type.toString().split('.').last,
      'isNew': isNew,
    };
  }

  // Buat dari Map
  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      time: DateTime.parse(json['time'] ?? DateTime.now().toIso8601String()),
      type: NotificationType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => NotificationType.info,
      ),
      isNew: json['isNew'] ?? true,
    );
  }
}

enum NotificationType {
  success,
  error,
  warning,
  info, reminder,
}

class LocalNotificationService {
  static const String _notificationKey = 'notifications';
  static const int _maxNotifications = 50; // Batasi jumlah notifikasi

  // Tambahkan notifikasi
  static Future<void> addNotification({
    required String title,
    required String message,
    NotificationType type = NotificationType.info,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Buat notifikasi baru
      final notificationItem = NotificationItem(
        title: title,
        message: message,
        time: DateTime.now(),
        type: type,
        isNew: true,
      );

      // Ambil daftar notifikasi yang sudah ada
      List<String> savedNotifications =
          prefs.getStringList(_notificationKey) ?? [];

      // Konversi notifikasi ke JSON
      String notificationJson = json.encode(notificationItem.toJson());

      // Tambahkan notifikasi baru di awal list
      savedNotifications.insert(0, notificationJson);

      // Batasi jumlah notifikasi
      if (savedNotifications.length > _maxNotifications) {
        savedNotifications =
            savedNotifications.take(_maxNotifications).toList();
      }

      // Simpan kembali ke SharedPreferences
      await prefs.setStringList(_notificationKey, savedNotifications);
    } catch (e) {
      debugPrint('Gagal menyimpan notifikasi: $e');
    }
  }

  // Ambil semua notifikasi
  static Future<List<NotificationItem>> getNotifications() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? savedNotifications = prefs.getStringList(_notificationKey);

      if (savedNotifications == null) return [];

      return savedNotifications
          .map((jsonString) =>
              NotificationItem.fromJson(json.decode(jsonString)))
          .toList();
    } catch (e) {
      debugPrint('Gagal mengambil notifikasi: $e');
      return [];
    }
  }

  // Tandai semua notifikasi sebagai sudah dibaca
  static Future<void> markAllNotificationsAsRead() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? savedNotifications = prefs.getStringList(_notificationKey);

      if (savedNotifications != null) {
        // Update setiap notifikasi
        List<String> updatedNotifications =
            savedNotifications.map((jsonString) {
          Map<String, dynamic> notificationMap = json.decode(jsonString);
          notificationMap['isNew'] = false;
          return json.encode(notificationMap);
        }).toList();

        // Simpan kembali
        await prefs.setStringList(_notificationKey, updatedNotifications);
      }
    } catch (e) {
      debugPrint('Gagal menandai notifikasi sebagai dibaca: $e');
    }
  }

  // Hitung notifikasi yang belum dibaca
  static Future<int> getUnreadNotificationCount() async {
    try {
      List<NotificationItem> notifications = await getNotifications();
      return notifications.where((notification) => notification.isNew).length;
    } catch (e) {
      debugPrint('Gagal menghitung notifikasi yang belum dibaca: $e');
      return 0;
    }
  }

  // Hapus semua notifikasi
  static Future<void> clearAllNotifications() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(_notificationKey);
    } catch (e) {
      debugPrint('Gagal menghapus notifikasi: $e');
    }
  }

  // Hapus notifikasi lama
  static Future<void> removeOldNotifications({int days = 30}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? savedNotifications = prefs.getStringList(_notificationKey);

      if (savedNotifications != null) {
        // Filter notifikasi yang tidak lebih tua dari jumlah hari yang ditentukan
        final cutoffDate = DateTime.now().subtract(Duration(days: days));

        List<String> filteredNotifications =
            savedNotifications.where((jsonString) {
          try {
            final notification =
                NotificationItem.fromJson(json.decode(jsonString));
            return notification.time.isAfter(cutoffDate);
          } catch (e) {
            return false;
          }
        }).toList();

        // Simpan kembali
        await prefs.setStringList(_notificationKey, filteredNotifications);
      }
    } catch (e) {
      debugPrint('Gagal menghapus notifikasi lama: $e');
    }
  }
}
