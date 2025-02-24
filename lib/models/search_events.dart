import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:polivent_app/config/app_config.dart';
import 'package:polivent_app/config/ui_colors.dart';
import 'package:polivent_app/models/event_filter.dart';
import 'package:polivent_app/models/search_event_result.dart';
import 'package:polivent_app/services/token_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uicons_pro/uicons_pro.dart';

class SearchEventsWidget extends StatefulWidget {
  final bool isFloating;

  const SearchEventsWidget({super.key, this.isFloating = false});

  @override
  SearchEventsWidgetState createState() => SearchEventsWidgetState();
}

class SearchEventsWidgetState extends State<SearchEventsWidget> {
  final TextEditingController _searchController = TextEditingController();
  EventFilter?
      _currentFilter; // Tambahkan variabel untuk menyimpan filter saat ini

  // Method untuk mereset search
  void resetSearch() {
    setState(() {
      _searchController.clear();
      _currentFilter = null;
    });
  }

  // Method untuk update search
  void updateSearch() {
    setState(() {
      // Implementasi refresh atau update search
      _searchController.clear();
    });
  }

  Future<void> _searchEvents(String searchQuery,
      {String? category, DateTime? dateFrom, DateTime? dateTo}) async {
    try {
      final accessToken = await TokenService.getAccessToken();

      // Konstruksi URL dengan parameter pencarian
      String url = '$prodApiBaseUrl/available_events?search=$searchQuery';

      // Tambahkan parameter filter jika ada
      if (category != null && category.isNotEmpty) {
        url += '&category=$category';
      }

      if (dateFrom != null && dateTo != null) {
        url +=
            '&date_from=${DateFormat('yyyy-MM-dd').format(dateFrom)}&date_to=${DateFormat('yyyy-MM-dd').format(dateTo)}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      debugPrint('Search URL: $url');
      debugPrint('Search Response Status: ${response.statusCode}');
      debugPrint('Search Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['status'] == 'success') {
          final List<dynamic> eventsData = jsonResponse['data'];

          // Navigasi ke halaman hasil pencarian dengan data events
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchEventsResultScreen(
                searchQuery: searchQuery,
                events: eventsData,
                category: category,
                dateFrom: dateFrom,
                dateTo: dateTo,
              ),
            ),
          );
        } else {
          // Tampilkan pesan error dari server
          _showErrorDialog(jsonResponse['message'] ?? 'Pencarian gagal');
        }
      } else {
        // Tampilkan pesan error berdasarkan status code
        _showErrorDialog('Gagal mencari event. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error searching events: $e');
      _showErrorDialog('Terjadi kesalahan: $e');
    }
  }

  Future<String> _getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token') ?? '';
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pencarian Event'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.isFloating
          ? const EdgeInsets.symmetric(horizontal: 20)
          : EdgeInsets.zero,
      child: Container(
        decoration: widget.isFloating
            ? BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    )
                  ])
            : null,
        child: TextField(
          textInputAction: TextInputAction.search,
          controller: _searchController,
          maxLines: 1,
          minLines: 1,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            isDense: true,
            alignLabelWithHint: true,
            hintText: 'Cari event',
            contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
            hintStyle: const TextStyle(color: UIColor.typoGray, fontSize: 14),
            filled: true,
            fillColor: UIColor.solidWhite,
            prefixIcon: Icon(
              UIconsPro.regularRounded.search,
              color: UIColor.typoBlack,
              size: 18,
            ),
            suffixIcon: GestureDetector(
              onTap: () async {
                final filter = await EventFilter.showFilterBottomSheet(
                  context,
                  // Kirim filter saat ini untuk ditampilkan
                  currentCategory: _currentFilter?.category ?? '',
                  currentDateFrom: _currentFilter?.dateFrom,
                  currentDateTo: _currentFilter?.dateTo,
                );

                if (filter != null) {
                  setState(() {
                    _currentFilter = filter;
                  });

                  // Lakukan pencarian jika ada teks di search
                  if (_searchController.text.isNotEmpty) {
                    _searchEvents(
                      _searchController.text,
                      category: filter.category,
                      dateFrom: filter.dateFrom,
                      dateTo: filter.dateTo,
                    );
                  }

                  // Terapkan filter
                  _applyFilter(filter);
                }
              },
              child: Icon(
                UIconsPro.regularRounded.settings_sliders,
                color: UIColor.typoBlack,
                size: 18,
              ),
            ),
          ),
          onSubmitted: (searchQuery) {
            if (searchQuery.isNotEmpty) {
              _searchEvents(
                searchQuery,
                category: _currentFilter?.category,
                dateFrom: _currentFilter?.dateFrom,
                dateTo: _currentFilter?.dateTo,
              );
            }
          },
        ),
      ),
    );
  }

  // Perbarui _showFilterModal
  void _showFilterModal() async {
    final updatedFilter = await EventFilter.showFilterBottomSheet(
      context,
      currentCategory: _currentFilter?.category ?? '',
      currentDateFrom: _currentFilter?.dateFrom,
      currentDateTo: _currentFilter?.dateTo,
    );

    if (updatedFilter != null) {
      setState(() {
        _currentFilter = updatedFilter;
      });

      // Lakukan pencarian jika ada teks di search
      if (_searchController.text.isNotEmpty) {
        _searchEvents(
          _searchController.text,
          category: updatedFilter.category,
          dateFrom: updatedFilter.dateFrom,
          dateTo: updatedFilter.dateTo,
        );
      }
    }
  }

  // Perbarui _applyFilter
  void _applyFilter(EventFilter filter) {
    // Lakukan pencarian dengan filter
    _searchEvents(
      _searchController.text,
      category: filter.category,
      dateFrom: filter.dateFrom,
      dateTo: filter.dateTo,
    );
  }

  String getSearchValue() {
    return _searchController.text;
  }
}
