import 'dart:async';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:polivent_app/config/app_config.dart';
import 'package:polivent_app/config/ui_colors.dart';
import 'package:uicons_pro/uicons_pro.dart';
import 'package:polivent_app/screens/home/event/detail_events.dart';
import 'package:polivent_app/services/data/events_model.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:developer' as developer;

class CarouselSection extends StatefulWidget {
  const CarouselSection({super.key});

  @override
  State<CarouselSection> createState() => CarouselEventsState();
}

class CarouselEventsState extends State<CarouselSection> {
  final Dio _dio = Dio();
  List<Event> _eventsCarousel = [];
  bool _isLoading = true;
  String _error = '';

  // Tambahkan flag untuk mencegah multiple requests
  bool _isFetching = false;

  // Tambahkan timestamp terakhir fetch
  DateTime? _lastFetchTime;

  // Durasi minimal antara fetch
  static const Duration _minFetchInterval = Duration(minutes: 5);

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null).then((_) => fetchMostLikedEvents());
  }

  void updateCarousel() {
    fetchMostLikedEvents();
  }

  String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final formatter = DateFormat('EEEE, d MMMM yyyy', 'id_ID');
      return formatter.format(date);
    } catch (e) {
      return dateString;
    }
  }

  Future<void> fetchMostLikedEvents() async {
    // Cek apakah sedang fetch atau fetch terlalu sering
    if (_isFetching ||
        (_lastFetchTime != null &&
            DateTime.now().difference(_lastFetchTime!) < _minFetchInterval)) {
      return;
    }

    try {
      // Set flag fetching
      setState(() {
        _isFetching = true;
        _isLoading = true;
        _error = '';
      });

      final response = await _dio.get(
        '$prodApiBaseUrl/available_events',
        queryParameters: {'most_likes': true, 'upcoming': true, 'limit': 5},
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200) {
        final dynamic jsonResponse = response.data;

        // Pastikan data valid
        final List<dynamic> eventsList =
            jsonResponse is Map ? jsonResponse['data'] ?? [] : jsonResponse;

        setState(() {
          _eventsCarousel =
              eventsList.map((event) => Event.fromJson(event)).toList();
          _isLoading = false;
          _isFetching = false;
          _lastFetchTime = DateTime.now();
        });
      } else {
        throw DioException(
            requestOptions: response.requestOptions,
            response: response,
            message: 'Failed to load events: ${response.statusCode}');
      }
    } on DioException catch (e) {
      setState(() {
        _error = 'Failed to load events: ${e.message}';
        _isLoading = false;
        _isFetching = false;
      });

      // Tampilkan error sekali
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_error)),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Unexpected error: $e';
        _isLoading = false;
        _isFetching = false;
      });

      // if (context.mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text(_error)),
      //   );
      // }
    }
  }

  // Method refresh manual dengan debounce
  void _manualRefresh() {
    // Reset last fetch time untuk memaksa refresh
    _lastFetchTime = null;
    fetchMostLikedEvents();
  }

  // Tambahkan method baru di dalam class _CarouselEventsState
  Widget _buildEmptyEventView() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/no-events.png', // Pastikan asset tersedia
            width: 100,
            height: 100,
          ),
          const SizedBox(height: 20),
          const Text(
            'Belum Ada Event Tersedia',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: UIColor.primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          const Text(
            'Saat ini tidak ada event yang sedang berlangsung. Silakan periksa kembali nanti.',
            style: TextStyle(
              fontSize: 14,
              color: UIColor.typoGray,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: fetchMostLikedEvents, // Refresh events
            style: ElevatedButton.styleFrom(
              backgroundColor: UIColor.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'Refresh',
              style: TextStyle(
                color: UIColor.solidWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerCarousel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_error),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _manualRefresh,
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          )
        else if (_eventsCarousel.isEmpty)
          _buildEmptyEventView()
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                            image: CachedNetworkImageProvider(
                              event.poster,
                              errorListener: (error) {
                                developer.log(
                                  'Image Load Error',
                                  name: 'CachedNetworkImage',
                                  error: error,
                                  stackTrace: StackTrace.current,
                                );
                              },
                            ),
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
                                      ImageFilter.blur(sigmaX: 5, sigmaY: 5),
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
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                event.title,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: UIColor.solidWhite,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              _buildInfoRow(
                                                icon: UIconsPro
                                                    .regularRounded.ticket_alt,
                                                text: "${event.quota} tiket",
                                              ),
                                              _buildInfoRow(
                                                icon: UIconsPro.regularRounded
                                                    .house_building,
                                                text: event.place,
                                              ),
                                              _buildInfoRow(
                                                icon: UIconsPro
                                                    .regularRounded.calendar,
                                                text:
                                                    formatDate(event.dateStart),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // _buildJoinButton(event),
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

// Helper method to create consistent info rows
Widget _buildInfoRow({required IconData icon, required String text}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 1),
    child: Row(
      children: [
        Icon(
          icon,
          color: UIColor.solidWhite,
          size: 14,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: UIColor.solidWhite,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}

// // Helper method to create join button
// Widget _buildJoinButton(Event event) {
//   return Align(
//     alignment: Alignment.bottomCenter,
//     child: Container(
//       width: 100,
//       height: 30,
//       decoration: BoxDecoration(
//         color: event.quota > 0 ? UIColor.secondaryColor : UIColor.rejected,
//         borderRadius: BorderRadius.circular(30),
//       ),
//       alignment: Alignment.center,
//       child: Text(
//         event.quota > 0 ? "Join" : "Full",
//         style: const TextStyle(
//           color: UIColor.solidWhite,
//           fontWeight: FontWeight.w600,
//           fontSize: 12,
//         ),
//       ),
//     ),
//   );
// }
