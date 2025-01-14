import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:polivent_app/config/app_config.dart';
import 'package:polivent_app/services/auth_services.dart';
import 'package:polivent_app/services/data/comment_model.dart';
import 'package:polivent_app/services/token_service.dart';

// Layanan untuk mengelola operasi terkait komentar
class CommentService {
  final AuthService _authService = AuthService();

  // Mengambil komentar berdasarkan ID event
  Future<List<CommentModel>> getCommentsByEventId(int eventId) async {
    try {
      final accessToken = await TokenService.getAccessToken();
      final response = await http.get(
        Uri.parse('$prodApiBaseUrl/comments?event_id=$eventId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['status'] == 'success') {
          final List<dynamic> commentsData = responseData['data'];

          // Filter dan buat daftar komentar utama
          List<CommentModel> comments = commentsData
              .where((comment) => comment['comment_parent_id'] == null)
              .map<CommentModel>((comment) {
            final commentModel = CommentModel.fromJson(comment);
            return commentModel;
          }).toList();

          // Dapatkan balasan untuk setiap komentar
          for (var comment in comments) {
            comment.replies = await getRepliesByCommentId(comment.commentId);
          }

          return comments;
        }
        return [];
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching comments: $e');
      return [];
    }
  }

  // Mengambil balasan komentar berdasarkan ID komentar induk
  Future<List<CommentModel>> getRepliesByCommentId(int commentId) async {
    try {
      final accessToken = await TokenService.getAccessToken();
      final response = await http.get(
        Uri.parse('$prodApiBaseUrl/comments?comment_parent_id=$commentId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['status'] == 'success') {
          final List<dynamic> repliesData = responseData['data'];

          // Buat list untuk menyimpan semua replies
          List<CommentModel> replies = [];

          // Konversi replies menjadi CommentModel
          for (var replyData in repliesData) {
            final reply = CommentModel.fromJson(replyData);

            // Dapatkan sub-replies untuk setiap reply
            reply.replies = await getRepliesByCommentId(reply.commentId);

            replies.add(reply);
          }

          return replies;
        }
        return [];
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching replies: $e');
      return [];
    }
  }

  // Membuat komentar baru
  Future<CommentModel?> createComment({
    required int eventId,
    required String content,
    int? parentCommentId,
  }) async {
    try {
      final userData = await _authService.getUserData();
      final accessToken = await TokenService.getAccessToken();

      if (userData == null || accessToken == null) {
        return null;
      }

      final response = await http.post(
        Uri.parse('$prodApiBaseUrl/comments'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'user_id': userData.userId,
          'event_id': eventId,
          'content': content,
          'comment_parent_id': parentCommentId,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['status'] == 'success') {
          return CommentModel.fromJson(responseData['data']);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error creating comment: $e');
      return null;
    }
  }
}
