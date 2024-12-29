import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
// import 'package:polivent_app/models/events_model.dart';
import 'package:polivent_app/services/data/events_model.dart';
import 'package:polivent_app/services/token_service.dart';
import 'package:polivent_app/config/app_config.dart';

class EventService {
  // Base URL untuk API events
  static const String _baseUrl = '$prodApiBaseUrl/available_events';

  // Mendapatkan daftar event
  Future<List<Event>> getEvents({
    int page = 1,
    int limit = 10,
    String? category,
    String? search,
  }) async {
    try {
      // Bangun query parameters
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (category != null) 'category': category,
        if (search != null) 'search': search,
      };

      final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer ${await TokenService.getAccessToken()}',
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Request timeout'),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        // Pastikan response memiliki list events
        if (jsonResponse is Map && jsonResponse.containsKey('events')) {
          final eventsList = (jsonResponse['events'] as List)
              .map((eventJson) => Event.fromJson(eventJson))
              .toList();
          return eventsList;
        } else if (jsonResponse is List) {
          return jsonResponse
              .map((eventJson) => Event.fromJson(eventJson))
              .toList();
        }

        throw Exception('Invalid response format');
      } else {
        throw Exception('Failed to load events: ${response.body}');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on TimeoutException {
      throw Exception('Request timeout');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Mendapatkan detail event berdasarkan ID
  Future<Event> getEventById(int eventId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$eventId'),
        headers: {
          'Authorization': 'Bearer ${await TokenService.getAccessToken()}',
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Request timeout'),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        // Pastikan response adalah object event
        if (jsonResponse is Map) {
          return Event.fromJson(jsonResponse as Map<String, dynamic>);
        }

        throw Exception('Invalid response format');
      } else {
        throw Exception('Failed to load event details: ${response.body}');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on TimeoutException {
      throw Exception('Request timeout');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Mendaftarkan event
  Future<Map<String, dynamic>> registerForEvent(int eventId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/$eventId/register'),
        headers: {
          'Authorization': 'Bearer ${await TokenService.getAccessToken()}',
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Request timeout'),
      );

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'Berhasil mendaftar event',
          'registrationId': jsonResponse['registration_id'],
        };
      } else {
        return {
          'success': false,
          'message': jsonResponse['message'] ?? 'Gagal mendaftar event',
        };
      }
    } on SocketException {
      return {
        'success': false,
        'message': 'Tidak ada koneksi internet',
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Permintaan memakan waktu terlalu lama',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Mendapatkan event yang sudah didaftar pengguna
  Future<List<Event>> getUserRegisteredEvents() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/registered'),
        headers: {
          'Authorization': 'Bearer ${await TokenService.getAccessToken()}',
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Request timeout'),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        // Pastikan response memiliki list events
        if (jsonResponse is Map && jsonResponse.containsKey('events')) {
          final eventsList = (jsonResponse['events'] as List)
              .map((eventJson) => Event.fromJson(eventJson))
              .toList();
          return eventsList;
        } else if (jsonResponse is List) {
          return jsonResponse
              .map((eventJson) => Event.fromJson(eventJson))
              .toList();
        }

        throw Exception('Invalid response format');
      } else {
        throw Exception('Failed to load registered events: ${response.body}');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on TimeoutException {
      throw Exception('Request timeout');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Membatalkan pendaftaran event
  Future<Map<String, dynamic>> cancelEventRegistration(
      int registrationId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/registrations/$registrationId'),
        headers: {
          'Authorization': 'Bearer ${await TokenService.getAccessToken()}',
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Request timeout'),
      );

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message':
              jsonResponse['message'] ?? 'Berhasil membatalkan pendaftaran',
        };
      } else {
        return {
          'success': false,
          'message': jsonResponse['message'] ?? 'Gagal membatalkan pendaftaran',
        };
      }
    } on SocketException {
      return {
        'success': false,
        'message': 'Tidak ada koneksi internet',
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Permintaan memakan waktu terlalu lama',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }

  // Pencarian event
  Future<List<Event>> searchEvents(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/search?query=$query'),
        headers: {
          'Authorization': 'Bearer ${await TokenService.getAccessToken()}',
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Request timeout'),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        // Pastikan response memiliki list events
        if (jsonResponse is Map && jsonResponse.containsKey('events')) {
          final eventsList = (jsonResponse['events'] as List)
              .map((eventJson) => Event.fromJson(eventJson))
              .toList();
          return eventsList;
        } else if (jsonResponse is List) {
          return jsonResponse
              .map((eventJson) => Event.fromJson(eventJson))
              .toList();
        }

        throw Exception('Invalid response format');
      } else {
        throw Exception('Failed to search events: ${response.body}');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on TimeoutException {
      throw Exception('Request timeout');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
