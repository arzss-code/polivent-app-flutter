import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:polivent_app/config/app_config.dart';
import 'dart:convert';
import 'package:polivent_app/models/ui_colors.dart';
import 'package:polivent_app/models/search_event_result.dart';
import 'package:polivent_app/services/data/events_model.dart'; // Pastikan Anda memiliki model Event
import 'package:polivent_app/services/data/category_model.dart';
import 'package:shimmer/shimmer.dart';

class QuickCategorySection extends StatefulWidget {
  const QuickCategorySection({super.key});

  @override
  _QuickCategorySectionState createState() => _QuickCategorySectionState();
}

class _QuickCategorySectionState extends State<QuickCategorySection> {
  int? _selectedIndex; // Bisa null untuk menampilkan semua event
  List<Category> categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('$prodApiBaseUrl/categories'));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        List<dynamic> data = jsonResponse['data'];

        setState(() {
          // Tambahkan kategori "Semua" di awal
          categories = [Category(categoryId: null, categoryName: 'Semua')];

          // Tambahkan kategori dari API
          categories.addAll(
              data.map((category) => Category.fromJson(category)).toList());

          _isLoading = false;
        });
      } else {
        debugPrint('Error: ${response.statusCode}');
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: _isLoading
          ? _buildShimmerLoading()
          : ListView.separated(
              itemCount: categories.length,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 20, right: 20),
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                bool isSelected = _selectedIndex == index;

                return GestureDetector(
                  onTap: () {
                    // Navigasi ke SearchEventsResultScreen dengan kategori
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchEventsResultScreen(
                          searchQuery: '', // Kosongkan query
                          category: categories[index].categoryName != 'Semua'
                              ? categories[index].categoryName
                              : null,
                        ),
                      ),
                    );

                    setState(() {
                      // Update selected index untuk visual feedback
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
                        color: UIColor.primaryColor,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      categories[index].categoryName,
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
      itemCount: 8,
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
