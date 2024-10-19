import 'package:polivent_app/models/explore_more_events.dart';
import 'package:polivent_app/models/explore_quick_category_section.dart';
import 'package:polivent_app/models/explore_carousel_section.dart';
import 'package:polivent_app/models/search_events.dart';
// import 'package:flutter/services.dart';

// import 'package:uicons_pro/uicons_pro.dart';
import 'package:flutter/material.dart';

class HomeExplore extends StatefulWidget {
  const HomeExplore({super.key});

  @override
  State<HomeExplore> createState() => _HomeExploreState();
}

class _HomeExploreState extends State<HomeExplore> {
  final GlobalKey<SearchEventsWidgetState> _searchKey =
      GlobalKey<SearchEventsWidgetState>();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/images/appbar_image.png'),
                fit:
                    BoxFit.cover, // Set the image to cover the entire container
              ),
              border: Border.all(
                color: Colors.blue, // Set the border color to white
                width: 0, // Set the border width to 1
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                const Text(
                  'Hi, Atsiila Arya 👋',
                  style: TextStyle(
                    fontSize: 24,
                    fontFamily: "Inter",
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Let's explore the events!",
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: "Inter",
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 63),
                SearchEventsWidget(
                    key: _searchKey), //! memanggil model => search
                const SizedBox(height: 4),
              ],
            ),
          ),
          const SizedBox(
            height: 14,
          ),
          const QuickCategorySection(), //! -- Quick Category
          const CarouselSection(), //! -- Carousel Events
          const EventList() //! -- Events Available
        ],
      ),
    );
  }
}
