import 'package:flutter/material.dart';
import 'package:polivent_app/screens/home/profile/settings_screen.dart';
import 'package:polivent_app/models/ui_colors.dart';
import 'package:polivent_app/services/data/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uicons_pro/uicons_pro.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:developer' as developer;

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

  @override
  void initState() {
    super.initState();
    _fetchUserData();
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchUserData,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    return _buildProfileContent();
  }

  AppBar _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: true,
      backgroundColor: UIColor.solidWhite,
      title: const Text(
        "Profile Saya",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: UIColor.typoBlack,
        ),
      ),
      actions: [
        IconButton(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          icon: Icon(
            UIconsPro.regularRounded.settings,
            size: 20,
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
          const SizedBox(height: 20),
          _buildProfileImage(),
          const SizedBox(height: 16),
          _buildProfileName(),
          const SizedBox(height: 50),
          _buildAboutMe(),
          const SizedBox(height: 24),
          _buildInterests(),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    return CircleAvatar(
      radius: 60,
      backgroundColor: Colors.transparent,
      child: ClipOval(
        child: _currentUser?.avatar != null
            ? CachedNetworkImage(
                imageUrl: _currentUser!.avatar,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) {
                  developer.log(
                    'Image load error',
                    name: 'HomeProfile',
                    error: error,
                    level: 2, // Error level
                  );
                  return Image.asset(
                    "assets/images/default-avatar.jpg",
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  );
                },
              )
            : Image.asset(
                "assets/images/default-avatar.jpg",
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
      ),
    );
  }

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
            'About Me',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _currentUser?.about ?? 'Tambahkan About Me',
            style: const TextStyle(fontSize: 16, color: UIColor.typoGray),
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
                'Interests',
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
                      'Tambahkan Interest',
                      style: TextStyle(fontSize: 16, color: UIColor.typoGray),
                    ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInterestChip(String label) {
    return Chip(
      label: Text(label,
          style: const TextStyle(color: Colors.white, fontSize: 12)),
      backgroundColor: Colors.blue,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    );
  }
}
