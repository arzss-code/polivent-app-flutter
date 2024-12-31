// ignore_for_file: unnecessary_null_comparison

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:photo_view/photo_view.dart';
import 'package:polivent_app/config/app_config.dart';
import 'package:polivent_app/screens/home/event/photo_view_screen.dart';
import 'package:polivent_app/screens/home/explore/notification.dart';
import 'package:polivent_app/services/like_services.dart';
import 'package:polivent_app/services/auth_services.dart';
import 'package:polivent_app/services/data/events_model.dart';
import 'package:polivent_app/models/share.dart';
import 'package:polivent_app/models/ui_colors.dart';
import 'package:polivent_app/models/comments.dart';
import 'package:polivent_app/screens/home/event/success_join.dart';
import 'package:polivent_app/services/notifikasi/notification_local.dart';
// import 'package:polivent_app/services/data/user_model.dart';
import 'package:polivent_app/services/notifikasi/notification_services.dart';
import 'package:polivent_app/services/token_service.dart';
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

class _DetailEventsState extends State<DetailEvents>
    with TickerProviderStateMixin {
  // User? _currentUser;
  // String _errorMessage = '';
  late Future<Event> futureEvent;
  bool _showFullDescription = false;
  bool isLoved = false;
  int? likeId;
  bool _isLikeLoading = false;
  late ScrollController _scrollController;
  late AnimationController _colorAnimationController;
  late Animation<Color?> _colorTween;
  bool _isAppBarTransparent = true;
  bool _isEventRegistrationDisabled = false;
  String _joinButtonText = 'Daftar Event';
  List<dynamic> invitedUsers = [];
  bool _showAllInvitedUsers = false;

  @override
  void initState() {
    super.initState();

    futureEvent = fetchEventById();
    _initializeJoinButtonState();
    _checkInitialLikeStatus();
    _setupScrollController();
    _setupAnimations();
    // Inisialisasi status tombol
  }

// Method untuk inisialisasi status tombol
  // Metode yang Dioptimasi
  void _initializeJoinButtonState() {
    futureEvent.then((event) async {
      try {
        // Gunakan metode parallel dengan Future.wait untuk efisiensi
        final results = await Future.wait(
            [_isEventEnded(), _isUserJoinedEvent(), _isEventQuotaFull()]);

        // Destructuring hasil
        final bool isEnded = results[0];
        final bool isJoined = results[1];
        final bool isQuotaFull = results[2];

        // Update state dengan logika yang jelas
        _updateButtonState(
            isEnded: isEnded, isJoined: isJoined, isQuotaFull: isQuotaFull);
      } catch (error) {
        // Error handling yang lebih informatif
        _handleJoinButtonStateError(error);
      }
    });
  }

  // Metode error handling khusus
  void _handleJoinButtonStateError(dynamic error) {
    // Logging error yang lebih komprehensif
    debugPrint('Join Button State Error: $error');

    // Optional: Tambahkan error tracking atau pelaporan
    // ErrorReportingService.report(error);

    // Reset ke state default dengan notifikasi
    setState(() {
      _isEventRegistrationDisabled = false;
      _joinButtonText = 'Daftar Event';
    });

    // Optional: Tampilkan snackbar atau pesan error
    _showErrorNotification('Gagal memuat status event');
  }

// Metode opsional untuk notifikasi error
  void _showErrorNotification(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Metode update terpisah dengan parameter
  void _updateJoinButtonState() async {
    try {
      final results = await Future.wait(
          [_isUserJoinedEvent(), _isEventEnded(), _isEventQuotaFull()]);

      _updateButtonState(
          isJoined: results[0], isEnded: results[1], isQuotaFull: results[2]);
    } catch (error) {
      _handleJoinButtonStateError(error);
    }
  }

// Metode pusat untuk update state tombol
  void _updateButtonState(
      {required bool isJoined,
      required bool isEnded,
      required bool isQuotaFull}) {
    setState(() {
      // Logika prioritas status
      if (isJoined) {
        _isEventRegistrationDisabled = true;
        _joinButtonText = 'Sudah Terdaftar';
      } else if (isEnded) {
        _isEventRegistrationDisabled = true;
        _joinButtonText = 'Event Berakhir';
      } else if (isQuotaFull) {
        _isEventRegistrationDisabled = true;
        _joinButtonText = 'Kuota Penuh';
      } else {
        _isEventRegistrationDisabled = false;
        _joinButtonText = 'Daftar Event';
      }
    });
  }

  // // Method untuk memperbarui status tombol
  // void _updateJoinButtonState() async {
  //   try {
  //     final isJoined = await _isUserJoinedEvent();
  //     final isEnded = await _isEventEnded();
  //     final isQuotaFull = await _isEventQuotaFull();

  //     setState(() {
  //       _isEventRegistrationDisabled = isJoined || isEnded || isQuotaFull;

  //       if (isJoined) {
  //         _joinButtonText = 'Sudah Terdaftar';
  //       } else if (isEnded) {
  //         _joinButtonText = 'Event Berakhir';
  //       } else if (isQuotaFull) {
  //         _joinButtonText = 'Kuota Penuh';
  //       } else {
  //         _joinButtonText = 'Daftar Event';
  //       }
  //     });
  //   } catch (error) {
  //     debugPrint('Error updating join button state: $error');
  //   }
  // }

  void _setupScrollController() {
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        setState(() {
          _isAppBarTransparent = _scrollController.offset <= 100;
        });
      }
    });
  }

  void _setupAnimations() {
    _colorAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _colorTween = ColorTween(
      begin: Colors.transparent,
      end: UIColor.primaryColor,
    ).animate(_colorAnimationController);
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
      debugPrint('Error fetching like status: $e');
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

  Future<void> shareEvent(Event event) async {
    // Buat deep link dengan domain yang sudah dikonfigurasi
    final String shareLink =
        'https://polivent.my.id/event-detail/${event.eventId}';

    // Buat konten share yang informatif
    final String shareContent = 'Yuk ikuti event menarik ini!\n\n'
        '*${event.title}*\n\n'
        'Tanggal: ${formatDate(event.dateStart)}\n'
        'Lokasi: ${event.location}\n'
        '${event.description}\n\n'
        'Selengkapnya: $shareLink';

    try {
      // Cek apakah ada poster/gambar untuk dibagikan
      File? imageFile;
      if (event.poster != null) {
        imageFile = await _downloadImage(event.poster!);
      }

      // Share dengan atau tanpa gambar
      if (imageFile != null) {
        await Share.shareXFiles(
          [XFile(imageFile.path)],
          text: shareContent,
          subject: 'Bagikan Event: ${event.title}',
        );
      } else {
        await Share.share(
          shareContent,
          subject: 'Bagikan Event: ${event.title}',
        );
      }
    } catch (e) {
      print('Gagal membagikan event: $e');
      // Tampilkan pesan error jika diperlukan
    }
  }

// Fungsi download gambar opsional
  Future<File?> _downloadImage(String imageUrl) async {
    try {
      // Gunakan package http atau dio untuk download
      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        // Simpan gambar sementara
        final directory = await getTemporaryDirectory();
        final imagePath = '${directory.path}/event_poster.png';

        final File imageFile = File(imagePath);
        await imageFile.writeAsBytes(response.bodyBytes);

        return imageFile;
      }
    } catch (e) {
      print('Gagal download gambar: $e');
    }
    return null;
  }

  Future<Event> fetchEventById() async {
    try {
      // Tambahkan timeout untuk mencegah hanging request
      final response = await http.get(
        Uri.parse(
            'https://polivent.my.id/api/available_events?event_id=${widget.eventId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await TokenService.getAccessToken()}',
        },
      ).timeout(
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

          // Pastikan parsing invited_users
          if (jsonResponse['invited_users'] != null) {
            print(
                'Invited Users Count: ${jsonResponse['invited_users'].length}');
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
          'Authorization': 'Bearer ${await TokenService.getAccessToken()}',
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

          // Jadwalkan pengingat event
          await EventNotificationService.sendEventReminderNotification(
            event: event,
            user: userData, // Pastikan Anda memiliki data user saat ini
            daysBeforeEvent: 1, // Pengingat H-1
          );

          // Jadwalkan pengingat event
          await EventNotificationService.sendEventReminderNotification(
            event: event,
            user: userData, // Pastikan Anda memiliki data user saat ini
            daysBeforeEvent: 3, // Pengingat H-1
          );

          // Jadwalkan pengingat event
          await NotificationService.saveNotificationToLocal(
            title: 'Pengingat Event',
            body: 'Jangan lupa untuk menghadiri event ${event.title}!',
            payload: {
              'event_id': event.eventId.toString(),
              'type': 'event_reminder',
              'event_title': event.title,
              'event_location': event.location,
              'event_date': event.dateStart,
            },
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
      _updateJoinButtonState();
    } catch (e) {
      // Tutup loading indicator jika terjadi error
      Navigator.of(context).pop();
      _showErrorDialog('Terjadi kesalahan: $e');
    }
  }

  Future<bool> _checkJoinButtonState() async {
    final isJoined = await _isUserJoinedEvent();
    final isEnded = await _isEventEnded();
    final isQuotaFull = await _isEventQuotaFull();

    return isJoined || isEnded || isQuotaFull;
  }

  Future<Map<String, dynamic>> _getJoinButtonState() async {
    final isJoined = await _isUserJoinedEvent();
    final isEnded = await _isEventEnded();
    final isQuotaFull = await _isEventQuotaFull();

    // Ubah kondisi menjadi perbandingan boolean yang eksplisit
    if (isJoined == true) {
      return {'isDisabled': true, 'text': 'Sudah Terdaftar'};
    }

    if (isEnded == true) {
      return {'isDisabled': true, 'text': 'Event Berakhir'};
    }

    if (isQuotaFull == true) {
      return {'isDisabled': true, 'text': 'Kuota Penuh'};
    }

    return {'isDisabled': false, 'text': 'Daftar Event'};
  }

  Future<bool> _isUserJoinedEvent() async {
    try {
      final authService = AuthService();
      final userData = await authService.getUserData();

      final response = await http.get(
        Uri.parse(
            '$prodApiBaseUrl/registration?user_id=${userData.userId}&event_id=${widget.eventId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await TokenService.getAccessToken()}',
        },
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        return result['data']['isJoined'];
      }
      return false;
    } catch (error) {
      print('Error checking joined event: $error');
      return false;
    }
  }

  Future<bool> _isEventEnded() async {
    try {
      final response = await http.get(
        Uri.parse(
            '$prodApiBaseUrl/available_events?event_id=${widget.eventId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await TokenService.getAccessToken()}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        final eventEndDate = DateTime.parse(data['date_end']);
        return DateTime.now().isAfter(eventEndDate);
      }
      return false;
    } catch (error) {
      debugPrint('Error checking event end date: $error');
      return false;
    }
  }

  Future<bool> _isEventQuotaFull() async {
    try {
      final response = await http.get(
        Uri.parse(
            '$prodApiBaseUrl/available_events?event_id=${widget.eventId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await TokenService.getAccessToken()}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        return data['quota'] == 0;
      }
      return false;
    } catch (error) {
      debugPrint('Error checking event quota: $error');
      return false;
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
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  Colors.red.withOpacity(0.1),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Gradient Header
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Pendaftaran Gagal',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[800],
                      ),
                    ),
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.warning_rounded,
                        color: Colors.red[400],
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        message,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[800],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Tutup',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleRegistrationError(http.Response response) {
    final data = json.decode(response.body);
    switch (response.statusCode) {
      case 400:
        _showErrorDialog('Permintaan tidak valid');
        break;
      case 401:
        _showErrorDialog('Anda perlu login ulang');
        break;
      case 403:
        _showErrorDialog('Gagal, Hanya member yang bisa mendaftar!');
        break;
      case 404:
        _showErrorDialog('Event tidak ditemukan');
        break;
      case 409:
        if (data['message'] == 'User has already joined this event!') {
          _showErrorDialog('Anda sudah terdaftar pada event ini!');
        } else if (data['message'] == 'No available quota for this event') {
          _showErrorDialog('Gagal, kuota telah habis!');
        }
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
      final formatter = DateFormat('EEEE, d MMMM yyyy', 'id_ID');
      return formatter.format(date);
    } catch (e) {
      return dateString; // Return original string if parsing fails
    }
  }

  // Widget buildEventImage(String imageUrl) {
  //   return GestureDetector(
  //     onTap: () {
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => PhotoViewScreen(imageUrl: imageUrl),
  //         ),
  //       );
  //     },
  //     child: ClipRRect(
  //       borderRadius: const BorderRadius.only(
  //         bottomLeft: Radius.circular(12),
  //         bottomRight: Radius.circular(12),
  //       ),
  //       child: Image.network(
  //         imageUrl,
  //         fit: BoxFit.cover,
  //         height: 300,
  //         width: double.infinity,
  //         loadingBuilder: (context, child, loadingProgress) {
  //           if (loadingProgress == null) return child;
  //           return Center(
  //             child: CircularProgressIndicator(
  //               value: loadingProgress.expectedTotalBytes != null
  //                   ? loadingProgress.cumulativeBytesLoaded /
  //                       loadingProgress.expectedTotalBytes!
  //                   : null,
  //             ),
  //           );
  //         },
  //         errorBuilder: (context, error, stackTrace) {
  //           return Container(
  //             height: 300,
  //             color: Colors.grey[300],
  //             child: const Center(
  //               child: Icon(Icons.error_outline, size: 50, color: Colors.grey),
  //             ),
  //           );
  //         },
  //       ),
  //     ),
  //   );
  // }

  Widget _buildInfoPropose(Event event) {
    return Card(
      elevation: 0,
      color: Colors.grey[50],
      margin: const EdgeInsets.fromLTRB(0, 4, 0, 24),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: event.proposeUserAvatar != null
                  ? NetworkImage(event.proposeUserAvatar!)
                  : const AssetImage('assets/images/default-avatar.jpg')
                      as ImageProvider,
              radius: 20,
              onBackgroundImageError: (exception, stackTrace) {
                debugPrint('Error loading propose user avatar: $exception');
              },
              backgroundColor: Colors.grey[300],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.proposeUser ?? 'Unknown User',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  // const SizedBox(height: 4),
                  const Text(
                    'Propose',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvitedUsers(Event event) {
    debugPrint('Invited Users: ${event.invitedUsers}');

    if (event.invitedUsers == null || event.invitedUsers!.isEmpty) {
      return const SizedBox.shrink();
    }

    // Tentukan berapa banyak user yang akan ditampilkan
    final usersToShow = _showAllInvitedUsers
        ? event.invitedUsers!
        : event.invitedUsers!.take(5).toList();

    return Card(
      elevation: 0,
      color: Colors.grey[50],
      margin: const EdgeInsets.fromLTRB(0, 4, 0, 24),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Undangan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (event.invitedUsers!.length > 5)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showAllInvitedUsers = !_showAllInvitedUsers;
                      });
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(50, 30),
                    ),
                    child: Text(
                      _showAllInvitedUsers
                          ? 'Tampilkan sedikit'
                          : 'Lihat semua (${event.invitedUsers!.length})',
                      style: const TextStyle(
                        color: UIColor.primaryColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            // const SizedBox(height: 12),
            Column(
              children: usersToShow.map((user) {
                debugPrint('User: ${user.username}, Avatar: ${user.avatar}');

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: user.avatar != null
                            ? NetworkImage(user.avatar!.startsWith('/')
                                ? 'https://polivent.my.id${user.avatar}'
                                : user.avatar!)
                            : const AssetImage(
                                    'assets/images/default-avatar.jpg')
                                as ImageProvider,
                        onBackgroundImageError: (exception, stackTrace) {
                          debugPrint('Error loading avatar image: $exception');
                        },
                        backgroundColor: Colors.grey[300],
                      ),
                      const SizedBox(width: 12),
                      Text(
                        user.username,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
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
            return _buildLoadingShimmerWithAppBar();
          } else if (snapshot.hasData) {
            final event = snapshot.data!;
            return Stack(
              children: [
                CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    _buildSliverAppBar(event),
                    SliverToBoxAdapter(
                      child: _buildEventDetails(event),
                    ),
                  ],
                ),
                _buildBottomJoinButton(
                    event), // Gunakan method yang sudah dimodifikasi
                _buildFloatingAppBar(),
              ],
            );
          } else if (snapshot.hasError) {
            return _buildErrorView(snapshot.error.toString());
          } else {
            return const Center(child: Text('No event data available'));
          }
        },
      ),
    );
  }

  Widget _buildSliverAppBar(Event event) {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      expandedHeight: 300,
      pinned: false,
      backgroundColor:
          _isAppBarTransparent ? Colors.transparent : Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PhotoViewScreen(imageUrl: event.poster),
              ),
            );
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Gunakan Image.network langsung di sini
              Image.network(
                event.poster,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
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
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.error_outline,
                          size: 50, color: Colors.grey),
                    ),
                  );
                },
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                    ],
                  ),
                ),
              ),
              // Tambahkan judul event di sini
              Positioned(
                bottom: 16,
                left: 16,
                child: Opacity(
                  opacity: _isAppBarTransparent ? 0 : 1,
                  child: Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventDetails(Event event) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEventHeader(event),
          _buildEventInfo(event),
          _buildInfoPropose(event),
          _buildInvitedUsers(event),
          _buildDescriptionSection(event),
          _buildCommentsSection(event),
          const SizedBox(height: 100), // Space for bottom button
        ],
      ),
    );
  }

  Widget _buildEventHeader(Event event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                event.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            _buildLikeButton(),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: UIColor.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Free Event',
                style: TextStyle(
                  color: UIColor.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: UIColor.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                event.category ?? 'Umum',
                style: const TextStyle(
                  color: UIColor.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEventInfo(Event event) {
    return Card(
      elevation: 0,
      color: Colors.grey[50],
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow(
              UIconsPro.regularRounded.ticket_alt,
              '${event.quota} Tiket Tersedia',
            ),
            const Divider(height: 24),
            _buildInfoRow(
              UIconsPro.regularRounded.map_marker,
              event.location,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              UIconsPro.regularRounded.house_building,
              event.place,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              UIconsPro.regularRounded.calendar,
              '${formatDate(event.dateStart)}\n- ${formatDate(event.dateEnd)}',
            ),
            const Divider(height: 24),
            _buildInfoRow(
              UIconsPro.regularRounded.clock,
              '${DateFormat('HH:mm').format(DateTime.parse(event.dateStart).toLocal())} - ${DateFormat('HH:mm').format(DateTime.parse(event.dateEnd).toLocal())} WIB',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection(Event event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Deskripsi Event',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 12),
        AnimatedCrossFade(
          firstChild: Text(
            event.description,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
          secondChild: Text(
            event.description.length > 200
                ? '${event.description.substring(0, 200)}...'
                : event
                    .description, // Fallback to the full description if it's less than 200 characters
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
          crossFadeState: _showFullDescription
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          duration: const Duration(milliseconds: 300),
        ),
        if (event.description.length > 200)
          TextButton(
            onPressed: () =>
                setState(() => _showFullDescription = !_showFullDescription),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _showFullDescription ? 'Show Less' : 'Read More',
                  style: const TextStyle(color: UIColor.primaryColor),
                ),
                Icon(
                  _showFullDescription
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: UIColor.primaryColor,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFloatingAppBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 48,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _isAppBarTransparent
                  ? Colors.black.withOpacity(0.7)
                  : Colors.black.withOpacity(0.7),
              _isAppBarTransparent ? Colors.transparent : Colors.transparent
            ],
          ),
        ),
        child: Row(
          children: [
            // Tombol Kembali
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
            // Judul Event
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
            // Tombol Berbagi
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
                  // Pastikan futureEvent sudah terisi
                  futureEvent.then((event) {
                    shareEvent(event); // Panggil fungsi shareEvent
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Oops! Something went wrong',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: UIColor.primaryColor,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
            onPressed: () {
              setState(() {
                futureEvent = fetchEventById();
              });
            },
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text(
              'Try Again',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsSection(Event event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text(
          'Komentar',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 16),
        CommentsSection(eventId: event.eventId),
      ],
    );
  }

  // Atau alternatif lain:
  // Method build untuk tombol join
  Widget _buildBottomJoinButton(Event event) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        // child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _isEventRegistrationDisabled
                    ? null
                    : () => _registerEvent(event.eventId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isEventRegistrationDisabled
                      ? Colors.grey[300]
                      : UIColor.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: Text(
                  _joinButtonText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _isEventRegistrationDisabled
                        ? Colors.grey
                        : Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        // ),
      ),
    );
  }

  // Helper Widgets
  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: UIColor.primaryColor, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLikeButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(50),
        onTap: _toggleLike,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isLoved ? Colors.red.withOpacity(0.1) : Colors.transparent,
          ),
          child: Icon(
            isLoved ? Icons.favorite : Icons.favorite_border,
            color: isLoved ? Colors.red : Colors.grey,
            size: 28,
          ),
        ),
      ),
    );
  }
  // ... (previous code remains the same until the missing method)

  Widget _buildLoadingShimmerWithAppBar() {
    return Stack(
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event Image Placeholder
                Container(
                  height: 300,
                  width: double.infinity,
                  color: Colors.white,
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title Placeholder
                      Container(
                        height: 28,
                        width: MediaQuery.of(context).size.width * 0.7,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      // Info Card Placeholder
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            // Tickets Info
                            Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  height: 16,
                                  width: 150,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Location Info
                            Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  height: 16,
                                  width: 200,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Date Info
                            Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  height: 16,
                                  width: 180,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Description Section
                      Container(
                        height: 24,
                        width: 120,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      // Description Lines
                      ...List.generate(
                          4,
                          (index) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Container(
                                  height: 16,
                                  width: double.infinity,
                                  color: Colors.white,
                                ),
                              )),
                      const SizedBox(height: 24),
                      // Comments Section
                      Container(
                        height: 24,
                        width: 100,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      // Comment Placeholders
                      ...List.generate(
                          3,
                          (index) => Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Container(
                                          height: 16,
                                          width: 120,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      height: 16,
                                      width: double.infinity,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              )),
                      const SizedBox(height: 100), // Space for bottom button
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Floating App Bar
        _buildFloatingAppBar(),
        // Bottom Join Button Placeholder
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

// Tambahkan method dispose() di sini
  @override
  void dispose() {
    _scrollController.dispose();
    _colorAnimationController.dispose();
    super.dispose();
  }
// ... (rest of the previous code remains the same)
}
