import 'package:flutter/material.dart';
import 'package:polivent_app/config/app_config.dart';
import 'package:polivent_app/models/ui_colors.dart';
import 'package:uicons_pro/uicons_pro.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shimmer/shimmer.dart';
import 'package:polivent_app/screens/detail_events.dart';
import 'package:polivent_app/models/data/events_model.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

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
    initializeDateFormatting('id_ID', null).then((_) => fetchEvents());
  }

  String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final formatter = DateFormat('d MMMM yyyy', 'id_ID');
      return formatter.format(date);
    } catch (e) {
      return dateString; // Return original string if parsing fails
    }
  }

  void updateEventList() {
    setState(() {
      // Memperbarui data event list jika diperlukan
    });
  }

  Future<void> fetchEvents() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      final response =
          await http.get(Uri.parse('$prodApiBaseUrl/events'));

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
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: UIColor.typoBlack,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    UIconsPro.regularRounded.ticket_alt,
                                    color: UIColor.typoGray,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${event.quota} tiket',
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
                                    formatDate(event.dateStart),
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
