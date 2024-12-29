import 'package:flutter/material.dart';
import 'package:polivent_app/screens/auth/login_screen.dart';
import 'dart:developer' as developer;

import 'package:polivent_app/screens/home/profile/edit_profile.dart';
import 'package:polivent_app/models/ui_colors.dart';
import 'package:polivent_app/screens/home/profile/help.dart';
import 'package:polivent_app/services/auth_services.dart';
import 'package:polivent_app/services/token_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uicons_pro/uicons_pro.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  bool _notificationsEnabled = true;
  bool _isTokenValid = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationPreference();
    _checkTokenValidity();
  }

  Future<void> _checkTokenValidity() async {
    try {
      final isValid = await TokenService.checkTokenValidity();

      developer.log(
        'Token Validity: $isValid',
        name: 'SettingsScreen',
        level: 0, // Info level
      );

      if (!isValid) {
        setState(() {
          _isTokenValid = false;
        });

        // Tampilkan dialog token expired
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showTokenExpiredDialog();
        });
      }
    } catch (e) {
      developer.log(
        'Error checking token validity',
        name: 'SettingsScreen',
        error: e,
        level: 2, // Error level
      );

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Gagal memeriksa token: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  void _showTokenExpiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sesi Berakhir'),
          content:
              const Text('Sesi Anda telah berakhir. Silakan login kembali.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                // Logout dan arahkan ke halaman login
                _authService.logout(context);
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _loadNotificationPreference() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      });

      developer.log(
        'Notification preference loaded: $_notificationsEnabled',
        name: 'SettingsScreen',
        level: 0, // Info level
      );
    } catch (e) {
      developer.log(
        'Error loading notification preferences',
        name: 'SettingsScreen',
        error: e,
        level: 2, // Error level
      );

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Gagal memuat pengaturan notifikasi: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  void _toggleNotifications(bool value) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        _notificationsEnabled = value;
        prefs.setBool('notificationsEnabled', value);
      });

      developer.log(
        'Notifications toggled: $value',
        name: 'SettingsScreen',
        level: 0, // Info level
      );
    } catch (e) {
      developer.log(
        'Error toggling notifications',
        name: 'SettingsScreen',
        error: e,
        level: 2, // Error level
      );

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Gagal mengubah notifikasi: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  void _handleLogout() {
    showLogoutBottomSheet(context);
  }

  void showLogoutBottomSheet(BuildContext context) {
    try {
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
                  'Logout',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
                Divider(
                  height: 48,
                  color: Colors.grey[300],
                  thickness: 1,
                  indent: 16,
                  endIndent: 16,
                ),
                const Text(
                  'Apakah Anda yakin ingin keluar?\n'
                  'Anda selalu dapat masuk kembali untuk menjelajahi lebih banyak acara dan tetap terupdate!',
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
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size(150, 50),
                        backgroundColor: Colors.grey[200],
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(color: UIColor.primaryColor),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        developer.log(
                          'Logout initiated',
                          name: 'SettingsScreen',
                          level: 0, // Info level
                        );

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );

                        _authService.logout(context);
                      },
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size(150, 50),
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text(
                        'Ya, Keluar',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      developer.log(
        'Error showing logout bottom sheet',
        name: 'SettingsScreen',
        error: e,
        level: 2, // Error level
      );

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Gagal menampilkan logout: $e'),
        backgroundColor: Colors.red,
      ));
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
            Icons.arrow_back_rounded,
            size: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: UIColor.solidWhite,
        scrolledUnderElevation: 0,
        title: const Text(
          "Pengaturan",
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
          _buildSectionTitle(title: 'Pengaturan Akun'),
          _buildListTile(
            leadingIcon: UIconsPro.solidRounded.user_pen,
            title: 'Edit Profil',
            trailingIcon: Icons.arrow_forward_ios,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const EditProfileScreen()),
              ).then((_) {
                setState(() {});
              });
            },
          ),
          const SizedBox(height: 20.0),
          _buildSectionTitle(title: 'Preferensi'),
          SwitchListTile(
            title: const Text('Aktifkan Notifikasi'),
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
            title: 'Bantuan',
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
            title: 'Logout',
            trailingIcon: null,
            onTap: _handleLogout,
            titleColor: Colors.red,
            leadingIconColor: Colors.red,
          ),
          const SizedBox(height: 20.0),
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
