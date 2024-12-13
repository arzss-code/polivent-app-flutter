// user_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/data/user_model.dart';

final userProvider = FutureProvider<List<User>>((ref) async {
  final response =
      await http.get(Uri.parse('https://polivent.my.id/rest-api/users'));

  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);
    return data.map((user) => User.fromJson(user)).toList();
  } else {
    throw Exception('Failed to load users');
  }
});
