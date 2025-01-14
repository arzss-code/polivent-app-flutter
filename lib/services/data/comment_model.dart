// Model untuk merepresentasikan struktur data komentar
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

  // Membuat objek komentar dari data JSON
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

  // Mengubah objek komentar menjadi format JSON
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
