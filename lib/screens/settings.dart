import 'package:flutter/material.dart';
import 'package:polivent_app/config/app_config.dart';
import 'package:polivent_app/screens/edit_profile.dart';
import 'package:polivent_app/models/ui_colors.dart';
import 'package:polivent_app/screens/help.dart';
import 'package:polivent_app/screens/login.dart';
import 'package:polivent_app/services/api_services.dart';
import 'package:polivent_app/services/auth_services.dart';
import 'package:polivent_app/services/token_util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uicons_pro/uicons_pro.dart';
import 'package:http/http.dart' as http;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Buat instance AuthService
  final AuthService _authService = AuthService();
  bool _notificationsEnabled = true;
  String name = 'Atsila Arya';
  String aboutMe =
      'I am a student with a strong interest in mobile app development, UI/UX design, and gaming.';
  List<String> interests = [];

  @override
  void initState() {
    super.initState();
    _loadNotificationPreference();
    _loadProfileData();
    // _authService = AuthService();
  }

  void _loadNotificationPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    });
  }

  void _loadProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? name;
      aboutMe = prefs.getString('about_me') ?? aboutMe;
      interests = prefs.getStringList('interests') ?? [];
    });
  }

  void _toggleNotifications(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = value;
      prefs.setBool('notificationsEnabled', value);
    });
  }

  void showLogoutBottomSheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: UIColor.solidWhite,
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Sign out',
                style: TextStyle(color: Colors.red, fontSize: 24),
              ),
              Divider(
                height: 48,
                color: Colors.grey[300],
                thickness: 1,
                indent: 16,
                endIndent: 16,
              ),
              // const SizedBox(height: 16),
              const Text(
                'Are you sure you want to sign out?\n'
                'You can always sign back to explore more\n'
                'events and stay updated!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the bottom sheet
                    },
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(150, 50),
                      backgroundColor: Colors.grey[
                          200], // Set Cancel button background to grey 200
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: UIColor.primaryColor),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Panggil fungsi logout menggunakan instance
                      _authService.logout(context);
                    },
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(150, 50),
                      // padding: const EdgeInsets.symmetric(
                      //     horizontal: 50, vertical: 20),
                      backgroundColor: Colors
                          .blue, // Set Yes, Sign out button background to blue
                    ),
                    child: const Text(
                      'Yes, Sign out',
                      style: TextStyle(
                          color: Colors
                              .white), // You might want to change text color to white for better contrast
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
            size: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: UIColor.solidWhite,
        scrolledUnderElevation: 0,
        title: const Text(
          "Settings",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: UIColor.typoBlack,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        children: [
          const SizedBox(height: 20.0),
          _buildSectionTitle(title: 'Account Settings'),
          _buildListTile(
            leadingIcon: UIconsPro.solidRounded.user_pen,
            title: 'Edit Profile',
            trailingIcon: Icons.arrow_forward_ios,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const EditProfileScreen()),
              ).then((_) {
                _loadProfileData();
              });
            },
          ),
          const SizedBox(height: 20.0),
          _buildSectionTitle(title: 'Preferences'),
          SwitchListTile(
            title: const Text('Enable Notifications'),
            value: _notificationsEnabled,
            onChanged: _toggleNotifications,
            secondary: const Icon(
              Icons.notifications_active_rounded,
              color: UIColor.primaryColor,
              size: 24,
            ),
            tileColor: UIColor.solidWhite,
            activeColor: UIColor.primaryColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          const SizedBox(height: 10.0),
          _buildListTile(
            leadingIcon: UIconsPro.solidRounded.interrogation,
            title: 'Help',
            trailingIcon: Icons.arrow_forward_ios,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HelpScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 30.0),
          _buildListTile(
            leadingIcon: UIconsPro.solidRounded.sign_out_alt,
            title: 'Sign Out',
            trailingIcon: null,
            onTap: () {
              showLogoutBottomSheet(context);
            },
            titleColor: Colors.red,
            leadingIconColor: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle({required String title}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData leadingIcon,
    required String title,
    IconData? trailingIcon,
    required VoidCallback onTap,
    Color? titleColor,
    Color? leadingIconColor,
    Color? trailingIconColor,
    Size? leadingSize,
    Size? trailingSize,
  }) {
    return ListTile(
      // Buat background berwarna putih
      tileColor: UIColor.solidWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),

      leading: Icon(
        leadingIcon,
        color: leadingIconColor ?? UIColor.primaryColor,
        size: leadingSize?.width ?? 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? Colors.black,
        ),
      ),
      trailing: trailingIcon != null
          ? Icon(
              trailingIcon,
              color: trailingIconColor ?? Colors.grey,
              size: trailingSize?.width ?? 16.0,
            )
          : null,
      onTap: onTap,
    );
  }
}
