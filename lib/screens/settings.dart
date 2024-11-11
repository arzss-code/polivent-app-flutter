// Suggested code may be subject to a license. Learn more: ~LicenseLog:3100013983.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:polivent_app/config/app_config.dart';
import 'package:polivent_app/screens/edit_profile.dart';
import 'package:polivent_app/models/ui_colors.dart';
import 'package:polivent_app/screens/help.dart';
import 'package:polivent_app/screens/login.dart';
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
  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationPreference();
  }

  void _loadNotificationPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? false;
    });
  }

  void _toggleNotifications(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = value;
      prefs.setBool('notificationsEnabled', value);
    });
  }

  void _signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Membersihkan semua data yang tersimpan
    Navigator.pushReplacementNamed(
        context, '/login'); // Mengarahkan ke layar login
  }

  Future<void> logout() async {
    try {
      final token = await getToken();
      if (token == null) {
        print('Token tidak ditemukan');
        // Hapus token dari storage untuk berjaga-jaga
        await deleteToken();
        return;
      }

      final response = await http.delete(
        Uri.parse('$devApiBaseUrl/auth'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      // Untuk 401 atau 200, kita tetap hapus token lokal
      if (response.statusCode == 401 || response.statusCode == 200) {
        await deleteToken();
        print('Logout berhasil');
        // Di sini bisa tambah navigasi ke halaman login jika perlu
      } else {
        print('Logout gagal: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      // Optional: tetap hapus token jika terjadi error
      await deleteToken();
    }
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
            Icons.arrow_back_ios_new,
            size: 20,
          ),
        ),
        automaticallyImplyLeading: false, // remove leading(left) back icon
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
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                    builder: (context) => const EditProfileScreen(),
                  ),
                );
              }),
          const SizedBox(height: 20.0),
          _buildSectionTitle(title: 'Preferences'),
          SwitchListTile(
            title: const Text('Enable Notifications'),
            value: _notificationsEnabled,
            onChanged: _toggleNotifications,
            secondary: const Icon(
              Icons.notifications_on_rounded,
              color: UIColor.primaryColor,
            ),
            tileColor: UIColor.solidWhite,
            activeColor: UIColor.primaryColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          _buildListTile(
            leadingIcon: Icons.help,
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
          const SizedBox(height: 20.0),
          _buildListTile(
            leadingIcon: Icons.logout,
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
    Size? iconSize,
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
        size: iconSize?.width ?? 24.0,
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
              size: iconSize?.width ?? 16.0,
            )
          : null,
      onTap: onTap,
    );
  }
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
                    // padding: const EdgeInsets.symmetric(
                    //     horizontal: 50, vertical: 20),
                    backgroundColor: Colors
                        .grey[200], // Set Cancel button background to grey 200
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: UIColor.primaryColor),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Tambahkan logika logout di sini, misalnya:
                    // FirebaseAuth.instance.signOut();
                    _SettingsScreenState().logout();

                    // Setelah logout, arahkan pengguna ke halaman login
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                        (Route<dynamic> route) => false);
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
