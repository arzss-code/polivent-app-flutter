import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:polivent_app/config/app_config.dart';
import 'package:polivent_app/models/data/category_model.dart';
import 'package:polivent_app/models/data/registration_model.dart';
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

Future<bool> joinEvent(int userId, int eventId) async {
  final response = await http.post(
    Uri.parse('$devApiBaseUrl/registration'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode(Registration(eventId: eventId, userId: userId).toJson()),
  );

  if (response.statusCode == 200) {
    return true; // Berhasil mendaftar
  } else {
    return false; // Gagal mendaftar
  }
}

Future<List<Category>> fetchCategories() async {
  try {
    final response = await http.get(
      Uri.parse('$devApiBaseUrl/categories'),
      headers: {
        'Content-Type': 'application/json',
        // Tambahkan headers lain seperti authorization jika diperlukan
        // 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      // Parse JSON array menjadi list kategori
      List<dynamic> body = json.decode(response.body);
      List<Category> categories =
          body.map((dynamic item) => Category.fromJson(item)).toList();
      return categories;
    } else {
      // Lempar exception jika status code bukan 200
      throw Exception('Failed to load categories: ${response.statusCode}');
    }
  } catch (e) {
    // Tangani error yang mungkin terjadi
    throw Exception('Error fetching categories: $e');
  }
}

// Metode untuk mengambil kategori berdasarkan ID
Future<Category> fetchCategoryById(int categoryId) async {
  try {
    final response = await http.get(
      Uri.parse('$devApiBaseUrl/categories/$categoryId'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Parse JSON menjadi objek Category
      return Category.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load category: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching category: $e');
  }
}

// Metode untuk membuat kategori baru
Future<Category> createCategory(Category category) async {
  try {
    final response = await http.post(
      Uri.parse('$devApiBaseUrl/categories'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(category.toJson()),
    );

    if (response.statusCode == 201) {
      // Parse response dan kembalikan kategori yang baru dibuat
      return Category.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create category: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error creating category: $e');
  }
}

// Metode untuk mengupdate kategori
Future<Category> updateCategory(Category category) async {
  try {
    final response = await http.put(
      Uri.parse('$devApiBaseUrl/categories/${category.categoryId}'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(category.toJson()),
    );

    if (response.statusCode == 200) {
      // Parse response dan kembalikan kategori yang diupdate
      return Category.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update category: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error updating category: $e');
  }
}

// Metode untuk menghapus kategori
Future<bool> deleteCategory(int categoryId) async {
  try {
    final response = await http.delete(
      Uri.parse('$devApiBaseUrl/categories/$categoryId'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return true; // Berhasil dihapus
    } else {
      throw Exception('Failed to delete category: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error deleting category: $e');
  }
}


