import 'package:shared_preferences/shared_preferences.dart';
import 'package:polivent_app/services/data/interest_model.dart';
import 'dart:convert';

class InterestsService {
  static const String _interestsKey = 'user_interests';

  // Simpan interests ke local storage
  Future<void> saveUserInterests(List<Interest> interests) async {
    final prefs = await SharedPreferences.getInstance();
    final interestsJson =
        interests.map((interest) => interest.toJson()).toList();
    await prefs.setString(_interestsKey, json.encode(interestsJson));
  }

  // Load interests dari local storage
  Future<List<Interest>> getUserInterests() async {
    final prefs = await SharedPreferences.getInstance();
    final interestsJson = prefs.getString(_interestsKey);

    if (interestsJson != null) {
      final List<dynamic> decoded = json.decode(interestsJson);
      return decoded.map((json) => Interest.fromJson(json)).toList();
    }
    return [];
  }

  // Hapus semua interests
  Future<void> clearUserInterests() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_interestsKey);
  }
}
