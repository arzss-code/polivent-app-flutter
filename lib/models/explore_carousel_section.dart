import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:polivent_app/models/ui_colors.dart';
import 'package:uicons_pro/uicons_pro.dart';
import 'package:intl/intl.dart';
import 'package:polivent_app/screens/detail_events.dart';
import 'package:polivent_app/models/data/events_model.dart';
import 'package:shimmer/shimmer.dart';

class CarouselSection extends StatefulWidget {
  const CarouselSection({Key? key}) : super(key: key);

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

      final response =
          await http.get(Uri.parse('https://polivent.my.id/api/events'));

      if (response.statusCode == 200) {
        final dynamic jsonResponse = json.decode(response.body);

        if (jsonResponse is Map && jsonResponse.containsKey('data')) {
          final List<dynamic> eventsList = jsonResponse['data'] as List;
          setState(() {
            _eventsCarousel = eventsList
                .map((event) => Event.fromJson(event as Map<String, dynamic>))
                .toList();
            _isLoading = false;
          });
        } else if (jsonResponse is List) {
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

  Widget _buildShimmerCarousel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 150,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        SizedBox(
          height: (MediaQuery.of(context).size.width - 40) / 1.66,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: 3,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20, right: 20),
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              return Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: MediaQuery.of(context).size.width - 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 200,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 100,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 150,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        width: 80,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    width: 100,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(30),
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
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isLoading)
          _buildShimmerCarousel()
        else if (_error.isNotEmpty)
          Center(child: Text(_error))
        else
          Column(
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
              SizedBox(
                height: (MediaQuery.of(context).size.width - 40) / 1.66,
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _eventsCarousel.length,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final event = _eventsCarousel[index];
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width,
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: BackdropFilter(
                                  filter:
                                      ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                                  child: Container(
                                    padding:
                                        const EdgeInsets.fromLTRB(12, 8, 12, 8),
                                    color: UIColor.bgCarousel.withOpacity(0.4),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${event.title}",
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: UIColor.solidWhite,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Icon(
                                                  UIconsPro.regularRounded.user,
                                                  color: UIColor.solidWhite,
                                                  size: 12,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  "${event.quota} tiket",
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w400,
                                                    color: UIColor.solidWhite,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Icon(
                                                  UIconsPro.regularRounded
                                                      .house_building,
                                                  color: UIColor.solidWhite,
                                                  size: 12,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  event.location,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w400,
                                                    color: UIColor.solidWhite,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Icon(
                                                  UIconsPro
                                                      .regularRounded.calendar,
                                                  color: UIColor.solidWhite,
                                                  size: 12,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  event.dateStart,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w400,
                                                    color: UIColor.solidWhite,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Container(
                                              width: 100,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                color: event.quota > 0
                                                    ? UIColor.secondaryColor
                                                    : UIColor.rejected,
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              child: Text(
                                                event.quota > 0
                                                    ? "Join"
                                                    : "Full",
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  color: UIColor.solidWhite,
                                                  height: 2.5,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
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
          ),
      ],
    );
  }
}
