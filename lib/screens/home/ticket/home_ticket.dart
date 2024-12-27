import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:polivent_app/config/app_config.dart';
import 'package:polivent_app/models/ui_colors.dart';
import 'package:polivent_app/screens/auth/login_screen.dart';
import 'package:polivent_app/screens/home/ticket/detail_ticket.dart';
import 'package:polivent_app/services/auth_services.dart';
// import 'package:polivent_app/services/data/events_model.dart';
import 'package:polivent_app/services/data/registration_model.dart';
import 'package:polivent_app/services/token_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:uicons_pro/uicons_pro.dart';

class EventHistoryPage extends StatefulWidget {
  const EventHistoryPage({super.key});

  @override
  _EventHistoryPageState createState() => _EventHistoryPageState();
}

class _EventHistoryPageState extends State<EventHistoryPage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  List<Registration> _upcomingEvents = [];
  List<Registration> _pastEvents = [];
  bool _isLoading = true;
  String _errorMessage = '';
  final TextEditingController _searchController = TextEditingController();

  final _connectivity = Connectivity();
  int _retryCount = 0;
  static const int _maxRetries = 3;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeEventHistory();
  }

  Future<void> _initializeEventHistory() async {
    // await _loadDummyEvents();
    await _checkConnectivityAndFetchEvents();
  }

  Future<void> _loadDummyEvents() async {
    // Dummy data untuk event yang akan datang
    _upcomingEvents = [
      Registration(
        eventId: 1,
        registId: 1,
        registrationTime: DateTime.now().toIso8601String(),
        username: 'user1',
        title: 'Seminar Teknologi Terbaru',
        categoryName: 'Teknologi',
        place: 'Aula Utama Polinema',
        location: 'Kampus Polinema, Malang',
        dateStart: DateTime.now().add(Duration(days: 10)).toIso8601String(),
        dateEnd: DateTime.now().add(Duration(days: 11)).toIso8601String(),
        quota: 100,
        poster:
            'https://images.unsplash.com/photo-1488590528505-98d2b5ade38b?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1170&q=80',
        description:
            'Seminar teknologi terkini dengan pembicara ahli di bidang teknologi informasi',
        categoryId: 1,
      ),
      Registration(
        eventId: 2,
        registId: 2,
        registrationTime: DateTime.now().toIso8601String(),
        username: 'user2',
        title: 'Workshop Kewirausahaan Digital',
        categoryName: 'Bisnis',
        place: 'Gedung Rektorat',
        location: 'Universitas Negeri Malang',
        dateStart: DateTime.now().add(Duration(days: 15)).toIso8601String(),
        dateEnd: DateTime.now().add(Duration(days: 16)).toIso8601String(),
        quota: 50,
        poster:
            'https://images.unsplash.com/photo-1661956602116-aa6865609028?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1170&q=80',
        description:
            'Workshop pengembangan keterampilan kewirausahaan di era digital',
        categoryId: 2,
      ),
      Registration(
        eventId: 3,
        registId: 3,
        registrationTime: DateTime.now().toIso8601String(),
        username: 'user3',
        title: 'Konferensi Ilmiah Nasional',
        categoryName: 'Pendidikan',
        place: 'Gedung Konferensi Nasional',
        location: 'Jakarta Convention Center',
        dateStart: DateTime.now().add(Duration(days: 20)).toIso8601String(),
        dateEnd: DateTime.now().add(Duration(days: 22)).toIso8601String(),
        quota: 200,
        poster:
            'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1170&q=80',
        description:
            'Konferensi ilmiah membahas perkembangan penelitian terkini',
        categoryId: 3,
      ),
      Registration(
        eventId: 4,
        registId: 4,
        registrationTime: DateTime.now().toIso8601String(),
        username: 'user4',
        title: 'Pameran Seni Mahasiswa',
        categoryName: 'Seni',
        place: 'Galeri Seni Kampus',
        location: 'Institut Seni Indonesia Yogyakarta',
        dateStart: DateTime.now().add(Duration(days: 25)).toIso8601String(),
        dateEnd: DateTime.now().add(Duration(days: 27)).toIso8601String(),
        quota: 75,
        poster:
            'https://images.unsplash.com/photo-1532453288672-3a27e9be9972?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1074&q=80',
        description: 'Pameran karya seni mahasiswa dari berbagai jurusan',
        categoryId: 4,
      ),
      Registration(
        eventId: 5,
        registId: 5,
        registrationTime: DateTime.now().toIso8601String(),
        username: 'user5',
        title: 'Kompetisi Robotika Nasional',
        categoryName: 'Teknologi',
        place: 'Pusat Teknologi',
        location: 'Bandung',
        dateStart: DateTime.now().add(Duration(days: 30)).toIso8601String(),
        dateEnd: DateTime.now().add(Duration(days: 32)).toIso8601String(),
        quota: 50,
        poster:
            'https://images.unsplash.com/photo-1485827404155-7c0288c6420a?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1170&q=80',
        description: 'Kompetisi robotika tingkat nasional untuk mahasiswa',
        categoryId: 1,
      ),
    ];

    // Dummy data untuk event yang sudah selesai
    _pastEvents = [
      Registration(
        eventId: 6,
        registId: 6,
        registrationTime: DateTime.now().toIso8601String(),
        username: 'user6',
        title: 'Seminar Kesehatan Mental',
        categoryName: 'Kesehatan',
        place: 'Aula Utama Rumah Sakit',
        location: 'Surabaya',
        dateStart: DateTime.now().add(Duration(days: 35)).toIso8601String(),
        dateEnd: DateTime.now().add(Duration(days: 36)).toIso8601String(),
        quota: 100,
        poster:
            'https://images.unsplash.com/photo-1532938911079-1b06ac7ceec7?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1171&q=80',
        description:
            'Seminar tentang pentingnya kesehatan mental di kalangan muda',
        categoryId: 5,
      ),
      Registration(
        eventId: 7,
        registId: 7,
        registrationTime: DateTime.now().toIso8601String(),
        username: 'user7',
        title: 'Workshop Fotografi',
        categoryName: 'Seni',
        place: 'Studio Fotografi',
        location: 'Yogyakarta',
        dateStart: DateTime.now().add(Duration(days: 40)).toIso8601String(),
        dateEnd: DateTime.now().add(Duration(days: 41)).toIso8601String(),
        quota: 30,
        poster:
            'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?ixlib= rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1170&q=80',
        description: 'Workshop untuk meningkatkan keterampilan fotografi',
        categoryId: 4,
      ),
      Registration(
        eventId: 8,
        registId: 8,
        registrationTime: DateTime.now().toIso8601String(),
        username: 'user8',
        title: 'Pelatihan Public Speaking',
        categoryName: 'Keterampilan',
        place: 'Ruang Seminar',
        location: 'Jakarta',
        dateStart: DateTime.now().add(Duration(days: 45)).toIso8601String(),
        dateEnd: DateTime.now().add(Duration(days: 46)).toIso8601String(),
        quota: 40,
        poster:
            'https://images.unsplash.com/photo-1506748686214-e9df14d4d9d0?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1170&q=80',
        description:
            'Pelatihan untuk meningkatkan kemampuan berbicara di depan umum',
        categoryId: 2,
      ),
      Registration(
        eventId: 9,
        registId: 9,
        registrationTime: DateTime.now().toIso8601String(),
        username: 'user9',
        title: 'Festival Musik Mahasiswa',
        categoryName: 'Hiburan',
        place: 'Lapangan Kampus',
        location: 'Bali',
        dateStart: DateTime.now().add(Duration(days: 50)).toIso8601String(),
        dateEnd: DateTime.now().add(Duration(days: 52)).toIso8601String(),
        quota: 500,
        poster:
            'https://images.unsplash.com/photo-1506748686214-e9df14d4d9d0?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1170&q=80',
        description: 'Festival musik yang menampilkan berbagai band mahasiswa',
        categoryId: 6,
      ),
      Registration(
        eventId: 10,
        registId: 10,
        registrationTime: DateTime.now().toIso8601String(),
        username: 'user10',
        title: 'Lomba Cipta Puisi',
        categoryName: 'Seni',
        place: 'Ruang Kesenian',
        location: 'Malang',
        dateStart: DateTime.now().add(Duration(days: 55)).toIso8601String(),
        dateEnd: DateTime.now().add(Duration(days: 56)).toIso8601String(),
        quota: 100,
        poster:
            'https://images.unsplash.com/photo-1506748686214-e9df14d4d9d0?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1170&q=80',
        description: 'Lomba untuk menyalurkan kreativitas dalam menulis puisi',
        categoryId: 4,
      ),
    ];

    setState(() {
      _isLoading = false;
    });
  }

  Future<bool> _checkConnectivityAndFetchEvents({String search = ''}) async {
    var connectivityResult = await _connectivity.checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _errorMessage = 'Tidak ada koneksi internet';
        _isLoading = false;
      });
      return false;
    }

    return await _fetchEventsWithRetry(search: search);
  }

  Future<bool> _fetchEventsWithRetry({String search = ''}) async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final authService = AuthService();
      final userData = await authService.getUserData();

      if (userData == null) {
        throw Exception('User tidak ditemukan');
      }

      // Ambil access token dari TokenService
      final accessToken = await TokenService.getAccessToken();

      if (accessToken == null) {
        throw Exception('Access token tidak ditemukan');
      }

      // Debug print informasi request
      debugPrint('Fetching Events');
      debugPrint('User ID: ${userData.userId}');
      debugPrint('Search Query: $search');

      // Header authorization
      final headers = {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };

      // Upcoming Events
      final upcomingUrl = _buildUrl(
        path: '/registration',
        params: {
          'user_id': userData.userId,
          'not_present': 'true',
          if (search.isNotEmpty) 'search': search,
        },
      );

      // Past Events
      final pastUrl = _buildUrl(
        path: '/registration',
        params: {
          'user_id': userData.userId,
          'present': 'true',
          if (search.isNotEmpty) 'search': search,
        },
      );

      // Debug print URLs
      debugPrint('Upcoming Events URL: $upcomingUrl');
      debugPrint('Past Events URL: $pastUrl');

      // Fetch upcoming events
      final upcomingResponse =
          await http.get(Uri.parse(upcomingUrl), headers: headers).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('Upcoming Events Request Timeout');
          throw TimeoutException('Koneksi timeout');
        },
      );

      final pastResponse =
          await http.get(Uri.parse(pastUrl), headers: headers).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('Past Events Request Timeout');
          throw TimeoutException('Koneksi timeout');
        },
      );

      // Debug print response status codes
      debugPrint('Upcoming Events Status Code: ${upcomingResponse.statusCode}');
      debugPrint('Past Events Status Code: ${pastResponse.statusCode}');

      // Validasi response
      if (upcomingResponse.statusCode == 200 &&
          pastResponse.statusCode == 200) {
        try {
          final upcomingData = json.decode(upcomingResponse.body);
          final pastData = json.decode(pastResponse.body);

          // Debug print response bodies
          debugPrint('Upcoming Events Response: $upcomingData');
          debugPrint('Past Events Response: $pastData');

          setState(() {
            _upcomingEvents = (upcomingData['data'] as List)
                .map((json) => Registration.fromJson(json))
                .toList();
            _pastEvents = (pastData['data'] as List)
                .map((json) => Registration.fromJson(json))
                .toList();

            // Debug print event counts
            debugPrint('Upcoming Events Count: ${_upcomingEvents.length}');
            debugPrint('Past Events Count: ${_pastEvents.length}');

            _isLoading = false;
            _retryCount = 0;
          });

          return true;
        } catch (parseError) {
          // Error parsing JSON
          debugPrint('JSON Parsing Error: $parseError');
          throw Exception('Gagal memproses data events');
        }
      } else {
        // Tangani error berdasarkan status code
        _handleHttpError(upcomingResponse.statusCode, pastResponse.statusCode);
        return false;
      }
    } catch (e) {
      _handleFetchError(e);
      return false;
    }
  }

  String _buildUrl({
    required String path,
    Map<String, dynamic>? params,
  }) {
    // Gunakan baseUrl yang diberikan atau default
    const effectiveBaseUrl = prodApiBaseUrl;

    // Bangun query parameters
    final queryParams = params?.entries
        .map((entry) =>
            '${entry.key}=${Uri.encodeComponent(entry.value.toString())}')
        .join('&');

    // Gabungkan URL
    return queryParams != null
        ? '$effectiveBaseUrl$path?$queryParams'
        : '$effectiveBaseUrl$path';
  }

  void _handleHttpError(int upcomingStatusCode, int pastStatusCode) {
    debugPrint(
        'HTTP Error - Upcoming: $upcomingStatusCode, Past: $pastStatusCode');

    String errorMessage = 'Terjadi kesalahan';

    // Tangani berbagai status code
    if (upcomingStatusCode == 401 || pastStatusCode == 401) {
      errorMessage = 'Sesi Anda telah berakhir. Silakan login ulang.';
      // Logout user atau refresh token
      _forceLogout();
    } else if (upcomingStatusCode == 403 || pastStatusCode == 403) {
      errorMessage = 'Anda tidak memiliki akses';
    } else if (upcomingStatusCode == 404 || pastStatusCode == 404) {
      errorMessage = 'Sumber data tidak ditemukan';
    } else if (upcomingStatusCode >= 500 || pastStatusCode >= 500) {
      errorMessage = 'Kesalahan server. Silakan coba lagi nanti.';
    }

    setState(() {
      _errorMessage = errorMessage;
      _isLoading = false;
    });
  }

  void _handleFetchError(dynamic error) {
    debugPrint('Event History Fetch Error: $error');

    setState(() {
      _errorMessage = _getErrorMessage(error);
      _isLoading = false;
    });

    // Retry mechanism
    if (_retryCount < _maxRetries) {
      _retryCount++;
      debugPrint('Retry attempt: $_retryCount');
      Future.delayed(Duration(seconds: 2 * _retryCount), () {
        _checkConnectivityAndFetchEvents();
      });
    } else {
      debugPrint('Max retries reached. Stopping retry attempts.');
    }
  }

  String _getErrorMessage(dynamic error) {
    debugPrint('Error Type: ${error.runtimeType}');

    if (error is TimeoutException) {
      return 'Koneksi timeout. Periksa koneksi internet Anda.';
    } else if (error is SocketException) {
      return 'Tidak ada koneksi internet. Silakan periksa jaringan Anda.';
    } else if (error is http.ClientException) {
      return 'Gagal terhubung ke server. Periksa koneksi internet.';
    } else {
      return 'Terjadi kesalahan: ${error.toString()}';
    }
  }

  void _forceLogout() async {
    // Implementasi logout
    await AuthService().logout(context);

    // Navigasi ke halaman login
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Hapus tombol back
        centerTitle: true,
        backgroundColor:
            UIColor.solidWhite, // Sesuaikan dengan warna di kode asli
        title: const Text(
          "Tiket Saya",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color:
                UIColor.typoBlack, // Sesuaikan dengan warna teks di kode asli
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: UIColor.primaryColor, // Warna tab yang aktif
          unselectedLabelColor: UIColor.typoGray, // Warna tab yang tidak aktif
          indicatorColor: UIColor.primaryColor, // Warna garis indikator
          tabs: const [
            Tab(text: 'Akan Datang'),
            Tab(text: 'Selesai'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _checkConnectivityAndFetchEvents(),
        child: Column(
          children: [
            // Search Bar dengan desain yang mirip kode asli
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari tiket',
                  hintStyle:
                      const TextStyle(color: UIColor.typoGray, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: UIColor.typoGray),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  // enabledBorder: OutlineInputBorder(
                  //   borderRadius: BorderRadius.circular(10),
                  //   // borderSide: const BorderSide(color: UIColor.typoGray),
                  // ),
                  // focusedBorder: OutlineInputBorder(
                  //   borderRadius: BorderRadius.circular(10),
                  //   // borderSide: const BorderSide(color: UIColor.primaryColor),
                  // ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon:
                              const Icon(Icons.clear, color: UIColor.typoGray),
                          onPressed: () {
                            _searchController.clear();
                            _checkConnectivityAndFetchEvents(); // Reset pencarian
                          },
                        )
                      : null,
                ),
                style: const TextStyle(color: UIColor.typoBlack),
                onChanged: (value) {
                  // Debounce pencarian
                  Future.delayed(const Duration(milliseconds: 500), () {
                    _checkConnectivityAndFetchEvents(search: value);
                  });
                },
              ),
            ),

            // Sisanya tetap sama seperti sebelumnya
            if (_isLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_errorMessage.isNotEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 60),
                      const SizedBox(height: 16),
                      Text(
                        'Error: $_errorMessage',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: UIColor.primaryColor,
                        ),
                        onPressed: () => _checkConnectivityAndFetchEvents(),
                        child: const Text(
                          'Coba Lagi',
                          style: TextStyle(color: UIColor.white),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildEventList(_upcomingEvents, isUpcoming: true),
                    _buildEventList(_pastEvents, isUpcoming: false),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventList(List<Registration> events, {bool isUpcoming = true}) {
    if (events.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage('assets/images/no-tickets.png'),
              width: 150,
              height: 150,
            ),
            SizedBox(height: 12),
            Text(
              "Tidak Ada Event",
              style: TextStyle(
                color: UIColor.primaryColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 48.0),
              child: Text(
                "Saat ini tidak ada event yang tersedia. Silakan periksa kembali nanti untuk pembaruan.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 20, bottom: 20),
      itemCount: events.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: _buildEventCard(events[index], isUpcoming),
        );
      },
    );
  }

  Widget _buildEventCard(Registration event, bool isUpcoming) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
              color: isUpcoming ? UIColor.primaryColor : Colors.grey, width: 6),
        ),
        color: UIColor.solidWhite,
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(6)),
                  child: Image.network(
                    event.poster,
                    height: 120,
                    width: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 120,
                        width: 90,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported),
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 8, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        '${event.categoryName}: ${event.title}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: UIColor.typoBlack,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      _buildInfoRow(UIconsPro.regularRounded.user_time,
                          '${event.quota} peserta'),
                      _buildInfoRow(
                          UIconsPro.regularRounded.house_building, event.place),
                      _buildInfoRow(
                          UIconsPro.regularRounded.marker, event.location),
                      _buildInfoRow(UIconsPro.regularRounded.calendar,
                          _formatEventDate(event)),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Buttons Section
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _navigateToDetailScreen(event);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isUpcoming
                          ? UIColor.primaryColor
                          : UIColor.solidWhite,
                      foregroundColor: isUpcoming
                          ? UIColor.solidWhite
                          : UIColor.primaryColor,
                      side: const BorderSide(color: UIColor.primaryColor),
                    ),
                    child: const Text("Lihat Detail"),
                  ),
                ),
                if (!isUpcoming) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _showReviewDialog(event);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: UIColor.primaryColor,
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: UIColor.primaryColor),
                      ),
                      child: const Text("Beri Ulasan"),
                    ),
                  ),
                ],
              ],
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
          Icon(icon, color: UIColor.primaryColor, size: 12),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
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

  String _formatEventDate(Registration event) {
    final startDate = DateTime.parse(event.dateStart);
    final endDate = DateTime.parse(event.dateEnd);

    final formatter = DateFormat('dd MMM yyyy');
    return '${formatter.format(startDate)} - ${formatter.format(endDate)}';
  }

  // Fungsi navigasi di dalam EventHistoryPage
  void _navigateToDetailScreen(Registration event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TicketDetailPage(registration: event),
      ),
    );
  }

  void _showReviewDialog(Registration event) {
    int _rating = 0;
    final TextEditingController reviewController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      backgroundColor: Colors.white,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Judul dan Close Button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Beri Ulasan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: UIColor.primaryColor,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              // Nama Event
              Text(
                event.title,
                style: const TextStyle(
                  fontSize: 16,
                  color: UIColor.typoGray,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 20),

              // Rating Bintang
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _rating = index + 1;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        index < _rating ? Icons.star : Icons.star_border,
                        color: UIColor.primaryColor,
                        size: 40,
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 20),

              // Input Ulasan
              TextField(
                controller: reviewController,
                decoration: InputDecoration(
                  hintText: 'Ceritakan pengalaman Anda mengikuti event',
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: UIColor.primaryColor.withOpacity(0.5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: UIColor.primaryColor,
                      width: 2,
                    ),
                  ),
                ),
                maxLines: 4,
                cursorColor: UIColor.primaryColor,
              ),

              const SizedBox(height: 20),

              // Tombol Kirim
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Validasi input
                    final review = reviewController.text.trim();

                    if (_rating == 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Silakan pilih rating'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (review.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ulasan tidak boleh kosong'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // Proses penyimpanan ulasan
                    _saveReview(event, review, _rating);

                    // Tutup bottom sheet
                    Navigator.pop(context);

                    // Tampilkan konfirmasi
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Ulasan berhasil disimpan'),
                        backgroundColor: UIColor.primaryColor,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: UIColor.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Kirim Ulasan',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: UIColor.solidWhite),
                  ),
                ),
              ),

              // Tambahkan padding bottom
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ),
    );
  }

// Fungsi untuk menyimpan review (sesuaikan dengan kebutuhan)
  Future<void> _saveReview(
      Registration event, String review, int rating) async {
    try {
      debugPrint('Menyimpan review untuk event: ${event.title}');
      debugPrint('Rating: $rating');
      debugPrint('Isi review: $review');

      // Implementasi penyimpanan review
      // Contoh:
      // final response = await ApiService.saveReview(
      //   eventId: event.eventId,
      //   review: review,
      //   rating: rating
      // );
    } catch (e) {
      debugPrint('Gagal menyimpan review: $e');

      // Optional: Tampilkan pesan error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan review: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  bool get wantKeepAlive => true;
}
