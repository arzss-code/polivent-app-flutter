import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/events_model.dart';

class ApiService {
  final String baseUrl = 'http://localhost/api-polyvent'; // Base URL API Anda

  // Fungsi untuk mengambil daftar event dari API
  Future<List<Event>> getEvents() async {
    final response = await http.get(Uri.parse('$baseUrl/events'));

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
    final response = await http.get(Uri.parse('$baseUrl/events/$eventId'));

    if (response.statusCode == 200) {
      // Mengonversi response menjadi objek Event
      return Event.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load event details');
    }
  }
}
