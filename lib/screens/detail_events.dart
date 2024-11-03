import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:polivent_app/models/comments.dart';
import 'package:polivent_app/models/ui_colors.dart';
import 'package:polivent_app/models/explore_carousel_section.dart';
import 'package:polivent_app/screens/success_join.dart';
import 'package:uicons_pro/uicons_pro.dart';
// import 'package:google_fonts/google_fonts.dart';

class DetailEvents extends StatefulWidget {
  final CarouselEventsModel event;

  const DetailEvents({super.key, required this.event});

  @override
  State<DetailEvents> createState() => _DetailEventsState();
}

class _DetailEventsState extends State<DetailEvents> {
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

  bool _showFullDescription = false; // State
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
                                  backgroundColor: const Color(
                                      0xFFFFFFFF), // Background hitam untuk tampilan full image
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
                      horizontal: 20.0,
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
                                fontWeight: FontWeight.bold,
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
                          Icon(UIconsPro.regularRounded.house_building,
                              size: 20, color: UIColor.primaryColor),
                          const SizedBox(width: 8),
                          Text(
                            location,
                            style: TextStyle(
                              fontFamily: 'Inter', // Set font to Inter
                              fontSize: 16, // Set font size to 13
                              fontWeight:
                                  FontWeight.w500, // Medium weight (w500)
                              color:
                                  Colors.grey[700], // Optionally set text color
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(UIconsPro.regularRounded.calendar_clock,
                              size: 20, color: UIColor.primaryColor),
                          const SizedBox(width: 8),
                          Text(
                            dateTime,
                            style: TextStyle(
                              fontFamily: 'Inter', // Set font to Inter
                              fontSize: 16, // Set font size to 13
                              fontWeight:
                                  FontWeight.w500, // Medium weight (w500)
                              color:
                                  Colors.grey[700], // Optionally set text color
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(UIconsPro.regularRounded.ticket_alt,
                              size: 20, color: UIColor.primaryColor),
                          const SizedBox(width: 8),
                          Text(
                            '$totalTickets Ticket',
                            style: TextStyle(
                              fontFamily: 'Inter', // Set font to Inter
                              fontSize: 16, // Set font size to 13
                              fontWeight:
                                  FontWeight.w500, // Medium weight (w500)
                              color:
                                  Colors.grey[700], // Optionally set text color
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Divider(color: Colors.grey[300], thickness: 1),

                      // Organizer Info
                      const Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: UIColor.primaryColor,
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
                                  fontSize: 13,
                                  color: Colors.grey,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      Divider(color: Colors.grey[300], thickness: 1),
                      const SizedBox(height: 12),

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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            description,
                            style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 8),
                          if (_showFullDescription) // Show full description when true
                            Text(
                              fullDescription,
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                          TextButton(
                            iconAlignment: IconAlignment.start,
                            // Button always at the bottom
                            onPressed: () {
                              setState(() {
                                _showFullDescription = !_showFullDescription;
                              });
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.all(0),
                              foregroundColor: Colors.blue,
                              alignment: Alignment.centerLeft,
                            ),
                            child: Text(_showFullDescription
                                ? 'Read Less'
                                : 'Read More'),
                          ),
                        ],
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
                      const CommentSection(), // Panggil kelas CommentSection dari file
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
                        Navigator.pop(context); // Aksi tombol back
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
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
                          color: UIColor.secondaryColor,
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
                        height: 50,
                        decoration: BoxDecoration(
                          // color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return const SuccessJoinPopup();
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              UIColor.primaryColor, // Use primary blue color
                          minimumSize:
                              const Size(200, 50), // Updated button size
                        ),
                        child: const Text(
                          'Join',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
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
