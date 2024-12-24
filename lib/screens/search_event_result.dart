import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:polivent_app/models/search_events.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:polivent_app/config/app_config.dart';
import 'package:polivent_app/models/ui_colors.dart';
import 'package:polivent_app/models/event_filter.dart';
import 'package:polivent_app/services/auth_services.dart';
import 'package:uicons_pro/uicons_pro.dart';
import 'package:polivent_app/screens/detail_events.dart';

class SearchEventsResultScreen extends StatefulWidget {
  final String searchQuery;
  final String? category;
  final String? location;
  final String? date; // Ubah dari DateTime ke String

  const SearchEventsResultScreen({
    super.key,
    required this.searchQuery,
    this.category,
    this.location,
    this.date,
    List<dynamic>? events, // Tambahkan parameter opsional events
  });

  @override
  _SearchEventsResultScreenState createState() =>
      _SearchEventsResultScreenState();
}

class _SearchEventsResultScreenState extends State<SearchEventsResultScreen> {
  // final GlobalKey<SearchEventsWidgetState> _searchKey =
  //     GlobalKey<SearchEventsWidgetState>();
  List<Map<String, dynamic>> _events = [];
  late EventFilter _currentFilter;
  bool _isLoading = true;
  String _errorMessage = '';
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);

    // Inisialisasi filter dari parameter konstruktor
    _currentFilter = EventFilter(
      category: widget.category ?? '',
      date: widget.date != null ? DateTime.tryParse(widget.date!) : null,
    );

    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    try {
      // Hapus variabel yang tidak digunakan
      final accessToken = await _getAccessToken();

      // Konstruksi URL dengan parameter pencarian
      String url =
          '$prodApiBaseUrl/available_events?search=${widget.searchQuery}';

      // Tambahkan parameter filter jika ada
      if (_currentFilter.category.isNotEmpty) {
        url += '&category=${_currentFilter.category}';
      }

      if (_currentFilter.date != null) {
        url += '&date=${DateFormat('yyyy-MM-dd').format(_currentFilter.date!)}';
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

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['status'] == 'success') {
          final List<dynamic> eventsData = jsonResponse['data'];

          setState(() {
            _events = eventsData
                .map((event) => {
                      'event_id': event['event_id'], // Tambahkan event_id
                      'title': event['title'],
                      'date': _formatDate(event['date_start']),
                      'location': event['location'],
                      'image': event['poster'],
                      'category': event['category_name'],
                    })
                .toList();
          });
        } else {
          throw Exception(jsonResponse['message'] ?? 'Pencarian gagal');
        }
      } else {
        throw Exception('Gagal mencari event. Status: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      print('Error searching events: $e');
    }
  }

  Future<String> _getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token') ?? '';
  }

  String _formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(dateTime);
    } catch (e) {
      return dateString;
    }
  }

  void _showFilterModal() async {
    final updatedFilter = await EventFilter.showFilterBottomSheet(context);

    if (updatedFilter != null) {
      setState(() {
        _currentFilter = updatedFilter;
        _isLoading = true;
      });

      _fetchEvents();
    }
  }

  void _clearFilter() {
    setState(() {
      _currentFilter = EventFilter(); // Reset filter
      _isLoading = true;
    });
    _fetchEvents();
  }

  void _editSearchQuery() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 10,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ubah Pencarian',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: UIColor.primaryColor,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Masukkan kata kunci pencarian',
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: Icon(
                        Icons.search,
                        color: UIColor.primaryColor,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                    autofocus: true,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _performNewSearch(),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: UIColor.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _performNewSearch,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.search, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Cari',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _performNewSearch() {
    if (_searchController.text.trim().isNotEmpty) {
      Navigator.of(context).pop(); // Tutup dialog

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SearchEventsResultScreen(
            searchQuery: _searchController.text.trim(),
            category: _currentFilter.category,
            date: _currentFilter.date != null
                ? DateFormat('yyyy-MM-dd').format(_currentFilter.date!)
                : null,
          ),
        ),
      );
    } else {
      // Tampilkan pesan jika input kosong
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Masukkan kata kunci pencarian'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: UIColor.solidWhite,
        title: GestureDetector(
          onTap: _editSearchQuery, // Tambahkan aksi tap
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hasil Pencarian',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              Text(
                widget.searchQuery,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                Icon(UIconsPro.solidRounded.settings_sliders,
                    color: Colors.black, size: 20),
                // Indikator filter aktif
                if (!_currentFilter.isEmpty())
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        _calculateActiveFiltersCount().toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: _showFilterModal,
          ),
        ],
      ),
      body: Column(
        children: [
          // SearchEventsWidget(key: _searchKey),
          // Filter Summary
          if (!_currentFilter.isEmpty())
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: UIColor.primaryColor.withOpacity(0.1),
              child: Row(
                children: [
                  const Text(
                    'Filter: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: UIColor.typoBlack,
                    ),
                  ),
                  if (_currentFilter.category.isNotEmpty)
                    _buildFilterChip(_currentFilter.category, () {
                      setState(() {
                        _currentFilter.category = '';
                        _isLoading = true;
                      });
                      _fetchEvents();
                    }),
                  if (_currentFilter.date != null)
                    _buildFilterChip(
                      '${_currentFilter.date!.day}/${_currentFilter.date!.month}/${_currentFilter.date!.year}',
                      () {
                        setState(() {
                          _currentFilter.date = null;
                          _isLoading = true;
                        });
                        _fetchEvents();
                      },
                    ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.clear_all, color: Colors.red),
                    onPressed: _clearFilter,
                  ),
                ],
              ),
            ),

          // Loading Indicator
          if (_isLoading) const Center(child: CircularProgressIndicator()),

          // Error Message
          if (_errorMessage.isNotEmpty)
            Center(
              child: Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            ),

          // Event List
          if (!_isLoading && _errorMessage.isEmpty)
            Expanded(
              child: _events.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _events.length,
                      itemBuilder: (context, index) {
                        return _buildEventCard(_events[index]);
                      },
                    ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onDeleted) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(
          label,
          style: const TextStyle(color: UIColor.primaryColor),
        ),
        backgroundColor: UIColor.primaryColor.withOpacity(0.2),
        deleteIcon:
            const Icon(Icons.close, size: 16, color: UIColor.primaryColor),
        onDeleted: onDeleted,
      ),
    );
  }

  int _calculateActiveFiltersCount() {
    int count = 0;
    if (_currentFilter.category.isNotEmpty) count++;
    if (_currentFilter.date != null) count++;
    return count;
  }

  // Di dalam method _buildEventCard, bungkus Card dengan GestureDetector atau InkWell
  Widget _buildEventCard(Map<String, dynamic> event) {
    return GestureDetector(
      onTap: () {
        // Navigasi ke halaman detail event
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailEvents(
              eventId: event['event_id'], // Pastikan Anda memiliki event_id
            ),
          ),
        );
      },
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Image
              Image.network(
                event['image'],
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: UIColor.primaryColor.withOpacity(0.1),
                    child: Center(
                      child: Icon(
                        UIconsPro.regularRounded.calendar,
                        color: UIColor.primaryColor,
                        size: 50,
                      ),
                    ),
                  );
                },
              ),

              // Event Details
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event['title'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: UIColor.typoBlack,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(UIconsPro.regularRounded.calendar,
                            color: UIColor.primaryColor, size: 16),
                        const SizedBox(width: 8),
                        Text(event['date']),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(UIconsPro.regularRounded.marker,
                            color: UIColor.primaryColor, size: 16),
                        const SizedBox(width: 8),
                        Text(event['location']),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            UIconsPro.regularRounded.search,
            size: 50,
            color: UIColor.primaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tidak ada hasil ditemukan',
            style: TextStyle(
              fontSize: 18,
              color: UIColor.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Coba dengan kata kunci atau filter yang berbeda.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Jangan lupa dispose controller
    _searchController.dispose();
    super.dispose();
  }
}
