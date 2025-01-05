import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:polivent_app/config/app_config.dart';
import 'package:polivent_app/models/common_widget.dart';
import 'package:polivent_app/screens/home/event/detail_events.dart';
import 'package:polivent_app/screens/home/profile/settings_screen.dart';
import 'package:polivent_app/config/ui_colors.dart';
import 'package:polivent_app/services/data/user_model.dart';
import 'package:polivent_app/services/token_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uicons_pro/uicons_pro.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;

// Import User model dan AuthService
import 'package:polivent_app/services/auth_services.dart';

class HomeProfile extends StatefulWidget {
  const HomeProfile({super.key});

  @override
  State<HomeProfile> createState() => _HomeProfileState();
}

class _HomeProfileState extends State<HomeProfile> {
  User? _currentUser;
  bool _isLoading = true;
  String _errorMessage = '';
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  // Variabel untuk menyimpan jumlah event
  int _eventCount = 0;
  Map<String, dynamic>? _lastRegisteredEvent;
  // bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchRegisteredEvents();
  }

  Future<void> _fetchUserData() async {
    developer.log(
      'Fetching user data...',
      name: 'HomeProfile',
      level: 0, // Info level
    );

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final authService = AuthService();
      final userData = await authService.getUserData();

      developer.log(
        'User data fetched successfully',
        name: 'HomeProfile',
        level: 0, // Info level
      );

      setState(() {
        _currentUser = userData;
        _isLoading = false;
      });
    } catch (e) {
      developer.log(
        'Error fetching user data',
        name: 'HomeProfile',
        error: e,
        level: 2, // Error level
      );

      setState(() {
        _errorMessage = 'Gagal memuat data. Silakan coba lagi.';
        _isLoading = false;
      });
    }
  }

  Future<void> _handleRefresh() async {
    developer.log(
      'Refreshing profile data...',
      name: 'HomeProfile',
      level: 0, // Info level
    );
    await _fetchUserData();
  }

  Future<List<String>> _getCurrentUserInterests() async {
    try {
      // Prioritaskan interests dari model User
      if (_currentUser?.interests != null &&
          _currentUser!.interests!.isNotEmpty) {
        developer.log(
          'Returning interests from user model',
          name: 'HomeProfile',
          level: 0, // Info level
        );
        return _currentUser!.interests!;
      }

      // Jika tidak ada, coba ambil dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      List<String>? interests = prefs.getStringList('user_interests');

      developer.log(
        'Returning interests from SharedPreferences: $interests',
        name: 'HomeProfile',
        level: 0, // Info level
      );
      return interests ?? [];
    } catch (e) {
      developer.log(
        'Error retrieving interests',
        name: 'HomeProfile',
        error: e,
        level: 2, // Error level
      );
      return [];
    }
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    ).then((_) {
      _fetchUserData(); // Memuat ulang data setelah kembali dari SettingsScreen
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: UIColor.primaryColor,
      backgroundColor: UIColor.solidWhite,
      key: _refreshIndicatorKey,
      onRefresh: _handleRefresh,
      child: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return CommonWidgets.buildErrorWidget(
        context: context,
        errorMessage: _errorMessage,
        onRetry: () {
          _fetchUserData();
          _fetchRegisteredEvents();
        },
      );
    }

    if (_currentUser == null) {
      return const Center(
        child: Text(
          'Sesi Anda telah berakhir. Silakan login ulang.',
          textAlign: TextAlign.center,
        ),
      );
    }

    return _buildProfileContent();
  }

  AppBar _buildAppBar() {
    return AppBar(
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: true,
      backgroundColor: UIColor.solidWhite,
      title: const Text(
        "Profil Saya",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: UIColor.typoBlack,
        ),
      ),
      actions: [
        IconButton(
          padding: const EdgeInsets.only(right: 20),
          icon: Icon(
            UIconsPro.regularRounded.settings,
            size: 24,
          ),
          onPressed: _navigateToSettings,
        ),
      ],
    );
  }

  Widget _buildProfileContent() {
    if (_currentUser == null) {
      return const Center(
        child: Text(
          'Data user tidak ditemukan, silahkan login ulang dan coba kembali.',
          textAlign: TextAlign.center,
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 30),
          // _buildProfileStats(),
          // const SizedBox(height: 30),
          _buildAboutMe(),
          const SizedBox(height: 24),
          _buildInterests(),
          const SizedBox(height: 24),
          _buildLastRegisteredEventCard(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildProfileImage(),
          const SizedBox(height: 16),
          _buildProfileName(),
          const SizedBox(height: 8),
          Text(
            _currentUser?.email ?? 'Email tidak tersedia',
            style: const TextStyle(
              color: UIColor.typoGray,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk memformat waktu registrasi
  String _formatRegistrationTime(String registrationTime) {
    try {
      DateTime parsedTime = DateTime.parse(registrationTime);
      return DateFormat('dd MMMM yyyy HH:mm').format(parsedTime);
    } catch (e) {
      return registrationTime;
    }
  }

  Future<void> _fetchRegisteredEvents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Mendapatkan token otorisasi
      final String? token = await TokenService.getAccessToken();

      if (token == null) {
        debugPrint('Token tidak tersedia');
        return;
      }

      // Header untuk autentikasi
      final Map<String, String> headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      // URL untuk mengambil data registrasi event
      const String registrationUrl = '$prodApiBaseUrl/registration?user_id=10';

      // Melakukan request untuk event yang diikuti
      final registrationResponse = await http.get(
        Uri.parse(registrationUrl),
        headers: headers,
      );

      // Memeriksa status kode respons
      if (registrationResponse.statusCode == 200) {
        // Parse JSON
        final Map<String, dynamic> responseData =
            json.decode(registrationResponse.body);

        // Pastikan data adalah list
        final List<dynamic> events = responseData['data'] ?? [];

        // Hitung jumlah event yang sudah didaftarkan
        final int eventCount = events.length;

        // Temukan event terakhir yang didaftarkan berdasarkan registration_time
        Map<String, dynamic>? lastEvent;
        if (events.isNotEmpty) {
          lastEvent = events.reduce((current, next) {
            DateTime currentTime = DateTime.parse(current['registration_time']);
            DateTime nextTime = DateTime.parse(next['registration_time']);
            return currentTime.isAfter(nextTime) ? current : next;
          });
        }

        // Update state dengan jumlah event dan event terakhir
        setState(() {
          _eventCount = eventCount;
          _lastRegisteredEvent = lastEvent;
          _isLoading = false;
        });
      } else {
        // Handle error
        debugPrint('Gagal mengambil event yang diikuti');
        debugPrint('Status Code: ${registrationResponse.statusCode}');

        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      // Tangani error jaringan atau parsing
      debugPrint('Error saat mengambil event: $e');

      setState(() {
        _isLoading = false;
      });

      // Tampilkan pesan error kepada pengguna
      _showErrorSnackBar('Tidak dapat memuat event');
    }
  }

  // Method untuk menampilkan error snackbar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Widget untuk menampilkan event terakhir
  Widget _buildLastRegisteredEventCard() {
    if (_lastRegisteredEvent == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Event Terakhir yang Diikuti',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            // Navigasi ke halaman detail event
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailEvents(
                  eventId: _lastRegisteredEvent!['event_id'],
                ),
              ),
            );
          },
          child: Card(
            color: Colors.white,
            elevation: 5,
            shadowColor: Colors.grey.withOpacity(0.2),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Poster Event
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(8)),
                  child: Image.network(
                    _lastRegisteredEvent!['poster'],
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 200,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported),
                      );
                    },
                  ),
                ),

                // Informasi Event
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _lastRegisteredEvent!['title'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(UIconsPro.regularRounded.calendar,
                              size: 16, color: UIColor.primaryColor),
                          const SizedBox(width: 8),
                          Text(
                            'Didaftarkan: ${_formatRegistrationTime(_lastRegisteredEvent!['registration_time'])}',
                            style: const TextStyle(color: UIColor.typoGray),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(UIconsPro.regularRounded.category,
                              size: 16, color: UIColor.primaryColor),
                          const SizedBox(width: 8),
                          Text(
                            _lastRegisteredEvent!['category_name'],
                            style: const TextStyle(color: UIColor.typoGray),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

// Modifikasi widget untuk menggunakan variabel dinamis
  Widget _buildProfileStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Gunakan loading indicator jika sedang memuat
        _isLoading
            ? const CircularProgressIndicator()
            : _buildStatItem('Events Diikuti', '$_eventCount'),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: UIColor.primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: UIColor.typoGray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: UIColor.primaryColor.withOpacity(0.3),
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 60,
            backgroundColor: Colors.white,
            child: ClipOval(
              child: _currentUser?.avatar != null
                  ? CachedNetworkImage(
                      imageUrl: _currentUser!.avatar,
                      width: 110,
                      height: 110,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) {
                        return Image.asset(
                          "assets/images/default-avatar.jpg",
                          width: 110,
                          height: 110,
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  : Image.asset(
                      "assets/images/default-avatar.jpg",
                      width: 110,
                      height: 110,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInterestChip(String label) {
    return Container(
      decoration: BoxDecoration(
        color: UIColor.primaryColor,
        // gradient: LinearGradient(
        //   colors: [
        //     UIColor.primaryColor.withOpacity(0.7),
        //     UIColor.primaryColor,
        //   ],
        //   begin: Alignment.topLeft,
        //   end: Alignment.bottomRight,
        // ),
        borderRadius: BorderRadius.circular(20),
        // boxShadow: [
        //   BoxShadow(
        //     color: UIColor.primaryColor.withOpacity(0.3),
        //     spreadRadius: 1,
        //     blurRadius: 5,
        //     offset: const Offset(0, 2),
        //   ),
        // ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      margin: const EdgeInsets.only(right: 4, bottom: 4),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Widget _buildProfileContent() {
  //   if (_currentUser == null) {
  //     return const Center(
  //       child: Text(
  //         'Data user tidak ditemukan, silahkan login ulang dan coba kembali.',
  //         textAlign: TextAlign.center,
  //       ),
  //     );
  //   }

  //   return SingleChildScrollView(
  //     padding: const EdgeInsets.all(20.0),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       children: [
  //         const SizedBox(height: 20),
  //         _buildProfileImage(),
  //         const SizedBox(height: 16),
  //         _buildProfileName(),
  //         const SizedBox(height: 50),
  //         _buildAboutMe(),
  //         const SizedBox(height: 24),
  //         _buildInterests(),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildProfileImage() {
  //   return CircleAvatar(
  //     radius: 60,
  //     backgroundColor: Colors.transparent,
  //     child: ClipOval(
  //       child: _currentUser?.avatar != null
  //           ? CachedNetworkImage(
  //               imageUrl: _currentUser!.avatar,
  //               width: 120,
  //               height: 120,
  //               fit: BoxFit.cover,
  //               errorWidget: (context, url, error) {
  //                 developer.log(
  //                   'Image load error',
  //                   name: 'HomeProfile',
  //                   error: error,
  //                   level: 2, // Error level
  //                 );
  //                 return Image.asset(
  //                   "assets/images/default-avatar.jpg",
  //                   width: 120,
  //                   height: 120,
  //                   fit: BoxFit.cover,
  //                 );
  //               },
  //             )
  //           : Image.asset(
  //               "assets/images/default-avatar.jpg",
  //               width: 120,
  //               height: 120,
  //               fit: BoxFit.cover,
  //             ),
  //     ),
  //   );
  // }

  Widget _buildProfileName() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _currentUser?.username ?? 'Nama Pengguna',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildAboutMe() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tentang Saya',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _currentUser?.about ??
                'Ceritakan sedikit tentang dirimu...\nBagikan minat, passion, atau pencapaianmu!',
            style: TextStyle(
              fontSize: 16,
              color: UIColor.typoGray,
              fontStyle: _currentUser?.about == null
                  ? FontStyle.italic
                  : FontStyle.normal,
            ),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }

  Widget _buildInterests() {
    return FutureBuilder<List<String>>(
      future: _getCurrentUserInterests(),
      builder: (context, snapshot) {
        List<String> interests = snapshot.data ?? [];

        return Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Minat',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              interests.isNotEmpty
                  ? Wrap(
                      spacing: 12.0,
                      runSpacing: 8.0,
                      children: interests
                          .map((interest) => _buildInterestChip(interest))
                          .toList(),
                    )
                  : const Text(
                      'Tambahkan minat kamu...',
                      style: TextStyle(
                          fontSize: 16,
                          color: UIColor.typoGray,
                          fontStyle: FontStyle.italic),
                    ),
            ],
          ),
        );
      },
    );
  }

  // Widget _buildInterestChip(String label) {
  //   return Chip(
  //     label: Text(label,
  //         style: const TextStyle(color: Colors.white, fontSize: 12)),
  //     backgroundColor: Colors.blue,
  //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
  //   );
  // }
}
