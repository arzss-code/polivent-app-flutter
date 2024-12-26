import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:polivent_app/screens/home/explore/explore_upcoming_events.dart';
import 'package:polivent_app/screens/home/explore/explore_quick_category_section.dart';
import 'package:polivent_app/screens/home/explore/explore_most_likes_carousel.dart';
import 'package:polivent_app/models/search_events.dart';
import 'package:polivent_app/models/ui_colors.dart';
import 'package:polivent_app/screens/home/explore/notification.dart';
import 'package:polivent_app/services/auth_services.dart'; // Import AuthService
import 'package:polivent_app/services/data/user_model.dart'; // Import User model

class HomeExplore extends StatefulWidget {
  const HomeExplore({super.key});

  @override
  State<HomeExplore> createState() => _HomeExploreState();
}

class _HomeExploreState extends State<HomeExplore> {
  // Key untuk refresh
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  // Key untuk refresh
  final GlobalKey<CarouselEventsState> _carouselKey =
      GlobalKey<CarouselEventsState>();
  // Key untuk refresh
  final GlobalKey<EventListWidgetState> _eventListKey =
      GlobalKey<EventListWidgetState>();
  final GlobalKey<SearchEventsWidgetState> _searchKey =
      GlobalKey<SearchEventsWidgetState>();

  User? _currentUser;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final authService = AuthService();
      final userData = await authService.getUserData();

      setState(() {
        _currentUser = userData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Metode refresh yang mencakup semua data
  Future<void> _refreshAllData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Fetch user data
      final authService = AuthService();
      final userData = await authService.getUserData();

      // Refresh global keys untuk komponen yang membutuhkan refresh
      _searchKey.currentState?.updateSearch();

      // Jika komponen-komponen lain memiliki method refresh, panggil di sini
      // Contoh:
      _carouselKey.currentState?.fetchMostLikedEvents();
      _eventListKey.currentState?.fetchUpcomingEvents();

      setState(() {
        _currentUser = userData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(child: Text('Error: $_errorMessage'));
    }

    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _refreshAllData,
      color: UIColor.primaryColor,
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('assets/images/appbar_image.png'),
                  fit: BoxFit.cover,
                ),
                border: Border.all(
                  color: UIColor.primaryColor,
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
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          Text(
                            'Halo, ${_currentUser?.username ?? 'Pengguna'} 👋',
                            style: const TextStyle(
                              fontSize: 22,
                              fontFamily: "Inter",
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            "Ayo mulai jelajahi event!",
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: "Inter",
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                                    color: Color.fromRGBO(255, 255, 255, 0.305))
                                .copyWith(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const NotificationPage()));
                                },
                                icon: const Icon(
                                  Icons.notifications_rounded,
                                  color: Colors.white,
                                  size: 24,
                                )),
                          )
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 70),
                  SearchEventsWidget(key: _searchKey),
                  const SizedBox(height: 4),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const QuickCategorySection(),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Text(
                'Event Paling Disukai',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: UIColor.typoBlack,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const CarouselSection(),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Text(
                'Event Yang Akan Datang',
                textAlign: TextAlign.right,
                style: TextStyle(
                    color: UIColor.typoBlack,
                    fontSize: 18,
                    fontWeight: FontWeight.w700),
              ),
            ),
            const EventList()
          ],
        ),
      ),
    );
  }
}
