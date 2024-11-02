// Suggested code may be subject to a license. Learn more: ~LicenseLog:3100013983.
import 'package:flutter/material.dart';
import 'package:polivent_app/screens/edit_profile.dart';
import 'package:polivent_app/models/ui_colors.dart';
import 'package:polivent_app/screens/help.dart';
import 'package:polivent_app/screens/login.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
              leadingIcon: Icons.person,
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
          _buildListTile(
            leadingIcon: Icons.notifications,
            title: 'Notifications',
            trailingIcon: Icons.arrow_forward_ios,
            onTap: () {},
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
        color: leadingIconColor ?? Colors.grey,
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
