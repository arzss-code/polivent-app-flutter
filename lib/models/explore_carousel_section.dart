import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:polivent_app/models/ui_colors.dart';
import 'package:uicons_pro/uicons_pro.dart';
import 'package:intl/intl.dart';
import 'package:polivent_app/screens/detail_events.dart';

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
      eventId: json['event_id'] != null ? int.parse(json['event_id'].toString()) : 0,
      title: json['title']?.toString() ?? 'No Title',
      dateAdd: json['date_add']?.toString() ?? '',
      categoryId: json['category_id'] != null ? int.parse(json['category_id'].toString()) : 0,
      descEvent: json['desc_event']?.toString() ?? '',
      poster: json['poster']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      quota: json['quota'] != null ? int.parse(json['quota'].toString()) : 0,
      dateStart: json['date_start']?.toString() ?? '',
      dateEnd: json['date_end']?.toString() ?? '',
    );
  }
}

class CarouselSection extends StatefulWidget {
  const CarouselSection({super.key});

  @override
  State<CarouselSection> createState() => _CarouselEventsState();
}

class _CarouselEventsState extends State<CarouselSection> {
  List<Event> _eventsCarousel = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      final response = await http.get(Uri.parse('https://polivent.my.id/api/events'));

      if (response.statusCode == 200) {
        final dynamic jsonResponse = json.decode(response.body);
        
        if (jsonResponse is Map && jsonResponse.containsKey('data')) {
          // If the response has a 'data' wrapper
          final List<dynamic> eventsList = jsonResponse['data'] as List;
          setState(() {
            _eventsCarousel = eventsList
                .map((event) => Event.fromJson(event as Map<String, dynamic>))
                .toList();
            _isLoading = false;
          });
        } else if (jsonResponse is List) {
          // If the response is directly a list
          setState(() {
            _eventsCarousel = jsonResponse
                .map((event) => Event.fromJson(event as Map<String, dynamic>))
                .toList();
            _isLoading = false;
          });
        } else {
          throw Exception('Unexpected JSON format');
        }
      } else {
        throw Exception('Failed to load events: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load events: $e';
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_error)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Text(
            'Trending Events',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: UIColor.typoBlack,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_error.isNotEmpty)
          Center(child: Text(_error))
        else
          SizedBox(
            height: (MediaQuery.of(context).size.width - 40) / 1.66,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _eventsCarousel.length,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 20, right: 20),
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final event = _eventsCarousel[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailEvents(eventId: event.eventId),
                      ),
                    );
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width - 40,
                    decoration: BoxDecoration(
                      color: UIColor.solidWhite,
                      image: DecorationImage(
                        image: NetworkImage(event.poster),
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: UIColor.solidWhite,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.title,
                                  style: TextStyle(
                                    color: UIColor.typoBlack,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  DateFormat('dd MMM yyyy').format(
                                    DateTime.parse(event.dateStart),
                                  ),
                                  style: TextStyle(
                                    color: UIColor.typoGray,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}