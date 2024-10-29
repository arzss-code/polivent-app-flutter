import 'package:flutter/material.dart';

class CommentSection extends StatefulWidget {
  const CommentSection({super.key});

  @override
  CommentSectionState createState() => CommentSectionState();
}

class CommentSectionState extends State<CommentSection> {
  final List<Map<String, dynamic>> comments = [
    {
      "user": "User1",
      "userProfileUrl":
          "https://i.ibb.co.com/hWCQWcp/profile-peter.jpg", // Replace with actual profile picture URL
      "text": "Seminar ini sangat menarik!",
      "replies": [
        {
          "user": "User2",
          "userProfileUrl":
              "https://i.ibb.co.com/hWCQWcp/profile-peter.jpg", // Replace with actual profile picture URL
          "text": "Saya setuju!"
        },
      ]
    },
    {
      "user": "User3",
      "userProfileUrl":
          "https://i.ibb.co.com/hWCQWcp/profile-peter.jpg", // Replace with actual profile picture URL
      "text": "Apakah ada sesi tanya jawab?",
      "replies": [
        {
          "user": "User4",
          "userProfileUrl":
              "https://i.ibb.co.com/hWCQWcp/profile-peter.jpg", // Replace with actual profile picture URL
          "text": "Ya, sesi tanya jawab akan ada di akhir."
        }
      ]
    },
    {
      "user": "User5",
      "userProfileUrl":
          "https://i.ibb.co.com/hWCQWcp/profile-peter.jpg", // Replace with actual profile picture URL
      "text": "Topik yang dibahas relevan dengan teknologi masa depan.",
      "replies": []
    },
  ];

  final TextEditingController _newCommentController = TextEditingController();
  final TextEditingController _replyController = TextEditingController();

  void _addComment() {
    if (_newCommentController.text.isNotEmpty) {
      setState(() {
        comments.add({
          "user": "NewUser", // Placeholder for current user
          "userProfileUrl":
              "https://i.ibb.co.com/hWCQWcp/profile-peter.jpg", // Add the actual profile picture URL here
          "text": _newCommentController.text,
          "replies": []
        });
        _newCommentController.clear();
      });
      FocusScope.of(context)
          .unfocus(); // Hide the keyboard and cursor after adding a comment
    }
  }

  void _addReply(int index) {
    if (_replyController.text.isNotEmpty) {
      setState(() {
        comments[index]['replies'].add({
          "user": "ReplyUser", // Placeholder for reply user
          "userProfileUrl": null, // Add actual reply profile picture URL here
          "text": _replyController.text
        });
        _replyController.clear();
      });
      FocusScope.of(context)
          .unfocus(); // Hide the keyboard and cursor after adding a reply
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Display comments and their replies
        ...comments.map((comment) {
          int index = comments.indexOf(comment);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: comment['userProfileUrl'] != null
                            ? NetworkImage(comment['userProfileUrl'])
                            : null, // Load profile image from URL or null
                        backgroundColor: const Color.fromRGBO(255, 191, 28, 1),
                        child: comment['userProfileUrl'] == null
                            ? const Icon(Icons.person, color: Colors.white)
                            : null, // Display placeholder icon if no URL
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              comment['user'],
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              comment['text'],
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                // Open reply input field
                                showModalBottomSheet(
                                  isScrollControlled:
                                      true, // Important for resizing
                                  context: context,
                                  builder: (context) {
                                    return Padding(
                                      padding: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                              .viewInsets
                                              .bottom), // Push above the keyboard
                                      child: Card(
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(24),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: TextField(
                                                  controller: _replyController,
                                                  cursorColor: Colors
                                                      .blue, // Blue cursor
                                                  decoration: InputDecoration(
                                                    hintText:
                                                        'Type your reply...',
                                                    hintStyle: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey
                                                          .withOpacity(0.7),
                                                    ),
                                                    border: InputBorder.none,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                decoration: const BoxDecoration(
                                                  color: Colors.blue,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: IconButton(
                                                  onPressed: () {
                                                    _addReply(index);
                                                    Navigator.pop(context);
                                                  },
                                                  icon: const Icon(Icons.send,
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: const Text(
                                'Reply',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        '2h ago', // Placeholder for time
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              // Display replies
              Padding(
                padding: const EdgeInsets.only(left: 40.0),
                child: Column(
                  children: comment['replies']
                      .map<Widget>((reply) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: reply['userProfileUrl'] !=
                                            null
                                        ? NetworkImage(reply['userProfileUrl'])
                                        : null, // Load profile image from URL
                                    backgroundColor: const Color.fromRGBO(
                                        255,
                                        191,
                                        28,
                                        1), // Display placeholder if no URL
                                    radius: 16,
                                    child: reply['userProfileUrl'] == null
                                        ? const Icon(Icons.person,
                                            color: Colors.white)
                                        : null,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          reply[
                                              'user'], // Display reply user name
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          reply['text'],
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 14,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          );
        }),

        const SizedBox(height: 16),

        // Add new comment input field (rounded with short height)
        Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newCommentController,
                    cursorColor: Colors.blue, // Set cursor color to blue
                    onSubmitted: (value) {
                      if (value.isEmpty) {
                        FocusScope.of(context)
                            .unfocus(); // Hide cursor if empty
                      }
                    },
                    decoration: const InputDecoration(
                      hintText: 'Add a comment...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _addComment,
                    icon: const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
