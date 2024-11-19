import 'package:flutter/material.dart';
import 'package:polivent_app/models/ui_colors.dart';
import 'package:polivent_app/models/event_filter.dart';
import 'package:uicons_pro/uicons_pro.dart';

class SearchEventsResultScreen extends StatefulWidget {
  final String searchQuery;
  final String? category;
  final String? location;
  final DateTime? date;

  const SearchEventsResultScreen({
    super.key,
    required this.searchQuery,
    this.category,
    this.location,
    this.date,
  });

  @override
  _SearchEventsResultScreenState createState() =>
      _SearchEventsResultScreenState();
}

class _SearchEventsResultScreenState extends State<SearchEventsResultScreen> {
  final List<Map<String, dynamic>> _originalEvents = [
    // Contoh data event (ganti dengan data dari backend/state management)
    {
      'title': 'Share Your Knowledge',
      'date': 'Senin, 14 Oktober 2024',
      'location': 'MST Lt. 3 Polines',
      'image': 'https://example.com/event1.jpg',
      'category': 'Seminar',
    },
    {
      'title': 'Seminar Nasional',
      'date': 'Senin, 14 Oktober 2024',
      'location': 'GKT Lt. 2 Polines',
      'image': 'https://example.com/event2.jpg',
      'category': 'Seminar',
    },
    {
      'title': 'Workshop',
      'date': '20 Juni 2024',
      'location': 'Gedung Pertemuan Jakarta',
      'image': 'https://example.com/event2.jpg',
      'category': 'Workshop',
    },
    {
      'title': 'Techcomfest',
      'date': '20 Juni 2024',
      'location': 'Gedung Pertemuan Jakarta',
      'image': 'https://example.com/event2.jpg',
      'category': 'Workshop',
    },
    {
      'title': 'Workshop Pengembangan Bisnis',
      'date': '20 Juni 2024',
      'location': 'Gedung Pertemuan Jakarta',
      'image': 'https://example.com/event2.jpg',
      'category': 'Workshop',
    },
    {
      'title': 'Workshop Pengembangan Bisnis',
      'date': '20 Juni 2024',
      'location': 'Gedung Pertemuan Jakarta',
      'image': 'https://example.com/event2.jpg',
      'category': 'Workshop',
    },
    {
      'title': 'Workshop Pengembangan Bisnis',
      'date': '20 Juni 2024',
      'location': 'Gedung Pertemuan Jakarta',
      'image': 'https://example.com/event2.jpg',
      'category': 'Workshop',
    },
    // Tambahkan event lainnya
  ];

  List<Map<String, dynamic>> _events = [];
  late EventFilter _currentFilter;

  @override
  void initState() {
    super.initState();

    // Inisialisasi filter dari parameter konstruktor
    _currentFilter = EventFilter(
      category: widget.category ?? '',
      location: widget.location ?? '',
      date: widget.date,
    );

    // Inisialisasi events
    _events = _originalEvents;
    _fetchFilteredEvents();
  }

  void _fetchFilteredEvents() {
    setState(() {
      _events = _originalEvents.where((event) {
        // Filter berdasarkan query pencarian
        bool matchesQuery = event['title']
            .toLowerCase()
            .contains(widget.searchQuery.toLowerCase());

        // Filter berdasarkan kategori
        bool matchesCategory = _currentFilter.category.isEmpty ||
            event['category'] == _currentFilter.category;

        // Filter berdasarkan lokasi
        bool matchesLocation = _currentFilter.location.isEmpty ||
            event['location']
                .toLowerCase()
                .contains(_currentFilter.location.toLowerCase());

        return matchesQuery && matchesCategory && matchesLocation;
      }).toList();
    });
  }

  void _showFilterModal() async {
    final updatedFilter = await EventFilter.showFilterBottomSheet(context);

    if (updatedFilter != null) {
      setState(() {
        _currentFilter = updatedFilter;
      });

      _fetchFilteredEvents();
    }
  }

  void _clearFilter() {
    setState(() {
      _currentFilter = EventFilter(); // Reset filter
      _events = _originalEvents; // Kembalikan ke event asli
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: UIColor.solidWhite,
        title: Column(
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
          ],
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
                      });
                      _fetchFilteredEvents();
                    }),
                  if (_currentFilter.location.isNotEmpty)
                    _buildFilterChip(_currentFilter.location, () {
                      setState(() {
                        _currentFilter.location = '';
                      });
                      _fetchFilteredEvents();
                    }),
                  if (_currentFilter.date != null)
                    _buildFilterChip(
                      '${_currentFilter.date!.day}/${_currentFilter.date!.month}/${_currentFilter.date!.year}',
                      () {
                        setState(() {
                          _currentFilter.date = null;
                        });
                        _fetchFilteredEvents();
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

          // Event List
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
    if (_currentFilter.location.isNotEmpty) count++;
    if (_currentFilter.date != null) count++;
    return count;
  }

  // Metode _buildEventCard dan _buildEmptyState tetap sama seperti sebelumnya
  Widget _buildEventCard(Map<String, dynamic> event) {
    return Card(
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
}
