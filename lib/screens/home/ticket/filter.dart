import 'package:flutter/material.dart';
import 'package:polivent_app/models/ui_colors.dart';

class FilterModalWidget extends StatefulWidget {
  final bool showNotPresent;
  final bool showHasPresent;
  final bool isUpcomingTab;
  final Function(bool, bool) onApplyFilters;

  const FilterModalWidget({
    super.key,
    required this.showNotPresent,
    required this.showHasPresent,
    required this.isUpcomingTab,
    required this.onApplyFilters,
  });

  @override
  State<FilterModalWidget> createState() => _FilterModalWidgetState();
}

class _FilterModalWidgetState extends State<FilterModalWidget> {
  late bool _showNotPresent;
  late bool _showHasPresent;

  @override
  void initState() {
    super.initState();
    _showNotPresent = widget.showNotPresent;
    _showHasPresent = widget.showHasPresent;
  }

  void _resetToDefault() {
    setState(() {
      if (widget.isUpcomingTab) {
        _showNotPresent = true;
        _showHasPresent = false;
      } else {
        _showNotPresent = false;
        _showHasPresent = true;
      }
    });
  }

  void _updateFilters(bool? value, bool isNotPresent) {
    setState(() {
      if (isNotPresent) {
        _showNotPresent = value ?? false;
        // If turning on not_present, turn off has_present
        if (_showNotPresent) {
          _showHasPresent = false;
        }
      } else {
        _showHasPresent = value ?? false;
        // If turning on has_present, turn off not_present
        if (_showHasPresent) {
          _showNotPresent = false;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.isUpcomingTab ? 'Tiket Akan Datang' : 'Tiket Selesai',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: UIColor.primaryColor,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Filter Options
          const Text(
            'Status Kehadiran',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: UIColor.typoBlack,
            ),
          ),
          const SizedBox(height: 10),

          // Show checkboxes based on tab
          if (widget.isUpcomingTab)
            CheckboxListTile(
              value: _showNotPresent,
              onChanged: (value) {
                setState(() => _showNotPresent = value ?? true);
              },
              title: const Text(
                'Belum Hadir',
                style: TextStyle(fontSize: 14),
              ),
              activeColor: UIColor.primaryColor,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            )
          else
            CheckboxListTile(
              value: _showHasPresent,
              onChanged: (value) {
                setState(() => _showHasPresent = value ?? true);
              },
              title: const Text(
                'Sudah Hadir',
                style: TextStyle(fontSize: 14),
              ),
              activeColor: UIColor.primaryColor,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),

          const SizedBox(height: 20),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _resetToDefault,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: UIColor.primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: const Text(
                    'Reset',
                    style: TextStyle(color: UIColor.primaryColor),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApplyFilters(_showNotPresent, _showHasPresent);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: UIColor.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: const Text(
                    'Terapkan',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
