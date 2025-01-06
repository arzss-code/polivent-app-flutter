import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:polivent_app/services/comment_services.dart';
import 'package:polivent_app/services/data/comment_model.dart';
import 'package:polivent_app/services/data/user_model.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:polivent_app/services/auth_services.dart';

// Widget untuk menampilkan dan mengelola bagian komentar pada event
class CommentsSection extends StatefulWidget {
  final int eventId;

  const CommentsSection({super.key, required this.eventId});

  @override
  CommentsSectionState createState() => CommentsSectionState();
}

class CommentsSectionState extends State<CommentsSection> {
  // Inisialisasi layanan dan kontroller
  final CommentService _commentService = CommentService();
  final TextEditingController _commentController = TextEditingController();
  final AuthService _authService = AuthService();

  // Variabel untuk menyimpan state komentar dan interaksi
  List<CommentModel> _comments = [];
  bool _isLoading = true;
  bool _isReplying = false;
  CommentModel? _replyingToComment;
  User? _currentUser;
  Map<int, bool> _expandedReplies = {};
  FocusNode _commentFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchComments();
  }

  // Method untuk menghitung total komentar (termasuk replies)
  int _countTotalComments(List<CommentModel> comments) {
    int total = comments.length;
    for (var comment in comments) {
      if (comment.replies != null) {
        total += comment.replies!.length;
      }
    }
    return total;
  }

  // Mengambil data pengguna saat ini
  Future<void> _fetchUserData() async {
    try {
      final userData = await _authService.getUserData();

      setState(() {
        _currentUser = userData;
      });
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
  }

  // Mengambil komentar dari layanan berdasarkan ID event
  Future<void> _fetchComments() async {
    setState(() {
      _isLoading = true;
    });

    final comments = await _commentService.getCommentsByEventId(widget.eventId);

    setState(() {
      _comments = comments..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _isLoading = false;
    });
  }

  // Mengirim komentar baru atau balasan
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

  // Membangun input komentar dengan avatar pengguna
  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
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
                        debugPrint('Image load error: $error');
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
          // TextField untuk menulis komentar
          Expanded(
            child: TextField(
              focusNode: _commentFocusNode,
              controller: _commentController,
              textInputAction: TextInputAction.send,
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
              onSubmitted: (_) => _submitComment(),
            ),
          ),
          // Tombol kirim
          IconButton(
            iconSize: 35,
            icon: const Icon(Icons.send_rounded),
            color: Colors.blue,
            onPressed: _submitComment,
          ),
        ],
      ),
    );
  }

  // Membangun tampilan tile komentar
  Widget _buildCommentTile(CommentModel comment, {bool isReply = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar pengguna
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
          // Konten komentar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Nama pengguna
                    Text(
                      comment.username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    // Waktu komentar
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
                // Konten komentar
                Text(comment.content),
                const SizedBox(height: 8),
                // Tombol untuk membalas komentar
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
                          fontWeight: FontWeight.w500,
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

  // Membangun daftar balasan
  Widget _buildReplyList(List<CommentModel> replies) {
    // Jika tidak ada balasan, kembalikan widget kosong
    if (replies.isEmpty) return const SizedBox.shrink();

    // Urutkan balasan dari yang terlama ke terbaru
    replies.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return Column(
      children: replies.map((reply) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 50),
              child: _buildCommentTile(reply, isReply: true),
            ),
            // Tambahkan sub-replies jika ada
            if (reply.replies != null && reply.replies!.isNotEmpty)
              _buildReplyList(reply.replies!),
          ],
        );
      }).toList(),
    );
  }

  // Menampilkan balasan dengan opsi hide/show
  Widget _buildRepliesSection(CommentModel comment) {
    // Jika tidak ada balasan, kembalikan widget kosong
    if (comment.replies == null || comment.replies!.isEmpty) {
      return const SizedBox.shrink();
    }

    // Tentukan status expand/collapse untuk komentar ini
    bool isExpanded = _expandedReplies[comment.commentId] ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tombol untuk menampilkan/menyembunyikan balasan
        if (comment.replies!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 52, top: 2, bottom: 2),
            child: InkWell(
              onTap: () {
                setState(() {
                  _expandedReplies[comment.commentId] = !isExpanded;
                });
              },
              child: Text(
                isExpanded ? 'Sembunyikan balasan' : 'Lihat balasan',
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

        // Tampilkan balasan jika diperluas
        if (isExpanded) _buildReplyList(comment.replies!),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Ini akan menutup keyboard dan menghilangkan fokus
        FocusScope.of(context).unfocus();

        // Reset reply state
        setState(() {
          _isReplying = false;
          _replyingToComment = null;
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Comment Input
          _buildCommentInput(),

          // Comments Section
          _buildCommentsSection(),
        ],
      ),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _comments.length,
          itemBuilder: (context, index) {
            final comment = _comments[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCommentTile(comment),
                _buildRepliesSection(comment),
              ],
            );
          },
        ),
      ],
    );
  }

  @override
  // Membersihkan sumber daya
  void dispose() {
    _commentFocusNode.dispose();
    _commentController.dispose();
    super.dispose();
  }
}
