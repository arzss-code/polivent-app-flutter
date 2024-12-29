import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:polivent_app/config/app_config.dart';
import 'package:polivent_app/models/ui_colors.dart';
import 'package:uicons_pro/uicons_pro.dart';
import 'package:shimmer/shimmer.dart';
import 'package:polivent_app/screens/home/event/detail_events.dart';
import 'package:polivent_app/services/data/events_model.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class EventList extends StatefulWidget {
  const EventList({super.key});

  @override
  State<EventList> createState() => EventListWidgetState();
}

class EventListWidgetState extends State<EventList> {
  final Dio _dio = Dio();

  List<Event> _eventsMore = [];
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
    initializeDateFormatting('id_ID', null).then((_) => fetchUpcomingEvents());
  }

  String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final formatter = DateFormat('d MMMM yyyy', 'id_ID');
      return formatter.format(date);
    } catch (e) {
      return dateString;
    }
  }

  void updateEventList() {
    fetchUpcomingEvents();
  }

  Future<void> fetchUpcomingEvents() async {
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
        queryParameters: {'upcoming': true},
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
          _eventsMore =
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
      _handleError(e);
    } catch (e) {
      _handleError(DioException(
          requestOptions: RequestOptions(), message: e.toString()));
    }
  }

  void _handleError(DioException e) {
    setState(() {
      _error = _getErrorMessage(e);
      _isLoading = false;
      _isFetching = false;
    });

    // Tampilkan error sekali
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_error)),
      );
    }
  }

  String _getErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'Koneksi terputus. Periksa koneksi internet Anda.';
      case DioExceptionType.badResponse:
        return _getBadResponseMessage(e.response);
      case DioExceptionType.cancel:
        return 'Permintaan dibatalkan.';
      case DioExceptionType.unknown:
        return 'Terjadi kesalahan tidak terduga.';
      default:
        return e.message ?? 'Gagal memuat events';
    }
  }

  String _getBadResponseMessage(Response? response) {
    if (response == null) return 'Tidak ada respon dari server';

    switch (response.statusCode) {
      case 400:
        return 'Permintaan tidak valid';
      case 401:
        return 'Anda tidak memiliki otorisasi';
      case 403:
        return 'Akses ditolak';
      case 404:
        return 'Sumber tidak ditemukan';
      case 500:
        return 'Kesalahan server internal';
      default:
        return 'Gagal memuat data. Kode status: ${response.statusCode}';
    }
  }

  // Method untuk refresh manual
  void _manualRefresh() {
    // Reset last fetch time untuk memaksa refresh
    _lastFetchTime = null;
    fetchUpcomingEvents();
  }

  // Widget untuk event kosong
  Widget _buildEmptyEventView() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/no-events.png',
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
            'Saat ini tidak ada event yang akan datang. Silakan periksa kembali nanti.',
            style: TextStyle(
              fontSize: 14,
              color: UIColor.typoGray,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _manualRefresh,
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
        else if (_eventsMore.isEmpty)
          _buildEmptyEventView() // Tambahkan kondisi untuk event kosong
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
                              child: event.poster != null &&
                                      event.poster.isNotEmpty
                                  ? Image.network(
                                      event.poster,
                                      height:
                                          (MediaQuery.of(context).size.width -
                                                  44) /
                                              3,
                                      width: double.infinity,
                                      alignment: Alignment.topCenter,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        debugPrint('Image load error: $error');
                                        return Image.asset(
                                          'assets/images/no_image_found.png',
                                          height: (MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                  44) /
                                              3,
                                          width: double.infinity,
                                          alignment: Alignment.center,
                                          fit: BoxFit.cover,
                                        );
                                      },
                                    )
                                  : Image.asset(
                                      'assets/images/no_image_found.png',
                                      height:
                                          (MediaQuery.of(context).size.width -
                                                  44) /
                                              3,
                                      width: double.infinity,
                                      alignment: Alignment.center,
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
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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
                                  Flexible(
                                    child: Text(
                                      event.location,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: UIColor.typoBlack,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
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
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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
