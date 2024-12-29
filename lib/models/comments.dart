// ignore_for_file: unused_field

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:polivent_app/services/data/user_model.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:polivent_app/services/auth_services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:polivent_app/config/app_config.dart';
import 'package:polivent_app/services/token_service.dart';

class CommentModel {
  final int commentId;
  final int userId;
  final int eventId;
  final String content;
  final String username;
  final String avatar;
  final DateTime createdAt;
  final int? commentParentId;
  List<CommentModel>? replies;

  CommentModel({
    required this.commentId,
    required this.userId,
    required this.eventId,
    required this.content,
    required this.username,
    required this.avatar,
    required this.createdAt,
    this.commentParentId,
    this.replies,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      commentId: json['comment_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      eventId: json['event_id'] ?? 0,
      content: json['content'] ?? '',
      username: json['username'] ?? '',
      avatar: json['avatar'] ?? '',
      createdAt:
          DateTime.parse(json['created_at'] ?? DateTime.now().toString()),
      commentParentId: json['comment_parent_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'comment_id': commentId,
      'user_id': userId,
      'event_id': eventId,
      'content': content,
      'username': username,
      'avatar': avatar,
      'created_at': createdAt.toIso8601String(),
      'comment_parent_id': commentParentId,
    };
  }
}

class CommentService {
  final AuthService _authService = AuthService();

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

          List<CommentModel> comments = commentsData
              .where((comment) => comment['comment_parent_id'] == null)
              .map<CommentModel>((comment) {
            final commentModel = CommentModel.fromJson(comment);

            commentModel.replies = commentsData
                .where((reply) =>
                    reply['comment_parent_id'] == commentModel.commentId)
                .map((reply) => CommentModel.fromJson(reply))
                .toList();

            return commentModel;
          }).toList();

          return comments;
        }
        return [];
      }
      return [];
    } catch (e) {
      print('Error fetching comments: $e');
      return [];
    }
  }

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
      print('Error creating comment: $e');
      return null;
    }
  }
}

class CommentsSection extends StatefulWidget {
  final int eventId;

  const CommentsSection({Key? key, required this.eventId}) : super(key: key);

  @override
  _CommentsSectionState createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  final CommentService _commentService = CommentService();
  final TextEditingController _commentController = TextEditingController();
  final AuthService _authService = AuthService();

  List<CommentModel> _comments = [];
  bool _isLoading = true;
  bool _isReplying = false;
  CommentModel? _replyingToComment;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchComments();
  }

  Future<void> _fetchUserData() async {
    try {
      final userData = await _authService.getUserData();

      setState(() {
        _currentUser = userData;
      });
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _fetchComments() async {
    setState(() {
      _isLoading = true;
    });

    final comments = await _commentService.getCommentsByEventId(widget.eventId);

    setState(() {
      _comments = comments.reversed.toList();
      _isLoading = false;
    });
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final newComment = await _commentService.createComment(
      eventId: widget.eventId,
      content: _commentController.text.trim(),
      parentCommentId: _replyingToComment?.commentId,
    );

    if (newComment != null) {
      _commentController.clear();
      setState(() {
        _isReplying = false;
        _replyingToComment = null;
      });
      await _fetchComments();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send comment')),
      );
    }
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.transparent,
            child: ClipOval(
              child: _currentUser?.avatar != null
                  ? CachedNetworkImage(
                      imageUrl: _currentUser!.avatar,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) {
                        print('Image load error: $error');
                        return Image.asset(
                          "assets/images/default-avatar.jpg",
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  : Image.asset(
                      "assets/images/default-avatar.jpg",
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: _replyingToComment != null
                    ? 'Balas ${_replyingToComment!.username}...'
                    : 'Tulis komentar...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              ),
            ),
          ),
          IconButton(
            iconSize: 30,
            icon: const Icon(Icons.send_rounded),
            color: Colors.blue,
            onPressed: _submitComment,
          ),
        ],
      ),
    );
  }

  Widget _buildCommentTile(CommentModel comment, {bool isReply = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: isReply ? 17 : 20,
            backgroundColor: Colors.transparent,
            child: ClipOval(
              child: comment.avatar != null && comment.avatar.isNotEmpty
                  ? Image.network(
                      comment.avatar,
                      width: isReply ? 34 : 40,
                      height: isReply ? 34 : 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          "assets/images/default-avatar.jpg",
                          width: isReply ? 34 : 40,
                          height: isReply ? 34 : 40,
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  : Image.asset(
                      "assets/images/default-avatar.jpg",
                      width: isReply ? 34 : 40,
                      height: isReply ? 34 : 40,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      comment.username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      timeago.format(comment.createdAt, locale: 'id'),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(comment.content),
                const SizedBox(height: 8),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          _isReplying = true;
                          _replyingToComment = comment;
                        });
                      },
                      child: Text(
                        'Balas',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyList(List<CommentModel> replies) {
    // Jika tidak ada balasan, kembalikan widget kosong
    if (replies.isEmpty) return const SizedBox.shrink();

    // Urutkan balasan dari yang terlama ke terbaru
    // Sehingga balasan terbaru akan muncul di bagian bawah
    replies.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return Column(
      children: replies
          .map((reply) => Padding(
                padding: const EdgeInsets.only(left: 50),
                child: _buildCommentTile(reply, isReply: true),
              ))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Comment Input
        _buildCommentInput(),

        // Comments Section
        _buildCommentsSection(),
      ],
    );
  }

  Widget _buildCommentsSection() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_comments.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Jadilah yang pertama memberikan komentar!',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _comments.length,
      itemBuilder: (context, index) {
        final comment = _comments[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCommentTile(comment),
            _buildReplyList(comment.replies ?? []),
          ],
        );
      },
    );
  }
}
