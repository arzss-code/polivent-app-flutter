import 'package:flutter/material.dart';
import 'package:polivent_app/models/ui_colors.dart';

class EventFilter {
  String category;
  String location;
  DateTime? date;

  EventFilter({
    this.category = '',
    this.location = '',
    this.date,
  });

  // Method untuk mereset filter
  void resetFilter() {
    category = '';
    location = '';
    date = null;
  }

  // Method untuk mengecek apakah filter kosong
  bool isEmpty() {
    return category.isEmpty && location.isEmpty && date == null;
  }

  // Method untuk menampilkan bottom sheet filter
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
  String _selectedLocation = '';
  DateTime? _selectedDate;

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
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // Category Filter
                    _buildFilterSection(
                      title: 'Kategori',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildCategoryChip('Seminar'),
                          _buildCategoryChip('Workshop'),
                          _buildCategoryChip('Konferensi'),
                          _buildCategoryChip('Musik'),
                          _buildCategoryChip('E-Sport'),
                          _buildCategoryChip('Olahraga'),
                        ],
                      ),
                    ),

                    // Location Filter
                    _buildFilterSection(
                      title: 'Lokasi',
                      child: Wrap(
                        spacing: 8,
                        children: [
                          _buildLocationChip('Online'),
                          _buildLocationChip('Offline'),
                        ],
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

  Widget _buildLocationChip(String location) {
    return ChoiceChip(
      label: Text(location),
      selected: _selectedLocation == location,
      backgroundColor: Colors.white,
      selectedColor: UIColor.primaryColor.withOpacity(0.2),
      labelStyle: TextStyle(
        color:
            _selectedLocation == location ? UIColor.primaryColor : Colors.black,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: _selectedLocation == location
              ? UIColor.primaryColor
              : Colors.grey.shade300,
        ),
      ),
      onSelected: (bool selected) {
        setState(() {
          _selectedLocation = selected ? location : '';
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
      location: _selectedLocation,
      date: _selectedDate,
    ));
  }
}
