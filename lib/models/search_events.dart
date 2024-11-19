import 'package:polivent_app/models/ui_colors.dart';
import 'package:uicons_pro/uicons_pro.dart';
import 'package:flutter/material.dart';
import 'package:polivent_app/screens/search_event_result.dart';

class SearchEventsWidget extends StatefulWidget {
  const SearchEventsWidget({super.key});

  @override
  SearchEventsWidgetState createState() => SearchEventsWidgetState();
}

class SearchEventsWidgetState extends State<SearchEventsWidget> {
  final TextEditingController _searchController = TextEditingController();

  // Variabel untuk menyimpan filter yang dipilih
  String _selectedCategory = '';
  String _selectedLocation = '';
  DateTime? _selectedDate;

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
            onTap: _showFilterBottomSheet,
            child: Icon(
              UIconsPro.regularRounded.settings_sliders,
              color: UIColor.typoBlack,
              size: 18,
            ),
          ),
        ),
        onSubmitted: (searchQuery) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    SearchEventsResultScreen(searchQuery: searchQuery)),
          );
        },
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.95,
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
                      // Indikator drag
                      Container(
                        width: 30,
                        height: 4,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: UIColor.typoBlack.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),

                      // Judul
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Text(
                          'Filter Pencarian Event',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            // color: UIColor.primaryColor,
                          ),
                        ),
                      ),

                      // Konten yang dapat di-scroll
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            // Kategori Filter
                            _buildFilterSection(
                              title: 'Kategori',
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _buildCategoryChip(setState, 'Seminar'),
                                  _buildCategoryChip(setState, 'Workshop'),
                                  _buildCategoryChip(setState, 'Konferensi'),
                                  _buildCategoryChip(setState, 'Musik'),
                                  _buildCategoryChip(setState, 'E-Sport'),
                                  _buildCategoryChip(setState, 'Olahraga'),
                                ],
                              ),
                            ),

                            // Lokasi Filter
                            _buildFilterSection(
                              title: 'Lokasi',
                              child: Wrap(
                                spacing: 8,
                                children: [
                                  _buildLocationChip(setState, 'Online'),
                                  _buildLocationChip(setState, 'Offline'),
                                ],
                              ),
                            ),

                            // Tanggal Filter
                            _buildFilterSection(
                              title: 'Tanggal',
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: UIColor.primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                onPressed: () async {
                                  final DateTime? pickedDate =
                                      await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(2025),
                                    builder: (context, child) {
                                      return Theme(
                                        data: ThemeData.light().copyWith(
                                          primaryColor: UIColor.primaryColor,
                                          colorScheme: const ColorScheme.light(
                                            primary: UIColor.primaryColor,
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (pickedDate != null) {
                                    setState(() {
                                      _selectedDate = pickedDate;
                                    });
                                  }
                                },
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

                      // Tombol Terapkan di bagian bawah
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
                            onPressed: () {
                              Navigator.pop(context);
                              _applyFilter();
                            },
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
          },
        );
      },
    );
  }

// Helper method untuk membuat section filter
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

  Widget _buildCategoryChip(StateSetter setState, String category) {
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

  Widget _buildLocationChip(StateSetter setState, String location) {
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

  void _applyFilter() {
    // Implementasi logika pencarian dengan filter
    print('Category: $_selectedCategory');
    print('Location: $_selectedLocation');
    print('Date: $_selectedDate');

    // Contoh: Navigasi ke halaman hasil pencarian dengan parameter filter
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchEventsResultScreen(
          searchQuery: _searchController.text,
          category: _selectedCategory,
          location: _selectedLocation,
          date: _selectedDate,
        ),
      ),
    );
  }

  String getSearchValue() {
    return _searchController.text;
  }
}
