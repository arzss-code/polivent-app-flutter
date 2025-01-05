import 'package:flutter/material.dart';
import 'package:polivent_app/config/app_config.dart';
import 'package:polivent_app/models/common_widget.dart';
import 'package:polivent_app/config/ui_colors.dart';
import 'package:polivent_app/screens/home/event/favorite_events.dart';
import 'package:polivent_app/services/data/events_model.dart';
import 'package:uicons_pro/uicons_pro.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shimmer/shimmer.dart';
import 'package:polivent_app/screens/home/event/detail_events.dart';
import 'package:polivent_app/models/search_events.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class HomeEvents extends StatefulWidget {
  const HomeEvents({super.key});

  @override
  State<HomeEvents> createState() => _HomeEventsState();
}

class _HomeEventsState extends State<HomeEvents>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  List<Event> events = [];
  bool _isLoading = true;
  bool _hasMore = true;
  int _limit = 8;
  String _error = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null).then((_) => fetchEvents());
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (_hasMore && !_isLoading) {
        setState(() {
          _limit += 8; // Tambah 8 data lagi
        });
        fetchEvents(loadMore: true);
      }
    }
  }

  // Method refresh yang komprehensif
  Future<void> refreshEvents() async {
    debugPrint('Refreshing events...');
    try {
      setState(() {
        // _isLoading = true;
        // _error = '';
        _limit = 8;
        _hasMore = true;
        events.clear();
      });

      await fetchEvents();

      debugPrint('Events refresh completed');
    } catch (e) {
      debugPrint('Error during events refresh: $e');
      setState(() {
        _error = 'Gagal memuat ulang events: $e';
      });
    }
  }

  String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final formatter = DateFormat('EEEE, d MMMM yyyy', 'id_ID');
      return formatter.format(date);
    } catch (e) {
      return dateString; // Return original string if parsing fails
    }
  }

  Future<void> fetchEvents({bool loadMore = false}) async {
    if (!loadMore) {
      setState(() {
        _isLoading = true;
        _error = '';
      });
    }

    try {
      final response = await http
          .get(Uri.parse('$prodApiBaseUrl/available_events?limit=$_limit'));

      if (response.statusCode == 200) {
        final dynamic jsonResponse = json.decode(response.body);

        if (jsonResponse is Map && jsonResponse.containsKey('data')) {
          final List<dynamic> eventsList = jsonResponse['data'] as List;
          final List<Event> newEvents = eventsList
              .map((event) => Event.fromJson(event as Map<String, dynamic>))
              .toList();

          setState(() {
            events = newEvents;
            _isLoading = false;

            // Cek apakah masih ada data lebih lanjut
            _hasMore = newEvents.length == _limit;
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

  Widget _buildShimmerLoading() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 144,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  // Shimmer for the image
                  Container(
                    width: 90,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 12, 8, 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Shimmer for the title
                          Container(
                            height: 20,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Shimmer for the info rows
                          ...List.generate(3, (index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Container(
                                height: 16,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: Colors.white,
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GestureDetector(
      onTap: () {
        // Tutup keyboard
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          scrolledUnderElevation: 0,
          centerTitle: true,
          backgroundColor: UIColor.solidWhite,
          elevation: 0,
          actions: [
            IconButton(
              padding: const EdgeInsets.only(left: 20, right: 20),
              icon: const Icon(Icons.favorite_outline_rounded,
                  size: 28, color: UIColor.typoBlack),
              onPressed: () {
                // Navigasi ke halaman Favorite Events
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FavoriteEvents()));
              },
            ),
          ],
          title: const Text(
            "Events",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: UIColor.typoBlack,
            ),
          ),
        ),
        body: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: SearchEventsWidget(),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: refreshEvents,
                color: UIColor.primaryColor,
                backgroundColor: Colors.white,
                child: _buildEventContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventContent() {
    if (_isLoading) {
      return Center(
        child: _buildShimmerLoading(),
      );
    } else if (_error.isNotEmpty) {
      return CommonWidgets.buildErrorWidget(
          context: context, errorMessage: _error, onRetry: fetchEvents);
    } else if (events.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              const Image(
                image: AssetImage('assets/images/no-events.png'),
                height: 250,
                width: 250,
              ),
              const SizedBox(height: 20),
              const Text(
                'Belum Ada Event Tersedia',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: UIColor.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  'Saat ini tidak ada event yang tersedia. Silakan periksa kembali nanti.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: UIColor.typoGray,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: refreshEvents,
                style: ElevatedButton.styleFrom(
                  backgroundColor: UIColor.primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'Refresh',
                  style: TextStyle(
                    color: UIColor.solidWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.zero,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: events.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < events.length) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DetailEvents(eventId: events[index].eventId),
                    ),
                  );
                },
                child: _buildEventCard(events[index]),
              ),
            );
          } else if (_hasMore) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(
                  color: UIColor.primaryColor,
                ),
              ),
            );
          } else {
            return SizedBox.shrink();
          }
        },
      );
    }
  }

  Widget _buildEventCard(Event event) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: UIColor.solidWhite,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              child: event.poster != null && event.poster.isNotEmpty
                  ? Image.network(
                      event.poster,
                      height: 120,
                      width: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint('Image load error: $error');
                        return Image.asset(
                          'assets/images/no_image_found.png',
                          height: 120,
                          width: 90,
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  : Image.asset(
                      'assets/images/no_image_found.png',
                      height: 120,
                      width: 90,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 12, 8, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: UIColor.typoBlack,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  _buildInfoRow(UIconsPro.regularRounded.ticket_alt,
                      '${event.quota} tiket'),
                  _buildInfoRow(
                      UIconsPro.regularRounded.house_building, event.place),
                  // _buildInfoRow(
                  //     UIconsPro.regularRounded.marker, event.location),
                  _buildInfoRow(UIconsPro.regularRounded.calendar,
                      formatDate(event.dateStart)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, color: UIColor.primaryColor, size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: UIColor.typoBlack,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
