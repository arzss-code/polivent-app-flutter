import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  String name = 'Atsila Arya';
  String aboutMe = 'I am a student with a strong interest in mobile app development, UI/UX design, and gaming. I also enjoy competing in the fields of technology and design, constantly striving to improve my skills.';
  List<String> interests = ['Music', 'Workshop', 'Art', 'Sport', 'Food', 'Seminar', 'E-Sport'];
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  void _editName() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController nameController = TextEditingController(text: name);
        return AlertDialog(
          title: const Text("Edit Name"),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: "Enter your name"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  name = nameController.text;
                });
                Navigator.of(context).pop();
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _editAboutMe() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController aboutController = TextEditingController(text: aboutMe);
        return AlertDialog(
          title: const Text("Edit About Me"),
          content: TextField(
            controller: aboutController,
            decoration: const InputDecoration(labelText: "Enter about me"),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  aboutMe = aboutController.text;
                });
                Navigator.of(context).pop();
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _editInterests() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController interestsController = TextEditingController(text: interests.join(", "));
        return AlertDialog(
          title: const Text("Edit Interests"),
          content: TextField(
            controller: interestsController,
            decoration: const InputDecoration(labelText: "Enter interests (comma separated)"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  interests = interestsController.text.split(", ").map((e) => e.trim()).toList();
                });
                Navigator.of(context).pop();
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey[300]!, width: 2),
                        image: DecorationImage(
                          image: _profileImage != null
                              ? FileImage(_profileImage!)
                              : const NetworkImage('https://placeholder.com/150') as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.black,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Name
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.black),
                    onPressed: _editName,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // About Me
              Row(
                children: [
                  const Text(
                    'About Me',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.black),
                    onPressed: _editAboutMe,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                aboutMe,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),

              // Interests
              Row(
                children: [
                  const Text(
                    'Interests',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.black),
                    onPressed: _editInterests,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: interests
                    .map((interest) => Chip(
                          label: Text(
                            interest,
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
