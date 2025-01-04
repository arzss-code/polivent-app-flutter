import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:polivent_app/models/ui_colors.dart';
import 'package:polivent_app/config/app_config.dart';
import 'package:polivent_app/services/token_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EventFilter {
  String category;
  // DateTime? date;
  DateTime? dateFrom;
  DateTime? dateTo;

  EventFilter({
    this.category = '',
    // this.date,
    this.dateFrom,
    this.dateTo,
  });

  void resetFilter() {
    category = '';
    // date = null;
    dateFrom = null;
    dateTo = null;
  }

  bool isEmpty() {
    return category.isEmpty && dateFrom == null && dateTo == null;
  }

  // Method untuk membuat query parameter
  String getQueryParams() {
    final params = <String, String>{};

    if (category.isNotEmpty) {
      params['category'] = category;
    }

    if (dateFrom != null && dateTo != null) {
      params['date_from'] = DateFormat('yyyy-MM-dd').format(dateFrom!);
      params['date_to'] = DateFormat('yyyy-MM-dd').format(dateTo!);
    }

    return params.entries.map((e) => '${e.key}=${e.value}').join('&');
  }

  static Future<EventFilter?> showFilterBottomSheet(
    BuildContext context, {
    String currentCategory = '',
    DateTime? currentDateFrom,
    DateTime? currentDateTo,
  }) {
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
        return _FilterBottomSheetContent(
          currentCategory: currentCategory,
          currentDateFrom: currentDateFrom,
          currentDateTo: currentDateTo,
        );
      },
    );
  }
}

class _FilterBottomSheetContent extends StatefulWidget {
  final String currentCategory;
  final DateTime? currentDateFrom;
  final DateTime? currentDateTo;
  const _FilterBottomSheetContent({
    required this.currentCategory,
    this.currentDateFrom,
    this.currentDateTo,
  });

  @override
  _FilterBottomSheetContentState createState() =>
      _FilterBottomSheetContentState();
}

class _FilterBottomSheetContentState extends State<_FilterBottomSheetContent> {
  String _selectedCategory = '';
  DateTime? _selectedDate;
  List<String> _categories = [];
  bool _isLoading = true;
  // Tambahkan variabel untuk menyimpan rentang tanggal
  DateTime? _dateFrom;
  DateTime? _dateTo;
  DateTime? _selectedDateFrom;
  DateTime? _selectedDateTo;

  // Konstruktor untuk menerima filter saat ini
  _FilterBottomSheetContentState({
    String initialCategory = '',
  }) {
    _selectedCategory = initialCategory;
  }

  @override
  void initState() {
    super.initState();
    // Inisialisasi dengan kategori saat ini
    _selectedCategory = widget.currentCategory;
    _selectedDateFrom = widget.currentDateFrom;
    _selectedDateTo = widget.currentDateTo;
    _fetchCategories();
  }

  void _selectDateRange() async {
    final DateTimeRange? pickedDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      initialDateRange: _selectedDateFrom != null && _selectedDateTo != null
          ? DateTimeRange(start: _selectedDateFrom!, end: _selectedDateTo!)
          : null,

      // Kustomisasi tampilan
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            // Warna utama sesuai primary color
            primaryColor: UIColor.primaryColor,

            // Warna aksen
            colorScheme: ColorScheme.light(
              primary: UIColor.primaryColor, // Warna header dan tombol aktif
              onPrimary: Colors.white, // Warna teks pada primary
              surface: UIColor.solidWhite, // Warna background
              onSurface: Colors.black, // Warna teks default
              secondary:
                  UIColor.primaryColor.withOpacity(0.3), // Warna sekunder
            ),

            // Gaya tombol
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: UIColor.primaryColor, // Warna teks tombol
              ),
            ),
          ),
          child: child!,
        );
      },

      // Kustomisasi UI tambahan
      confirmText: 'Pilih',
      cancelText: 'Batal',
      helpText: 'Pilih Rentang Tanggal',

      // Efek visual tambahan
      errorFormatText: 'Format tanggal tidak valid',
      errorInvalidText: 'Tanggal tidak valid',
      fieldStartHintText: 'Mulai',
      fieldEndHintText: 'Selesai',
    );

    if (pickedDateRange != null) {
      setState(() {
        _selectedDateFrom = pickedDateRange.start;
        _selectedDateTo = pickedDateRange.end;
      });
    }
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
      minChildSize: 0.4,
      maxChildSize: 0.5,
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

              // Title dan Reset Button
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filter Pencarian Event',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Modifikasi kondisi tampilan tombol reset
                    if (_selectedCategory.isNotEmpty ||
                        _selectedDateFrom != null ||
                        _selectedDateTo != null)
                      _buildResetButton(),
                  ],
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

                          // Modifikasi widget date filter
                          _buildFilterSection(
                            title: 'Rentang Tanggal',
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: UIColor.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              onPressed: _selectDateRange,
                              child: Text(
                                _selectedDateFrom == null ||
                                        _selectedDateTo == null
                                    ? 'Pilih Rentang Tanggal'
                                    : '${DateFormat('dd/MM/yyyy').format(_selectedDateFrom!)} - ${DateFormat('dd/MM/yyyy').format(_selectedDateTo!)}',
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

  // Tambahkan tombol reset
  Widget _buildResetButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          _selectedCategory = '';
          // Reset rentang tanggal
          _selectedDateFrom = null;
          _selectedDateTo = null;
        });
      },
      child: const Text(
        'Reset',
        style: TextStyle(
          color: UIColor.primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
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

  // Modifikasi method _applyFilter untuk mengirim rentang tanggal
  void _applyFilter() {
    Navigator.of(context).pop(EventFilter(
      category: _selectedCategory,
      dateFrom: _selectedDateFrom,
      dateTo: _selectedDateTo,
    ));
  }
}
