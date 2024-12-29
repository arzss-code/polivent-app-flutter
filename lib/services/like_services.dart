import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:polivent_app/config/app_config.dart';
import 'package:polivent_app/services/auth_services.dart';
import 'package:polivent_app/services/token_service.dart';

class LikeService {
  Future<Map<String, dynamic>> checkLikeStatus(int eventId) async {
    try {
      final authService = AuthService();
      final userData = await authService.getUserData();

      if (userData == null) {
        return {'is_liked': false, 'like_id': null};
      }

      final accessToken = await TokenService.getAccessToken();

      if (accessToken == null) {
        return {'is_liked': false, 'like_id': null};
      }

      final response = await http.get(
        Uri.parse(
            '$prodApiBaseUrl/likes?event_id=$eventId&user_id=${userData.userId}'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Pastikan struktur data sesuai
        if (responseData['data'] != null) {
          return {
            'is_liked': responseData['data']['is_liked'] ?? false,
            'like_id': responseData['data']['like_id']
          };
        }
      }

      return {'is_liked': false, 'like_id': null};
    } catch (e) {
      print('Error checking like status: $e');
      return {'is_liked': false, 'like_id': null};
    }
  }

  Future<Map<String, dynamic>> toggleLike(int eventId) async {
    try {
      final authService = AuthService();
      final userData = await authService.getUserData();

      if (userData == null) {
        return {'success': false, 'is_liked': false, 'like_id': null};
      }

      final accessToken = await TokenService.getAccessToken();

      if (accessToken == null) {
        return {'success': false, 'is_liked': false, 'like_id': null};
      }

      // Ambil status like saat ini
      final currentLikeStatus = await checkLikeStatus(eventId);

      http.Response response;
      bool isLiked;
      int? likeId;

      if (currentLikeStatus['is_liked']) {
        // Unlike - Gunakan like_id untuk menghapus
        response = await http.delete(
          Uri.parse('$prodApiBaseUrl/likes/${currentLikeStatus['like_id']}'),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        );
        isLiked = false;
        likeId = null;
      } else {
        // Like
        response = await http.post(
          Uri.parse('$prodApiBaseUrl/likes'),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'user_id': userData.userId,
            'event_id': eventId,
          }),
        );

        // Parse like_id dari response
        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          likeId = responseData['data']['like_id'];
        }

        isLiked = true;
      }

      return {
        'success': response.statusCode == 200,
        'is_liked': isLiked,
        'like_id': likeId
      };
    } catch (e) {
      print('Error toggling like: $e');
      return {'success': false, 'is_liked': false, 'like_id': null};
    }
  }
}
