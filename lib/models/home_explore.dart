import 'package:polivent_app/models/explore_more_events.dart';
import 'package:polivent_app/models/explore_quick_category_section.dart';
import 'package:polivent_app/models/explore_carousel_section.dart';
import 'package:polivent_app/models/search_events.dart';
import 'package:flutter/material.dart';
import 'package:polivent_app/models/ui_colors.dart';

class HomeExplore extends StatefulWidget {
  const HomeExplore({super.key});

  @override
  State<HomeExplore> createState() => _HomeExploreState();
}

class _HomeExploreState extends State<HomeExplore> {
  final GlobalKey<SearchEventsWidgetState> _searchKey =
      GlobalKey<SearchEventsWidgetState>();

  Future<void> _onRefresh() async {
    // Tambahkan logika refresh data di sini
    // Contoh: await fetchNewData();
    await Future.delayed(const Duration(seconds: 2)); // Simulasi loading
    setState(() {
      // Update state setelah data di-refresh
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('assets/images/appbar_image.png'),
                  fit: BoxFit.cover,
                ),
                border: Border.all(
                  color: Colors.blue,
                  width: 0,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      const Text(
                        'Halo, Atsiila Arya 👋',
                        style: TextStyle(
                          fontSize: 22,
                          fontFamily: "Inter",
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                                color: Color.fromRGBO(255, 255, 255, 0.185))
                            .copyWith(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.notifications_rounded,
                              color: Colors.white,
                              size: 24,
                            )),
                      )
                    ],
                  ),
                  const Row(
                    children: [
                      Text(
                        "Ayo mulai jelajahi event!",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: "Inter",
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 68),
                  SearchEventsWidget(key: _searchKey),
                  const SizedBox(height: 4),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const QuickCategorySection(),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Text(
                'Trending Events',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: UIColor.typoBlack,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const CarouselSection(),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Text(
                'Events Available',
                textAlign: TextAlign.right,
                style: TextStyle(
                    color: UIColor.typoBlack,
                    fontSize: 18,
                    fontWeight: FontWeight.w800),
              ),
            ),
            const EventList()
          ],
        ),
      ),
    );
  }
}
