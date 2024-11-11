import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:polivent_app/config/app_config.dart';
import 'package:polivent_app/models/data/user_model.dart';
import '../models/data/events_model.dart';

// Fungsi untuk mengambil daftar event dari API
Future<List<Event>> getEvents() async {
  final response = await http.get(Uri.parse('$devApiBaseUrl/events'));

  if (response.statusCode == 200) {
    List<dynamic> body = jsonDecode(response.body);
    List<Event> events =
        body.map((dynamic item) => Event.fromJson(item)).toList();
    return events;
  } else {
    throw Exception('Failed to load events');
  }
}

// Fungsi untuk mengambil detail event berdasarkan event ID
Future<Event> getEventByID(int eventId) async {
  final response = await http.get(Uri.parse('$devApiBaseUrl/events/$eventId'));

  if (response.statusCode == 200) {
    // Mengonversi response menjadi objek Event
    return Event.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load event details');
  }
}

const storage = FlutterSecureStorage();

// Fungsi untuk mendapatkan data pengguna dengan token yang disimpan
Future<User?> fetchUserDataWithToken() async {
  final token =
      await storage.read(key: 'jwt_token'); // Membaca token dari storage

  if (token == null) {
    print('No token found');
    return null;
  }

  final response = await http.get(
    Uri.parse(
        '$devApiBaseUrl/users?profile=true'), // Ganti dengan URL endpoint API Anda
    headers: {
      'Authorization':
          'Bearer $token', // Menyertakan token dalam header Authorization
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    // Parsing data pengguna dari response JSON
    return User.fromJson(jsonResponse);
  } else {
    print('Failed to load user data');
    return null;
  }
}
