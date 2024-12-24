import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:polivent_app/config/app_config.dart';
import 'package:polivent_app/models/ui_colors.dart';
import 'package:polivent_app/models/event_filter.dart';
import 'package:polivent_app/screens/search_event_result.dart';
import 'package:polivent_app/services/auth_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uicons_pro/uicons_pro.dart';

class SearchEventsWidget extends StatefulWidget {
  const SearchEventsWidget({super.key});

  @override
  SearchEventsWidgetState createState() => SearchEventsWidgetState();
}

class SearchEventsWidgetState extends State<SearchEventsWidget> {
  final TextEditingController _searchController = TextEditingController();

  Future<void> _searchEvents(String searchQuery,
      {String? category, String? location, String? date}) async {
    try {
      final authService = AuthService();
      final accessToken = await _getAccessToken();

      // Konstruksi URL dengan parameter pencarian
      String url = '$prodApiBaseUrl/available_events?search=$searchQuery';

      // Tambahkan parameter filter jika ada
      if (category != null && category.isNotEmpty) {
        url += '&category=$category';
      }
      if (location != null && location.isNotEmpty) {
        url += '&location=$location';
      }
      if (date != null && date.isNotEmpty) {
        url += '&date=$date';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('Search Response Status: ${response.statusCode}');
      print('Search Response Body: ${response.body}');

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
                location: location,
                date: date,
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
      print('Error searching events: $e');
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
    return SizedBox(
      height: 45,
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
              final filter = await EventFilter.showFilterBottomSheet(context);
              if (filter != null) {
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
            _searchEvents(searchQuery);
          }
        },
      ),
    );
  }

  void _applyFilter(EventFilter filter) {
    // Lakukan pencarian dengan filter
    _searchEvents(
      _searchController.text,
      category: filter.category,
      date: filter.date?.toIso8601String(),
    );
  }

  String getSearchValue() {
    return _searchController.text;
  }
}
