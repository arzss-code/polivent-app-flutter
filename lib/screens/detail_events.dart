import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
// import 'package:google_fonts/google_fonts.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // Make the status bar transparent
    systemNavigationBarColor:
        Colors.transparent, // Make the navigation bar transparent
    // statusBarIconBrightness:
    //     Brightness.dark, // Change icon brightness (optional)
  ));
  runApp(const PoliventApp());
}

// Define primary color
const Color primaryColor = Color(0xFF1886EA);
const Color secondaryColor = Color(0xFFFAAD14);

class PoliventApp extends StatelessWidget {
  const PoliventApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Polivent App - Detail Event',
      theme: ThemeData(
        fontFamily: 'Inter', // Set Inter as default font
        primaryColor: primaryColor, // Use primaryColor globally
      ),
      home: const PoliventDetail(),
      debugShowCheckedModeBanner: false, // Debug banner removed
    );
  }
}

class PoliventDetail extends StatefulWidget {
  const PoliventDetail({super.key});

  @override
  _PoliventDetailState createState() => _PoliventDetailState();
}

class _PoliventDetailState extends State<PoliventDetail> {
  final String eventTitle = 'Seminar : Techcomfest';
  final String location = 'Gedung Kuliah Terpadu Lantai 2';
  final String dateTime = '12 Januari 2024 - 10:00 PM';
  final int totalTickets = 50;
  final String description =
      'Join us at Techomfest, the ultimate seminar for tech enthusiasts, innovators, and future leaders! '
      'This year’s seminar will dive deep into the latest advancements in technology, from artificial intelligence '
      'and blockchain to the Internet of Things (IoT) and cutting-edge software development.';

  final String fullDescription =
      'With renowned speakers, interactive panels, and hands-on workshops, Techomfest offers a unique opportunity to explore '
      'how technology is shaping the future across various industries. Whether you\'re a student, entrepreneur, or tech professional, '
      'this event is your gateway to new knowledge and innovation.';

  final int availableTickets = 44;

  bool isLoved = false; // State for love button interaction

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Scrollable content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar di bagian atas dengan rounded corner dan gradient hitam
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Dialog(
                                  backgroundColor: Colors
                                      .black, // Background hitam untuk tampilan full image
                                  insetPadding: const EdgeInsets.all(
                                      0), // Hilangkan padding di dialog
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context)
                                          .pop(); // Tutup dialog saat gambar di-tap lagi
                                    },
                                    child: SizedBox(
                                      width: double.infinity,
                                      height: double.infinity,
                                      child: PhotoView(
                                        imageProvider: const NetworkImage(
                                            'https://i.ibb.co.com/pW4RQff/poster-techomfest.jpg'),
                                        backgroundDecoration:
                                            const BoxDecoration(
                                          color: Colors
                                              .black, // Latar belakang hitam saat full screen
                                        ),
                                        minScale: PhotoViewComputedScale
                                            .contained, // Gambar di-fit sesuai layar
                                        maxScale:
                                            PhotoViewComputedScale.covered *
                                                3.0, // Bisa di-zoom hingga 3x
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: Image.network(
                            'https://i.ibb.co.com/pW4RQff/poster-techomfest.jpg',
                            alignment: Alignment.topCenter,
                            fit: BoxFit.cover,
                            height: 300,
                            width: double.infinity,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0), // Updated padding(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Detail seminar
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              eventTitle,
                              style: const TextStyle(
                                fontSize: 20, // Title font size updated
                                fontWeight: FontWeight.w800,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              isLoved ? Icons.favorite : Icons.favorite_border,
                              color: isLoved ? Colors.red : Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                isLoved = !isLoved; // Toggle love interaction
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.place_outlined, color: primaryColor),
                          const SizedBox(width: 8),
                          Text(
                            location,
                            style: TextStyle(
                              fontFamily: 'Inter', // Set font to Inter
                              fontSize: 14, // Set font size to 13
                              fontWeight:
                                  FontWeight.w500, // Medium weight (w500)
                              color:
                                  Colors.grey[600], // Optionally set text color
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.event_outlined, color: primaryColor),
                          const SizedBox(width: 8),
                          Text(
                            dateTime,
                            style: TextStyle(
                              fontFamily: 'Inter', // Set font to Inter
                              fontSize: 14, // Set font size to 13
                              fontWeight:
                                  FontWeight.w500, // Medium weight (w500)
                              color:
                                  Colors.grey[600], // Optionally set text color
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.confirmation_number_outlined,
                              color: primaryColor),
                          const SizedBox(width: 8),
                          Text(
                            '$totalTickets Ticket',
                            style: TextStyle(
                              fontFamily: 'Inter', // Set font to Inter
                              fontSize: 14, // Set font size to 13
                              fontWeight:
                                  FontWeight.w500, // Medium weight (w500)
                              color:
                                  Colors.grey[600], // Optionally set text color
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Divider(color: Colors.grey[300], thickness: 1),

                      // Organizer Info
                      const Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: primaryColor,
                            radius: 20,
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'UKM PCC',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  fontFamily: 'Inter',
                                ),
                              ),
                              Text(
                                'Organizer',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      Divider(color: Colors.grey[300], thickness: 1),
                      const SizedBox(height: 8),

                      // Descriptions
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        fullDescription,
                        style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 16),

                      // Comments section
                      const Text(
                        'Comments',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 8),
                      const CommentSection(),
                      const SizedBox(
                          height: 100), // Padding tambahan untuk bagian bawah
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Custom AppBar dengan tombol Back, Title, dan Share
          Positioned(
            top: 0, // Fixed position at top
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  // Back button with semi-transparent background
                  Container(
                    width: 40, // Set width of the container
                    height: 40, // Set height of the container
                    decoration: BoxDecoration(
                      color: Colors.white
                          .withOpacity(0.2), // Semi-transparent background
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 18,
                      ),
                      onPressed: () {
                        // Aksi tombol back
                      },
                    ),
                  ),
                  const Spacer(),
                  // Title "Detail Event" in the center
                  const Text(
                    'Detail Event',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: Colors.white,
                      fontSize: 20, // Font size 20 as per image
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  // Share button with semi-transparent background
                  Container(
                    width: 40, // Set width of the container
                    height: 40, // Set height of the container
                    decoration: BoxDecoration(
                      color: Colors.white
                          .withOpacity(0.2), // Semi-transparent background
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.share,
                        color: Colors.white,
                        size: 18,
                      ),
                      onPressed: () {
                        // Aksi tombol share
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bagian bawah dengan tombol "Join"
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              color: Colors.white,
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Free',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFAAD14),
                        ),
                      ),
                      Text(
                        '$availableTickets Tickets Left',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Rounded rectangle background with 20% opacity
                      Container(
                        width: 200,
                        height: 60,
                        decoration: BoxDecoration(
                          // color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Aksi ketika tombol join diklik
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              primaryColor, // Use primary blue color
                          minimumSize:
                              const Size(200, 60), // Updated button size
                        ),
                        child: const Text(
                          'Join',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CommentSection extends StatefulWidget {
  const CommentSection({super.key});

  @override
  _CommentSectionState createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
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
