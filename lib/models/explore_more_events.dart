import 'package:flutter/material.dart';
import 'package:polivent_app/models/ui_colors.dart';
// import 'package:intl/intl.dart';
import 'package:uicons_pro/uicons_pro.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shimmer/shimmer.dart';
import 'package:polivent_app/screens/detail_events.dart';
import 'package:polivent_app/models/data/events_model.dart';

class EventList extends StatefulWidget {
  const EventList({super.key});

  @override
  State<EventList> createState() => _EventListWidgetState();
}

class _EventListWidgetState extends State<EventList> {
  List<Event> _eventsMore = [];
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

      final response =
          await http.get(Uri.parse('https://polivent.my.id/api/events'));

      if (response.statusCode == 200) {
        final dynamic jsonResponse = json.decode(response.body);

        if (jsonResponse is Map && jsonResponse.containsKey('data')) {
          final List<dynamic> eventsList = jsonResponse['data'] as List;
          setState(() {
            _eventsMore = eventsList
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

  Widget _buildShimmerEventList() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: List.generate(6, (index) {
            return Container(
              width: (MediaQuery.of(context).size.width - 44) / 2,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
            );
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Text(
            'Events Available',
            textAlign: TextAlign.right,
            style: TextStyle(
                color: UIColor.typoBlack,
                fontSize: 18,
                fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 12),
        if (_isLoading)
          _buildShimmerEventList()
        else if (_error.isNotEmpty)
          Center(child: Text(_error))
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(_eventsMore.length, (index) {
                final event = _eventsMore[index];
                Color statusColor =
                    event.quota > 0 ? UIColor.solidWhite : UIColor.close;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DetailEvents(eventId: event.eventId),
                      ),
                    );
                  },
                  child: Container(
                    width: (MediaQuery.of(context).size.width - 44) / 2,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: UIColor.solidWhite,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                event.poster,
                                height:
                                    (MediaQuery.of(context).size.width - 44) /
                                        3,
                                width: double.infinity,
                                alignment: Alignment.topCenter,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.title,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: UIColor.typoBlack,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    UIconsPro.regularRounded.user_time,
                                    color: UIColor.typoGray,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${event.quota} participants',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: UIColor.typoBlack,
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(
                                    UIconsPro.regularRounded.house_building,
                                    color: UIColor.typoGray,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    event.location,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: UIColor.typoBlack,
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(
                                    UIconsPro.regularRounded.calendar,
                                    color: UIColor.typoGray,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    event.dateStart,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: UIColor.typoBlack,
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        const SizedBox(
          height: 12,
        ),
      ],
    );
  }
}
