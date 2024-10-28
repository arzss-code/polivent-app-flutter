import 'package:flutter/material.dart';
import 'package:polivent_app/screens/edit_profile.dart';

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
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: const Text('Settings'),
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
            }
          ),
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
            onTap: () {},
          ),
          const SizedBox(height: 20.0),
          _buildListTile(
            leadingIcon: Icons.logout,
            title: 'Sign Out',
            trailingIcon: null,
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return LogoutDialog();
                },
              );
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
  }) {
    return ListTile(
      leading: Icon(
        leadingIcon,
        color: leadingIconColor ?? Colors.grey,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? Colors.black,
        ),
      ),
      trailing: trailingIcon != null ? Icon(trailingIcon) : null,
      onTap: onTap,
    );
  }
}

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sign out', style: TextStyle(color: Colors.red)),
      content: const Text(
        'Are you sure you want to sign out?\n'
        'You can always sign back to explore more\n'
        'events and stay updated!',
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            // Add your logout logic here
            Navigator.of(context).pop(); // Close the dialog
          },
          child:
              const Text('Yes, Sign out', style: TextStyle(color: Colors.blue)),
        ),
      ],
    );
  }
}
