import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:polivent_app/models/ui_colors.dart';
import 'package:polivent_app/services/data/category_model.dart';
import 'package:shimmer/shimmer.dart';

class QuickCategorySection extends StatefulWidget {
  const QuickCategorySection({super.key});

  @override
  _QuickCategorySectionState createState() => _QuickCategorySectionState();
}

class _QuickCategorySectionState extends State<QuickCategorySection> {
  int _selectedIndex = 0; // Untuk melacak kategori yang dipilih
  List<Category> categories = []; // Daftar kategori yang akan diisi
  bool _isLoading = true; // Menandakan apakah data sedang dimuat

  @override
  void initState() {
    super.initState();
    fetchCategories(); // Memanggil fungsi untuk mengambil kategori
  }

  Future<void> fetchCategories() async {
    try {
      final response =
          await http.get(Uri.parse('https://polivent.my.id/api/categories'));

      if (response.statusCode == 200) {
        // Jika server mengembalikan respons OK, parse data
        final jsonResponse = json.decode(response.body);
        List<dynamic> data = jsonResponse['data']; // Mengakses data kategori

        setState(() {
          categories =
              data.map((category) => Category.fromJson(category)).toList();
          _isLoading = false; // Set loading menjadi false setelah data diambil
        });
      } else {
        // Jika server tidak mengembalikan respons OK
        print('Error: ${response.statusCode}'); // Menampilkan status code error
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      // Menangani kesalahan jaringan atau parsing
      print('Error fetching categories: $e');
      setState(() {
        _isLoading = false; // Set loading menjadi false jika terjadi kesalahan
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: _isLoading // Menampilkan shimmer jika data sedang diambil
          ? _buildShimmerLoading()
          : ListView.separated(
              itemCount: categories.length,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 20, right: 20),
              separatorBuilder: (context, index) => const SizedBox(
                width: 10,
              ),
              itemBuilder: (context, index) {
                bool isSelected = _selectedIndex == index;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  child: Container(
                    width: 90,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? UIColor.primaryColor
                          : UIColor.solidWhite,
                      border: Border.all(
                        color: isSelected
                            ? UIColor.primaryColor
                            : UIColor.primaryColor,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      categories[index]
                          .categoryName, // Menggunakan categoryName dari model Category
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected
                            ? UIColor.solidWhite
                            : UIColor.primaryColor,
                        height: 2.5,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.separated(
      itemCount: 8, // Jumlah item shimmer yang ingin ditampilkan
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: 20, right: 20),
      separatorBuilder: (context, index) => const SizedBox(width: 10),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: 90,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        );
      },
    );
  }
}
