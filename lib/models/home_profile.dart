import 'package:flutter/material.dart';
import 'package:polivent_app/screens/settings.dart'; // Pastikan untuk mengimpor SettingsScreen
import 'package:shared_preferences/shared_preferences.dart';
import 'package:polivent_app/models/ui_colors.dart';
import 'package:uicons_pro/uicons_pro.dart';

class HomeProfile extends StatefulWidget {
  const HomeProfile({super.key});

  @override
  State<HomeProfile> createState() => _HomeProfileState();
}

class _HomeProfileState extends State<HomeProfile> {
  String name = 'Atsila Arya';
  String aboutMe =
      'I am a student with a strong interest in mobile app development, '
      'UI/UX design, and gaming. I also enjoy competing in the fields '
      'of technology and design, constantly striving to improve my skills.';
  List<String> interests = [
    'Music',
    'Workshop',
    'Art',
    'Sport',
    'Food',
    'Seminar',
    'E-Sport'
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? name;
      aboutMe = prefs.getString('about_me') ?? aboutMe;
      interests = prefs.getStringList('interests') ?? interests;
    });
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    ).then((_) {
      _loadData(); // Memuat data setelah kembali dari SettingsScreen
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildAppBar(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: _buildProfileContent(),
          ),
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
          onPressed: _navigateToSettings, // Navigasi ke SettingsScreen
        ),
      ],
    );
  }

  Column _buildProfileContent() {
    return Column(
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
    );
  }

  CircleAvatar _buildProfileImage() {
    return CircleAvatar(
      radius: 60,
      backgroundColor: Colors.grey[300],
      backgroundImage: const AssetImage("assets/images/150.png"),
    );
  }

  Row _buildProfileName() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          name.isNotEmpty ? name : 'Tambahkan Nama',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Align _buildAboutMe() {
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
            aboutMe.isNotEmpty ? aboutMe : 'Tambahkan About Me',
            style: const TextStyle(fontSize: 16, color: UIColor.typoGray),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }

  Align _buildInterests() {
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
                      .map((interest) => InterestChip(label: interest))
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
}

class InterestChip extends StatelessWidget {
  final String label;

  const InterestChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label, style: const TextStyle(color: Colors.white)),
      backgroundColor: Colors.blue,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    );
  }
}
