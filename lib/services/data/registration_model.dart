import 'package:intl/intl.dart';

class Registration {
  final int registId;
  final bool? isPresent;
  final String registrationTime;
  final String username;
  final int eventId;
  final String title;
  final String poster;
  final String description;
  final String dateStart;
  final String dateEnd;
  final String location;
  final String place;
  final int categoryId;
  final String categoryName;
  final int quota;

  const Registration({
    required this.registId,
    this.isPresent,
    required this.registrationTime,
    required this.username,
    required this.eventId,
    required this.title,
    required this.poster,
    required this.description,
    required this.dateStart,
    required this.dateEnd,
    required this.location,
    required this.place,
    required this.categoryId,
    required this.categoryName,
    required this.quota,
  });

  // Factory method untuk membuat objek dari JSON
  factory Registration.fromJson(Map<String, dynamic> json) {
    return Registration(
      registId: _parseIntSafely(json['regist_id']),
      isPresent: json['is_present'] == null
          ? null
          : _parseBoolSafely(json['is_present']),
      registrationTime: _parseStringSafely(json['registration_time']),
      username: _parseStringSafely(json['username']),
      eventId: _parseIntSafely(json['event_id']),
      title: _parseStringSafely(json['title']),
      poster: _parseStringSafely(json['poster']),
      description: _parseStringSafely(json['description']),
      dateStart: _parseStringSafely(json['date_start']),
      dateEnd: _parseStringSafely(json['date_end']),
      location: _parseStringSafely(json['location']),
      place: _parseStringSafely(json['place']),
      categoryId: _parseIntSafely(json['category_id']),
      categoryName: _parseStringSafely(json['category_name']),
      quota: _parseIntSafely(json['quota']),
    );
  }

  // Metode pembantu untuk parsing aman
  static int _parseIntSafely(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    return int.tryParse(value.toString()) ?? defaultValue;
  }

  static String _parseStringSafely(dynamic value, {String defaultValue = ''}) {
    return value?.toString() ?? defaultValue;
  }

  static bool _parseBoolSafely(dynamic value, {bool defaultValue = false}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    return value.toString().toLowerCase() == 'true';
  }

  // Method untuk mendapatkan status kehadiran
  String getAttendanceStatus() {
    if (isPresent == null) {
      return 'Belum Dikonfirmasi';
    }
    return isPresent! ? 'Hadir' : 'Tidak Hadir';
  }

  // Method untuk mengecek apakah event sudah berlalu
  bool isEventPassed() {
    final endDate = DateTime.parse(dateEnd);
    return endDate.isBefore(DateTime.now());
  }

  // Method untuk format tanggal mulai
  String getFormattedStartDate() {
    try {
      final date = DateTime.parse(dateStart);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateStart;
    }
  }

  // Method untuk format tanggal selesai
  String getFormattedEndDate() {
    try {
      final date = DateTime.parse(dateEnd);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateEnd;
    }
  }

  // Override toString untuk debugging
  @override
  String toString() {
    return 'Registration(registId: $registId, title: $title, eventId: $eventId)';
  }
}

// Extension untuk parsing list registrasi dari JSON
extension RegistrationListParser on List<dynamic> {
  List<Registration> parseRegistrations() {
    return map((json) => Registration.fromJson(json)).toList();
  }
}
