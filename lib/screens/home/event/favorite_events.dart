import 'package:flutter/material.dart';
import 'package:polivent_app/config/app_config.dart';
import 'package:polivent_app/models/common_widget.dart';
import 'package:polivent_app/models/ui_colors.dart';
import 'package:polivent_app/services/data/events_model.dart';
import 'package:polivent_app/services/like_services.dart';
import 'package:polivent_app/services/token_service.dart';
import 'package:uicons_pro/uicons_pro.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shimmer/shimmer.dart';
import 'package:polivent_app/screens/home/event/detail_events.dart';
import 'package:polivent_app/models/search_events.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class FavoriteEvents extends StatefulWidget {
  const FavoriteEvents({super.key});

  @override
  State<FavoriteEvents> createState() => _FavoriteEventsState();
}

class _FavoriteEventsState extends State<FavoriteEvents>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final ScrollController _scrollController = ScrollController();

  List<Event> favoriteEvents = [];
  bool _isLoading = true;
  bool _hasMore = true;
  int _limit = 5;
  String _error = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null).then((_) => fetchFavoriteEvents());
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (_hasMore && !_isLoading) {
        setState(() {
          _limit += 5;
        });
        fetchFavoriteEvents(loadMore: true);
      }
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

  Future<void> refreshFavoriteEvents() async {
    debugPrint('Refreshing favorite events...');
    try {
      setState(() {
        _limit = 8;
        _hasMore = true;
        favoriteEvents.clear();
      });

      await fetchFavoriteEvents();

      debugPrint('Favorite events refresh completed');
    } catch (e) {
      debugPrint('Error during favorite events refresh: $e');
      setState(() {
        _error = 'Gagal memuat ulang event favorit: $e';
      });
    }
  }

  Future<void> fetchFavoriteEvents({bool loadMore = false}) async {
    if (!loadMore) {
      setState(() {
        _isLoading = true;
        _error = '';
      });
    }

    try {
      // Ganti dengan endpoint untuk mendapatkan event favorit
      final response = await http.get(
        Uri.parse('$prodApiBaseUrl/available_events?liked=true'),
        // Tambahkan header authorization jika diperlukan
        headers: {
          'Authorization': 'Bearer ${await TokenService.getAccessToken()}',
        },
      );

      if (response.statusCode == 200) {
        final dynamic jsonResponse = json.decode(response.body);

        if (jsonResponse is Map && jsonResponse.containsKey('data')) {
          final List<dynamic> eventsList = jsonResponse['data'] as List;
          final List<Event> newFavoriteEvents = eventsList
              .map((event) => Event.fromJson(event as Map<String, dynamic>))
              .toList();

          setState(() {
            favoriteEvents = newFavoriteEvents;
            _isLoading = false;
            _hasMore = newFavoriteEvents.length == _limit;
          });
        } else {
          throw Exception('Unexpected JSON format');
        }
      } else {
        throw Exception(
            'Failed to load favorite events: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat event favorit: $e';
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_error)),
      );
    }
  }

  // Gunakan method yang sama seperti sebelumnya untuk _buildShimmerLoading()

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: UIColor.solidWhite,
        elevation: 0,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Event Favorit",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: UIColor.typoBlack,
              ),
            ),
          ],
        ),
        actions: [
          // Jumlah event favorit
          Container(
            margin: const EdgeInsets.only(right: 20),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            decoration: BoxDecoration(
              color: UIColor.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${favoriteEvents.length}', // Tampilkan jumlah event favorit
              style: const TextStyle(
                color: UIColor.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: refreshFavoriteEvents,
              color: UIColor.primaryColor,
              backgroundColor: Colors.white,
              child: _buildFavoriteEventContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteEventContent() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0), // Add padding to the top
      child: _buildFavoriteEventList(),
    );
  }

  Widget _buildFavoriteEventList() {
    if (_isLoading) {
      return Center(
        child: _buildShimmerLoading(),
      );
    } else if (_error.isNotEmpty) {
      return CommonWidgets.buildErrorWidget(
          context: context, errorMessage: _error, onRetry: fetchFavoriteEvents);
    } else if (favoriteEvents.isEmpty) {
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
                'Tidak Ada Event Favorit',
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
                  'Anda belum memiliki event favorit. Tambahkan event yang Anda sukai.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: UIColor.typoGray,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: refreshFavoriteEvents,
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
        itemCount: favoriteEvents.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < favoriteEvents.length) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DetailEvents(eventId: favoriteEvents[index].eventId),
                    ),
                  );
                },
                child: _buildEventCard(favoriteEvents[index]),
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

  // Widget _buildFavoriteEventContent() {
  //   if (_isLoading) {
  //     return Center(
  //       child: _buildShimmerLoading(),
  //     );
  //   } else if (_error.isNotEmpty) {
  //     return CommonWidgets.buildErrorWidget(
  //         context: context, errorMessage: _error, onRetry: fetchFavoriteEvents);
  //   } else if (favoriteEvents.isEmpty) {
  //     return Center(
  //       child: SingleChildScrollView(
  //         physics: const AlwaysScrollableScrollPhysics(),
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           mainAxisSize: MainAxisSize.max,
  //           children: [
  //             const Image(
  //               image: AssetImage('assets/images/no-favorite-events.png'),
  //               height: 250,
  //               width: 250,
  //             ),
  //             const SizedBox(height: 20),
  //             const Text(
  //               'Tidak Ada Event Favorit',
  //               style: TextStyle(
  //                 fontSize: 20,
  //                 fontWeight: FontWeight.bold,
  //                 color: UIColor.primaryColor,
  //               ),
  //               textAlign: TextAlign.center,
  //             ),
  //             const SizedBox(height: 10),
  //             const Padding(
  //               padding: EdgeInsets.symmetric(horizontal: 30),
  //               child: Text(
  //                 'Anda belum memiliki event favorit. Tambahkan event yang Anda sukai.',
  //                 textAlign: TextAlign.center,
  //                 style: TextStyle(
  //                   color: UIColor.typoGray,
  //                   fontSize: 16,
  //                 ),
  //               ),
  //             ),
  //             const SizedBox(height: 20),
  //             ElevatedButton(
  //               onPressed: refreshFavoriteEvents,
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: UIColor.primaryColor,
  //                 padding: const EdgeInsets.symmetric(
  //                   horizontal: 40,
  //                   vertical: 12,
  //                 ),
  //               ),
  //               child: const Text(
  //                 'Refresh',
  //                 style: TextStyle(
  //                   color: UIColor.solidWhite,
  //                   fontWeight: FontWeight.bold,
  //                   fontSize: 16,
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     );
  //   } else {
  //     return ListView.builder(
  //       controller: _scrollController,
  //       padding: EdgeInsets.zero,
  //       physics: const AlwaysScrollableScrollPhysics(),
  //       itemCount: favoriteEvents.length + (_hasMore ? 1 : 0),
  //       itemBuilder: (context, index) {
  //         if (index < favoriteEvents.length) {
  //           return Padding(
  //             padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
  //             child: GestureDetector(
  //               onTap: () {
  //                 Navigator.push(
  //                   context,
  //                   MaterialPageRoute(
  //                     builder: (context) =>
  //                         DetailEvents(eventId: favoriteEvents[index].eventId),
  //                   ),
  //                 );
  //               },
  //               child: _buildEventCard(favoriteEvents[index]),
  //             ),
  //           );
  //         } else if (_hasMore) {
  //           return const Center(
  //             child: Padding(
  //               padding: EdgeInsets.all(8.0),
  //               child: CircularProgressIndicator(
  //                 color: UIColor.primaryColor,
  //               ),
  //             ),
  //           );
  //         } else {
  //           return SizedBox.shrink();
  //         }
  //       },
  //     );
  //   }
  // }

  // Modifikasi _buildEventCard
  Widget _buildEventCard(Event event) {
    // Gunakan checkLikeStatus untuk mendapatkan status like awal
    return FutureBuilder<Map<String, dynamic>>(
      future: LikeService().checkLikeStatus(event.eventId),
      builder: (context, likeSnapshot) {
        // State lokal untuk like
        final ValueNotifier<bool> isLikedNotifier =
            ValueNotifier<bool>(likeSnapshot.data?['is_liked'] ?? false);

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: UIColor.solidWhite,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poster Event
              Padding(
                padding: const EdgeInsets.all(12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: event.poster != null && event.poster.isNotEmpty
                      ? Image.network(
                          event.poster,
                          height: 120,
                          width: 90,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
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
                  padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul dan Tombol Favorite
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              event.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: UIColor.typoBlack,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Tombol Favorite dengan ValueListenableBuilder
                          ValueListenableBuilder<bool>(
                            valueListenable: isLikedNotifier,
                            builder: (context, isLiked, child) {
                              // Tampilkan loading jika masih proses
                              if (likeSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: Icon(
                                      Icons.favorite_border,
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              }

                              return GestureDetector(
                                onTap: () async {
                                  final result = await LikeService()
                                      .toggleLike(event.eventId);

                                  if (result['success']) {
                                    // Update state lokal
                                    isLikedNotifier.value = result['is_liked'];

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            Icon(
                                              result['is_liked']
                                                  ? Icons.check_circle
                                                  : Icons.remove_circle,
                                              color: result['is_liked']
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              result['is_liked']
                                                  ? 'Ditambahkan ke Favorit'
                                                  : 'Dihapus dari Favorit',
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                        backgroundColor: Colors.black87,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    );

                                    // // Update the favorite events list
                                    // if (result['is_liked']) {
                                    //   setState(() {
                                    //     favoriteEvents.add(event);
                                    //   });
                                    // } else {
                                    //   setState(() {
                                    //     favoriteEvents.removeWhere(
                                    //         (e) => e.eventId == event.eventId);
                                    //   });
                                    // }
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    transitionBuilder: (child, animation) {
                                      return ScaleTransition(
                                        scale: animation,
                                        child: child,
                                      );
                                    },
                                    child: Icon(
                                      isLiked
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: isLiked
                                          ? Colors.red.shade400
                                          : Colors.grey.shade400,
                                      size: 24,
                                      key: ValueKey(isLiked),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      // Spacer
                      const SizedBox(height: 8),

                      // Info Event
                      _buildInfoRow(
                        UIconsPro.regularRounded.ticket_alt,
                        '${event.quota} tiket',
                      ),
                      _buildInfoRow(
                        UIconsPro.regularRounded.house_building,
                        event.place,
                      ),
                      _buildInfoRow(
                        UIconsPro.regularRounded.calendar,
                        formatDate(event.dateStart),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
}
