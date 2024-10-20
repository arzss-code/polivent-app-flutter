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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: TextField(
        textInputAction: TextInputAction.search,
        // controller: _searchController,
        maxLines: 1,
        minLines: 1,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          isDense: true,
          alignLabelWithHint: true,
          hintText: 'Search event...',
          contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
          hintStyle: const TextStyle(color: UIColor.typoGray, fontSize: 14),
          filled: true,
          fillColor: UIColor.solidWhite,
          prefixIcon: Icon(
            UIconsPro.regularRounded.search,
            color: UIColor.typoBlack,
            size: 18,
          ),
          suffixIcon: Icon(
            UIconsPro.regularRounded.settings_sliders,
            color: UIColor.typoBlack,
            size: 18,
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

  String getSearchValue() {
    return _searchController.text;
  }
}
