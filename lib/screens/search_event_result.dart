import 'package:flutter/material.dart';
import 'package:polivent_app/models/ui_colors.dart';
import 'package:uicons_pro/uicons_pro.dart';

class SearchEventsResultScreen extends StatefulWidget {
  final String searchQuery;
  final String? category;
  final String? location;
  final DateTime? date;

  const SearchEventsResultScreen({
    Key? key,
    required this.searchQuery,
    this.category,
    this.location,
    this.date,
  }) : super(key: key);

  @override
  _SearchEventsResultScreenState createState() =>
      _SearchEventsResultScreenState();
}

class _SearchEventsResultScreenState extends State<SearchEventsResultScreen> {
  List<Map<String, dynamic>> _events = [
    // Contoh data event (ganti dengan data dari backend/state management)
    {
      'title': 'Seminar Teknologi Terbaru',
      'date': '15 Mei 2024',
      'location': 'Online',
      'image': 'https://example.com/event1.jpg',
      'category': 'Seminar',
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

  @override
  void initState() {
    super.initState();
    _fetchFilteredEvents();
  }

  void _fetchFilteredEvents() {
    // Implementasi filter events berdasarkan parameter
    setState(() {
      _events = _events.where((event) {
        bool matchesQuery = event['title']
            .toLowerCase()
            .contains(widget.searchQuery.toLowerCase());

        bool matchesCategory =
            widget.category == null || event['category'] == widget.category;

        bool matchesLocation = widget.location == null ||
            event['location']
                .toLowerCase()
                .contains(widget.location!.toLowerCase());

        return matchesQuery && matchesCategory && matchesLocation;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: UIColor.primaryColor,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hasil Pencarian',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              widget.searchQuery,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(UIconsPro.regularRounded.filter, color: Colors.white),
            onPressed: () {
              // Tambahkan aksi untuk membuka filter ulang
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Summary
          if (widget.category != null ||
              widget.location != null ||
              widget.date != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: UIColor.primaryColor.withOpacity(0.1),
              child: Row(
                children: [
                  Text(
                    'Filter: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: UIColor.primaryColor,
                    ),
                  ),
                  if (widget.category != null)
                    _buildFilterChip(widget.category!),
                  if (widget.location != null)
                    _buildFilterChip(widget.location!),
                  if (widget.date != null)
                    _buildFilterChip(
                        '${widget.date!.day}/${widget.date!.month}/${widget.date!.year}'),
                ],
              ),
            ),

          // Event List
          Expanded(
            child: _events.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.all(16),
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

  Widget _buildFilterChip(String label) {
    return Container(
      margin: EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(
          label,
          style: TextStyle(color: UIColor.primaryColor),
        ),
        backgroundColor: UIColor.primaryColor.withOpacity(0.2),
        deleteIcon: Icon(Icons.close, size: 16, color: UIColor.primaryColor),
        onDeleted: () {
          // Implementasi hapus filter
        },
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
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
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: UIColor.primaryColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(UIconsPro.regularRounded.calendar,
                          color: UIColor.primaryColor, size: 16),
                      SizedBox(width: 8),
                      Text(event['date']),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(UIconsPro.regularRounded.marker,
                          color: UIColor.primaryColor, size: 16),
                      SizedBox(width: 8),
                      Text(event['location']),
                    ],
                  ),
                ],
              ),
            ),

            // Detail Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: UIColor.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  // Navigasi ke halaman detail event
                },
                child: Text('Lihat Detail'),
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
          SizedBox(height: 16),
          Text(
            'Tidak ada hasil ditemukan',
            style: TextStyle(
              fontSize: 18,
              color: UIColor.primaryColor,
            ),
          ),
          SizedBox(height: 8),
          Text(
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
