import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:polivent_app/config/app_config.dart';
import 'dart:convert';
import 'package:polivent_app/config/ui_colors.dart';
import 'package:polivent_app/models/search_event_result.dart';
import 'package:polivent_app/services/data/category_model.dart';
import 'package:shimmer/shimmer.dart';

class QuickCategorySection extends StatefulWidget {
  const QuickCategorySection({Key? key}) : super(key: key);

  @override
  _QuickCategorySectionState createState() => _QuickCategorySectionState();
}

class _QuickCategorySectionState extends State<QuickCategorySection> {
  int? _selectedIndex;
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
          categories = [Category(categoryId: null, categoryName: 'Semua')];
          categories.addAll(
              data.map((category) => Category.fromJson(category)).toList());
          _isLoading = false;
        });
      } else {
        _handleError('Failed to load categories');
      }
    } catch (e) {
      _handleError(e.toString());
    }
  }

  void _handleError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: 35,
          child: _isLoading
              ? _buildShimmerLoading()
              : _buildCategoryList(constraints),
        );
      },
    );
  }

  Widget _buildCategoryList(BoxConstraints constraints) {
    return ListView.separated(
      itemCount: categories.length,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      separatorBuilder: (context, index) => const SizedBox(width: 10),
      itemBuilder: (context, index) {
        return _buildCategoryChip(index, constraints);
      },
    );
  }

  Widget _buildCategoryChip(int index, BoxConstraints constraints) {
    bool isSelected = _selectedIndex == index;
    String categoryName = categories[index].categoryName;

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: 80,
        maxWidth: constraints.maxWidth * 0.25,
      ),
      child: GestureDetector(
        onTap: () => _onCategoryTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? UIColor.primaryColor : UIColor.solidWhite,
            border: Border.all(color: UIColor.primaryColor),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: Text(
              categoryName,
              style: TextStyle(
                color: isSelected ? UIColor.solidWhite : UIColor.primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  void _onCategoryTap(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchEventsResultScreen(
          searchQuery: '',
          category: categories[index].categoryName != 'Semua'
              ? categories[index].categoryName
              : null,
        ),
      ),
    );

    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildShimmerLoading() {
    return ListView.separated(
      itemCount: 6,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
