import 'package:flutter/material.dart';
import 'package:polivent_app/screens/settings.dart';
import 'package:polivent_app/models/ui_colors.dart';
import 'package:polivent_app/services/data/user_model.dart';
import 'package:uicons_pro/uicons_pro.dart';
import 'package:cached_network_image/cached_network_image.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final authService = AuthService();
      final userData = await authService.getUserData();

      setState(() {
        _currentUser = userData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
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
    return Column(
      children: [
        _buildAppBar(),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage.isNotEmpty
                  ? Center(child: Text('Error: $_errorMessage'))
                  : _buildProfileContent(),
        ),
      ],
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: true,
      backgroundColor: UIColor.solidWhite,
      title: const Text(
        "My Profile",
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
      return const Center(child: Text('No user data available'));
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
          // Tambahkan bagian interests jika diperlukan
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    return CircleAvatar(
      radius: 60,
      backgroundColor: Colors.grey[300],
      backgroundImage: _currentUser?.avatar != null
          ? CachedNetworkImageProvider(_currentUser!.avatar)
          : const AssetImage("assets/images/150.png") as ImageProvider,
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

  // Tambahkan method baru untuk _buildInterests()
  Widget _buildInterests() {
    // Contoh list interests, sesuaikan dengan struktur data di User model
    List<String> interests = [
      'Music',
      'Workshop',
      'Art',
      'Sport',
      'Food',
      'Seminar',
      'E-Sport'
    ];

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
  }

// Tambahkan method untuk membuat interest chip
  Widget _buildInterestChip(String label) {
    return Chip(
      label: Text(label,
          style: const TextStyle(color: Colors.white, fontSize: 12)),
      backgroundColor: Colors.blue,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    );
  }
}
