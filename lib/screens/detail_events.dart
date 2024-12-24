import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:photo_view/photo_view.dart';
import 'package:polivent_app/config/app_config.dart';
import 'package:polivent_app/screens/notification.dart';
import 'package:polivent_app/services/like_services.dart';
import 'package:polivent_app/services/auth_services.dart';
import 'package:polivent_app/services/data/events_model.dart';
import 'package:polivent_app/models/share.dart';
import 'package:polivent_app/models/ui_colors.dart';
import 'package:polivent_app/models/comments.dart';
import 'package:polivent_app/screens/success_join.dart';
import 'package:polivent_app/services/data/user_model.dart';
import 'package:polivent_app/services/notification_services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uicons_pro/uicons_pro.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class DetailEvents extends StatefulWidget {
  final int eventId;

  const DetailEvents({super.key, required this.eventId});

  @override
  State<DetailEvents> createState() => _DetailEventsState();
}

class _DetailEventsState extends State<DetailEvents> {
  // User? _currentUser;
  // String _errorMessage = '';
  late Future<Event> futureEvent;
  bool _showFullDescription = false;
  bool isLoved = false;
  int? likeId;
  bool _isLikeLoading = false;

  @override
  void initState() {
    super.initState();
    futureEvent = fetchEventById();
    _checkInitialLikeStatus();
  }

  Future<void> _checkInitialLikeStatus() async {
    try {
      final likeService = LikeService();
      final likeStatus = await likeService.checkLikeStatus(widget.eventId);

      setState(() {
        isLoved = likeStatus['is_liked'];
        likeId = likeStatus['like_id'];
      });
    } catch (e) {
      print('Error fetching like status: $e');
    }
  }

  void _toggleLike() async {
    // Cek apakah sudah login
    final authService = AuthService();
    final userData = await authService.getUserData();

    if (userData == null) {
      // Tampilkan dialog login
      _showLoginRequiredDialog();
      return;
    }

    // Hindari multiple request
    if (_isLikeLoading) return;

    setState(() {
      _isLikeLoading = true;
    });

    // Simpan status sebelumnya
    final bool previousLikeStatus = isLoved;
    final int? previousLikeId = likeId;

    // Optimistic update
    setState(() {
      isLoved = !isLoved;
      likeId = null;
    });

    final likeService = LikeService();
    final result = await likeService.toggleLike(widget.eventId);

    if (!result['success']) {
      // Jika gagal, kembalikan ke status sebelumnya
      setState(() {
        isLoved = previousLikeStatus;
        likeId = previousLikeId;
        _isLikeLoading = false;
      });

      // Tampilkan snackbar error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(previousLikeStatus
              ? 'Gagal membatalkan like'
              : 'Gagal menambahkan like'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      setState(() {
        isLoved = result['is_liked'];
        likeId = result['like_id'];
        _isLikeLoading = false;
      });
    }
  }

  void shareEvent(Event event) {
    final String shareLink =
        'https://polivent.my.id/event-detail?id=${event.eventId}';
    final String shareContent = 'Ayo segera gabung event ini!\n\n'
        'Title: ${event.title}\n'
        'Date: ${formatDate(event.dateStart)}\n'
        'Location: ${event.location}\n'
        '${event.description}\n\n'
        '$shareLink';

    Share.share(shareContent);
  }

  Future<Event> fetchEventById() async {
    try {
      // Tambahkan timeout untuk mencegah hanging request
      final response = await http
          .get(
        Uri.parse(
            'https://polivent.my.id/api/available_events?event_id=${widget.eventId}'),
      )
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Request timeout');
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        // Penanganan berbagai format respons JSON
        if (jsonResponse is Map<String, dynamic>) {
          // Cek apakah ada nested 'data' key
          if (jsonResponse.containsKey('data')) {
            // Jika 'data' adalah Map
            if (jsonResponse['data'] is Map<String, dynamic>) {
              return Event.fromJson(jsonResponse['data']);
            }
            // Jika 'data' adalah List dan memiliki elemen
            else if (jsonResponse['data'] is List &&
                (jsonResponse['data'] as List).isNotEmpty) {
              return Event.fromJson((jsonResponse['data'] as List).first);
            }
          }

          // Jika tidak ada 'data' key, gunakan response langsung
          return Event.fromJson(jsonResponse);
        } else {
          throw Exception('Unexpected response format: not a map');
        }
      } else {
        // Log error response untuk debugging
        print('Error response: ${response.body}');
        throw Exception(
            'Failed to load event. Status code: ${response.statusCode}');
      }
    } on SocketException {
      // Tangani masalah koneksi internet
      throw Exception('No internet connection');
    } on HttpException {
      // Tangani masalah HTTP
      throw Exception('Failed to fetch event');
    } on FormatException {
      // Tangani masalah parsing JSON
      throw Exception('Bad response format');
    } catch (e) {
      // Tangani error yang tidak terduga
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<void> _registerEvent(int eventId) async {
    try {
      // Tampilkan loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      final authService = AuthService();
      final userData = await authService.getUserData();

      final response = await http.post(
        Uri.parse('$prodApiBaseUrl/registration'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAccessToken()}',
        },
        body: jsonEncode({
          'event_id': eventId,
          'user_id': userData.userId,
        }),
      );

      // Tutup loading indicator
      Navigator.of(context).pop();

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['status'] == 'success') {
          // Ambil detail event untuk mendapatkan tanggal
          final event = await fetchEventById();

          // Tampilkan notifikasi setelah pendaftaran berhasil
          await NotificationService.showEventNotification(
            eventId: eventId,
            eventTitle: event.title,
            eventDate: DateTime.parse(event.dateStart),
          );

          // Tambahkan notifikasi lokal
          _addLocalNotification(
            title: 'Pendaftaran Berhasil',
            message: 'Anda berhasil mendaftar event ${event.title}',
          );

          // Tampilkan popup sukses
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const SuccessJoinPopup();
            },
          );
        } else {
          _showErrorDialog(jsonResponse['message'] ?? 'Gagal mendaftar event');
        }
      } else {
        _handleRegistrationError(response);
      }
    } catch (e) {
      // Tutup loading indicator jika terjadi error
      Navigator.of(context).pop();
      _showErrorDialog('Terjadi kesalahan: $e');
    }
  }

  // Method untuk menambahkan notifikasi lokal
  void _addLocalNotification({
    required String title,
    required String message,
  }) async {
    // Buat notifikasi lokal yang akan disimpan di SharedPreferences
    final notificationItem = NotificationItem(
      title: title,
      message: message,
      time: DateTime.now(),
      type: NotificationType.success,
      isNew: true,
    );

    // Simpan ke SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Ambil daftar notifikasi yang sudah ada
    List<String>? savedNotifications =
        prefs.getStringList('notifications') ?? [];

    // Konversi notifikasi ke JSON
    String notificationJson = json.encode({
      'title': notificationItem.title,
      'message': notificationItem.message,
      'time': notificationItem.time.toIso8601String(),
      'type': notificationItem.type.toString().split('.').last,
      'isNew': notificationItem.isNew,
    });

    // Tambahkan notifikasi baru di awal list
    savedNotifications.insert(0, notificationJson);

    // Simpan kembali ke SharedPreferences
    await prefs.setStringList('notifications', savedNotifications);
  }

// Method untuk menampilkan dialog login yang diperlukan
  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Login Required'),
          content: const Text('You need to be logged in to like this event.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

// Method untuk menampilkan dialog error yang sudah ada
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pendaftaran Gagal'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<String> _getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token') ?? '';
  }

  void _handleRegistrationError(http.Response response) {
    switch (response.statusCode) {
      case 400:
        _showErrorDialog('Permintaan tidak valid');
        break;
      case 401:
        _showErrorDialog('Anda perlu login ulang');
        break;
      case 403:
        _showErrorDialog('Anda tidak memiliki izin');
        break;
      case 404:
        _showErrorDialog('Event tidak ditemukan');
        break;
      case 409:
        _showErrorDialog('Anda sudah terdaftar di event ini');
        break;
      case 500:
        _showErrorDialog('Kesalahan server');
        break;
      default:
        _showErrorDialog('Gagal mendaftar event. Silakan coba lagi');
    }
  }

  // void _showErrorDialog(String message) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Pendaftaran Gagal'),
  //         content: Text(message),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.of(context).pop(),
  //             child: const Text('OK'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PhotoViewScreen(imageUrl: imageUrl),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
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
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 300,
              width: double.infinity,
              color: Colors.white,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 24,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Container(
                        height: 16,
                        width: 200,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Container(
                        height: 16,
                        width: 150,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Container(
                        height: 16,
                        width: 100,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 20,
                        width: 100,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 100,
                        width: double.infinity,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Event>(
        future: futureEvent,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Stack(
              children: [
                _buildLoadingShimmer(),
                // Custom AppBar tetap ditampilkan saat loading
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
                              // if (snapshot.hasData) {
                              //   shareEvent(snapshot.data!);
                              // }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else if (snapshot.hasData) {
            final event = snapshot.data!;
            return Stack(
              children: [
                SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context)
                            .size
                            .height // Sesuaikan tinggi minimal
                        ),
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
                                  // Dalam method build, ubah IconButton like
                                  IconButton(
                                    icon: Icon(
                                      isLoved
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: isLoved ? Colors.red : Colors.grey,
                                    ),
                                    onPressed: _toggleLike,
                                  )
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
                                'Deskripsi',
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
                                        ? event.description
                                        : (event.description.length > 200
                                            ? '${event.description.substring(0, 200)}...'
                                            : event.description),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  if (event.description.length > 200)
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
                                'Komentar',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Inter',
                                ),
                              ),
                              // const SizedBox(height: 8),
                              CommentsSection(eventId: event.eventId),
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ],
                    ),
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
                              // shareEvent(event);
                              ShareBottomSheet.show(
                                context,
                                eventName: event.title,
                                eventPoster: event.poster,
                                eventDate: formatDate(event.dateStart),
                                eventLocation: event.location,
                                eventDescription: event.description,
                                eventLink:
                                    'https://polivent.my.id/event-detail?id=${event.eventId}',
                              );
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
                            // Ubah tombol Join dalam widget build
                            ElevatedButton(
                              onPressed: () {
                                _registerEvent(
                                    event.eventId); // Gunakan method baru ini
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
                        futureEvent = fetchEventById();
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

class PhotoViewScreen extends StatelessWidget {
  final String imageUrl;

  const PhotoViewScreen({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: PhotoView(
        imageProvider: NetworkImage(imageUrl),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 2,
        backgroundDecoration: const BoxDecoration(
          color: Colors.black,
        ),
        loadingBuilder: (context, event) => Center(
          child: CircularProgressIndicator(
            value: event?.expectedTotalBytes != null
                ? event!.cumulativeBytesLoaded / event.expectedTotalBytes!
                : null,
          ),
        ),
      ),
    );
  }
}
