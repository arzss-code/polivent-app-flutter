import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:polivent_app/models/ui_colors.dart';
import 'package:polivent_app/config/app_config.dart';
import 'package:polivent_app/services/token_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EventFilter {
  String category;
  DateTime? date;

  EventFilter({
    this.category = '',
    this.date,
  });

  void resetFilter() {
    category = '';
    date = null;
  }

  bool isEmpty() {
    return category.isEmpty && date == null;
  }

  static Future<EventFilter?> showFilterBottomSheet(BuildContext context) {
    return showModalBottomSheet<EventFilter>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return _FilterBottomSheetContent();
      },
    );
  }
}

class _FilterBottomSheetContent extends StatefulWidget {
  @override
  _FilterBottomSheetContentState createState() =>
      _FilterBottomSheetContentState();
}

class _FilterBottomSheetContentState extends State<_FilterBottomSheetContent> {
  String _selectedCategory = '';
  DateTime? _selectedDate;
  List<String> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final accessToken = await TokenService.getAccessToken();
      final response = await http.get(
        Uri.parse('$prodApiBaseUrl/categories'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'success') {
          setState(() {
            _categories = List<String>.from(jsonResponse['data']
                .map((category) => category['category_name']));
            _isLoading = false;
          });
        } else {
          throw Exception(
              jsonResponse['message'] ?? 'Gagal mengambil kategori');
        }
      } else {
        throw Exception(
            'Gagal mengambil kategori. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching categories: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat kategori: $e')),
      );
    }
  }

  Future<String> _getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token') ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.5,
      maxChildSize: 0.7,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(25),
            ),
          ),
          child: Column(
            children: [
              // Drag indicator
              Container(
                width: 30,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: UIColor.typoBlack.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),

              // Title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Text(
                  'Filter Pencarian Event',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Scrollable content
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          // Category Filter
                          _buildFilterSection(
                            title: 'Kategori',
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _categories
                                  .map((category) =>
                                      _buildCategoryChip(category))
                                  .toList(),
                            ),
                          ),

                          // Date Filter
                          _buildFilterSection(
                            title: 'Tanggal',
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: UIColor.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              onPressed: _selectDate,
                              child: Text(
                                _selectedDate == null
                                    ? 'Pilih Tanggal'
                                    : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),

              // Apply Filter Button
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: UIColor.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: _applyFilter,
                    child: const Text(
                      'Terapkan Filter',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: UIColor.solidWhite,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterSection({
    required String title,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: UIColor.typoBlack,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    return ChoiceChip(
      label: Text(category),
      selected: _selectedCategory == category,
      backgroundColor: Colors.white,
      selectedColor: UIColor.primaryColor.withOpacity(0.2),
      labelStyle: TextStyle(
        color:
            _selectedCategory == category ? UIColor.primaryColor : Colors.black,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: _selectedCategory == category
              ? UIColor.primaryColor
              : Colors.grey.shade300,
        ),
      ),
      onSelected: (bool selected) {
        setState(() {
          _selectedCategory = selected ? category : '';
        });
      },
    );
  }

  void _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _applyFilter() {
    Navigator.of(context).pop(EventFilter(
      category: _selectedCategory,
      date: _selectedDate,
    ));
  }
}
