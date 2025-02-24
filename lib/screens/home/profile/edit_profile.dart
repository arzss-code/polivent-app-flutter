import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:polivent_app/config/app_config.dart';
import 'package:polivent_app/config/ui_colors.dart';
import 'package:polivent_app/services/auth_services.dart';
import 'package:polivent_app/services/data/category_model.dart';
import 'package:polivent_app/services/data/user_model.dart';
import 'package:polivent_app/services/user_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  User? _currentUser;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = true;
  List<Category> _categories = [];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();

  // List minat yang dipilih
  List<String> _selectedInterests = [];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _loadSavedInterests();
    // Panggil fetch categories
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final response = await http.get(
        Uri.parse(
            '$prodApiBaseUrl/categories'), // Pastikan prodApiBaseUrl sudah didefinisikan
        headers: {
          'Content-Type': 'application/json',
          // Tambahkan authorization header jika diperlukan
          // 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        List<dynamic> data = jsonResponse['data'];

        setState(() {
          // // Tambahkan opsi "Semua" jika diinginkan
          // _categories = [Category(categoryId: null, categoryName: 'Semua')];

          // Tambahkan kategori dari API
          _categories.addAll(
              data.map((category) => Category.fromJson(category)).toList());
          _isLoading = false;
        });
      } else {
        // Tangani kesalahan respons
        _handleError('Gagal memuat kategori');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      // Tangani kesalahan koneksi atau parsing
      _handleError(e.toString());
      setState(() {
        _isLoading = false;
      });
    }
  }

// Tambahkan metode _handleError jika belum ada
  void _handleError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _loadSavedInterests() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedInterests = prefs.getStringList('user_interests') ?? [];
    });
  }

  Future<void> _saveInterests() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('user_interests', _selectedInterests);
  }

  Future<void> _fetchUserData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final userData = await _authService.getUserData();

      setState(() {
        _currentUser = userData;
        _nameController.text = userData.username ?? '';
        _aboutController.text = userData.about ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user data: $e')),
      );
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });

      try {
        await _userService.updateUserAvatar(_profileImage!);
        await _fetchUserData();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating avatar: $e')),
        );
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String username = _nameController.text.trim();
      String about = _aboutController.text.trim();
      File? avatarFile = _profileImage;

      await _userService.updateUserProfile(
          username: username, about: about, avatarFile: avatarFile);

      // Simpan dan update interests
      await _saveInterests();
      await _userService.updateUserInterests(_selectedInterests);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 10),
              Text('Profil berhasil diperbarui'),
            ],
          ),
          backgroundColor: Colors.black87,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      await _fetchUserData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 10),
              Expanded(
                  child: Text(
                      'Terjadi kesalahan saat memperbarui profil. Silakan coba lagi.')),
            ],
          ),
          backgroundColor: Colors.black87,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showInterestsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) {
              return Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Pilih Minat Anda',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final isSelected =
                            _selectedInterests.contains(category.categoryName);

                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              setState(() {
                                // Skip "Semua" category
                                if (category.categoryId != null) {
                                  if (isSelected) {
                                    _selectedInterests
                                        .remove(category.categoryName);
                                  } else {
                                    _selectedInterests
                                        .add(category.categoryName);
                                  }
                                }
                              });
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? UIColor.primaryColor
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                category.categoryName,
                                style: TextStyle(
                                  color:
                                      isSelected ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: UIColor.primaryColor,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Simpan',
                            style: TextStyle(
                                color: UIColor.solidWhite,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIColor.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              size: 24, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profil',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _updateProfile,
            child: Text(
              'Simpan',
              style: TextStyle(
                color: _isLoading ? Colors.grey : UIColor.primaryColor,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildProfileEditForm(),
    );
  }

  Widget _buildProfileEditForm() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.transparent,
                    child: ClipOval(
                      child: _profileImage != null
                          ? Image.file(
                              _profileImage!,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            )
                          : _currentUser?.avatar != null
                              ? CachedNetworkImage(
                                  imageUrl: _currentUser!.avatar!,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) =>
                                      Image.asset(
                                    "assets/images/default-avatar.jpg",
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Image.asset(
                                  "assets/images/default-avatar.jpg",
                                  width: 120,
                                  height: 120,
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
            _buildEditableField(
              title: 'Nama',
              controller: _nameController,
              hintText: 'Masukkan nama Anda',
            ),

            // About Me
            _buildEditableField(
              title: 'Tentang Saya',
              controller: _aboutController,
              hintText: 'Deskripsikan diri Anda',
              maxLines: 5,
            ),

            // Interests
            const Text(
              'Minat',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Modifikasi bagian build interests di _buildProfileEditForm()
            Wrap(
              spacing: 8.0,
              children: _selectedInterests.map((interest) {
                return Chip(
                  label: Text(interest),
                  backgroundColor: UIColor.primaryColor,
                  labelStyle: const TextStyle(color: Colors.white),
                  onDeleted: () {
                    setState(() {
                      _selectedInterests.remove(interest);
                    });
                  },
                  deleteIcon:
                      const Icon(Icons.close, color: Colors.white, size: 18),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: UIColor.primaryColor,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: _showInterestsBottomSheet,
              child: const Text(
                'Pilih Minat',
                style: TextStyle(
                    color: UIColor.solidWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField({
    required String title,
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: UIColor.primaryColor),
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
