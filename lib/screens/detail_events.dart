import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:photo_view/photo_view.dart';
import 'package:polivent_app/models/ui_colors.dart';
import 'package:polivent_app/models/comments.dart';
import 'package:polivent_app/models/share.dart';
import 'package:polivent_app/screens/success_join.dart';
import 'package:uicons_pro/uicons_pro.dart';
import 'package:intl/intl.dart';

class Event {
  final int eventId;
  final String title;
  final String dateAdd;
  final int categoryId;
  final String descEvent;
  final String poster;
  final String location;
  final int quota;
  final String dateStart;
  final String dateEnd;

  Event({
    required this.eventId,
    required this.title,
    required this.dateAdd,
    required this.categoryId,
    required this.descEvent,
    required this.poster,
    required this.location,
    required this.quota,
    required this.dateStart,
    required this.dateEnd,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      eventId: json['event_id'] ?? 0,
      title: json['title'] ?? 'No Title',
      dateAdd: json['date_add'] ?? '',
      categoryId: json['category_id'] ?? 0,
      descEvent: json['desc_event'] ?? '',
      poster: json['poster'] ?? '',
      location: json['location'] ?? '',
      quota: json['quota'] ?? 0,
      dateStart: json['date_start'] ?? '',
      dateEnd: json['date_end'] ?? '',
    );
  }
}

class DetailEvents extends StatefulWidget {
  final int eventId;

  const DetailEvents({Key? key, required this.eventId}) : super(key: key);

  @override
  State<DetailEvents> createState() => _DetailEventsState();
}

class _DetailEventsState extends State<DetailEvents> {
  late Future<Event> futureEvent;
  bool _showFullDescription = false;
  bool isLoved = false;

  @override
  void initState() {
    super.initState();
    futureEvent = fetchEvent();
  }

  Future<Event> fetchEvent() async {
    final response = await http.get(
      Uri.parse('https://polivent.my.id/api/events/${widget.eventId}'),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      if (jsonResponse is Map) {
        if (jsonResponse.containsKey('data')) {
          return Event.fromJson(jsonResponse['data'] as Map<String, dynamic>);
        } else {
          return Event.fromJson(jsonResponse as Map<String, dynamic>);
        }
      } else {
        throw Exception('Unexpected response format');
      }
    } else {
      throw Exception('Failed to load event: ${response.statusCode}');
    }
  }

  String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMMM yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  Widget buildEventImage(String imageUrl) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.zero,
              child: PhotoView(
                imageProvider: NetworkImage(imageUrl),
                backgroundDecoration:
                    const BoxDecoration(color: Colors.black87),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
              ),
            );
          },
        );
      },
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        height: 300,
        width: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 300,
            color: Colors.grey[300],
            child: const Center(
              child: Icon(Icons.error_outline, size: 50, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Event>(
        future: futureEvent,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final event = snapshot.data!;
            return Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildEventImage(event.poster),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 8.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    event.title,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    isLoved
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isLoved ? Colors.red : Colors.grey,
                                  ),
                                  onPressed: () {
                                    setState(() => isLoved = !isLoved);
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            // Location
                            Row(
                              children: [
                                Icon(
                                  UIconsPro.regularRounded.house_building,
                                  size: 20,
                                  color: UIColor.primaryColor,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    event.location,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            // Date
                            Row(
                              children: [
                                Icon(
                                  UIconsPro.regularRounded.calendar_clock,
                                  size: 20,
                                  color: UIColor.primaryColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  formatDate(event.dateStart),
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            // Quota
                            Row(
                              children: [
                                Icon(
                                  UIconsPro.regularRounded.ticket_alt,
                                  size: 20,
                                  color: UIColor.primaryColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${event.quota} Ticket',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Divider(color: Colors.grey[300], thickness: 1),
                            // Description section
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
                                  _showFullDescription
                                      ? event.descEvent
                                      : (event.descEvent.length > 200
                                          ? '${event.descEvent.substring(0, 200)}...'
                                          : event.descEvent),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                if (event.descEvent.length > 200)
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _showFullDescription =
                                            !_showFullDescription;
                                      });
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      foregroundColor: UIColor.primaryColor,
                                      alignment: Alignment.centerLeft,
                                    ),
                                    child: Text(
                                      _showFullDescription
                                          ? 'Read Less'
                                          : 'Read More',
                                    ),
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
                            const CommentSection(),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Custom AppBar
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 48,
                      horizontal: 16,
                    ),
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
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                              size: 18,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          'Detail Event',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.share,
                              color: Colors.white,
                              size: 18,
                            ),
                            onPressed: () {
                              // Implement share functionality
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Bottom Join Button
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, -1),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
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
                              '${event.quota} Tickets Left',
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
                                backgroundColor: UIColor.primaryColor,
                                minimumSize: const Size(200, 50),
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
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${snapshot.error}'),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        futureEvent = fetchEvent();
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
