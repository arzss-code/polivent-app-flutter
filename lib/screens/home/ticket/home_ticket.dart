import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:polivent_app/config/app_config.dart';
import 'package:polivent_app/models/comments.dart';
import 'package:polivent_app/models/ui_colors.dart';
import 'package:polivent_app/screens/auth/login_screen.dart';
import 'package:polivent_app/screens/home/ticket/detail_ticket.dart';
import 'package:polivent_app/screens/home/ticket/filter.dart';
import 'package:polivent_app/services/auth_services.dart';
// import 'package:polivent_app/services/data/events_model.dart';
import 'package:polivent_app/services/data/registration_model.dart';
import 'package:polivent_app/services/token_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:uicons_pro/uicons_pro.dart';

class EventHistoryPage extends StatefulWidget {
  const EventHistoryPage({super.key});

  @override
  _EventHistoryPageState createState() => _EventHistoryPageState();
}

class _EventHistoryPageState extends State<EventHistoryPage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  List<Registration> _upcomingEvents = [];
  List<Registration> _pastEvents = [];
  bool _isLoading = true;
  String _errorMessage = '';
  final TextEditingController _searchController = TextEditingController();

  // Add filter states
  bool _showNotPresent = true;
  bool _showHasPresent = true;

  final _connectivity = Connectivity();
  int _retryCount = 0;
  static const int _maxRetries = 3;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    _initializeEventHistory();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        // Set filter based on active tab
        if (_tabController.index == 0) {
          // Upcoming events tab
          _showNotPresent = true;
          _showHasPresent = false;
        } else {
          // Past events tab
          _showNotPresent = false;
          _showHasPresent = true;
        }
      });
      _checkConnectivityAndFetchEvents();
    }
  }

  void _showFilterModal() {
    final bool isUpcomingTab = _tabController.index == 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => FilterModalWidget(
        showNotPresent: _showNotPresent,
        showHasPresent: _showHasPresent,
        isUpcomingTab: isUpcomingTab,
        onApplyFilters: (notPresent, hasPresent) {
          setState(() {
            _showNotPresent = notPresent;
            _showHasPresent = hasPresent;
          });
          _checkConnectivityAndFetchEvents();
        },
      ),
    );
  }

  Future<void> _initializeEventHistory() async {
    // await _loadDummyEvents();
    await _checkConnectivityAndFetchEvents();
  }

  Future<bool> _checkConnectivityAndFetchEvents({String search = ''}) async {
    var connectivityResult = await _connectivity.checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _errorMessage = 'Tidak ada koneksi internet';
        _isLoading = false;
      });
      return false;
    }

    return await _fetchEventsWithRetry(search: search);
  }

  // Future<bool> _fetchEventsWithRetry({String search = ''}) async {
  //   try {
  //     setState(() {
  //       _isLoading = true;
  //       _errorMessage = '';
  //     });

  //     final authService = AuthService();
  //     final userData = await authService.getUserData();

  //     if (userData == null) {
  //       throw Exception('User tidak ditemukan');
  //     }

  //     final accessToken = await TokenService.getAccessToken();

  //     if (accessToken == null) {
  //       throw Exception('Access token tidak ditemukan');
  //     }

  //     final headers = {
  //       'Authorization': 'Bearer $accessToken',
  //       'Content-Type': 'application/json',
  //     };

  //     // Upcoming Events
  //     final upcomingUrl = _buildUrl(
  //       path: '/registration',
  //       params: {
  //         'user_id': userData.userId,
  //         'upcoming': 'true',
  //         if (_showNotPresent) 'not_present': 'true',
  //         if (_showHasPresent) 'has_present': 'true',
  //         if (search.isNotEmpty) 'search': search,
  //       },
  //     );

  //     // Past Events
  //     final pastUrl = _buildUrl(
  //       path: '/registration',
  //       params: {
  //         'user_id': userData.userId,
  //         // if (_showNotPresent) 'not_present': 'true',
  //         if (_showHasPresent) 'has_present': 'true',
  //         if (search.isNotEmpty) 'search': search,
  //       },
  //     );

  //     final upcomingResponse =
  //         await http.get(Uri.parse(upcomingUrl), headers: headers);
  //     final pastResponse = await http.get(Uri.parse(pastUrl), headers: headers);

  //     // Validasi response upcoming events
  //     if (upcomingResponse.statusCode == 200) {
  //       final upcomingData = json.decode(upcomingResponse.body);
  //       setState(() {
  //         _upcomingEvents = (upcomingData['data'] as List)
  //             .map((json) => Registration.fromJson(json))
  //             .toList();
  //       });
  //     } else if (upcomingResponse.statusCode != 404) {
  //       // Hanya tampilkan error jika bukan 404
  //       _handleHttpError(upcomingResponse.statusCode, 200);
  //       return false;
  //     }

  //     // Validasi response past events
  //     if (pastResponse.statusCode == 200) {
  //       final pastData = json.decode(pastResponse.body);
  //       // Filter events yang sudah berakhir
  //       // setState(() {
  //       //   _pastEvents = (pastData['data'] as List)
  //       //       .map((json) => Registration.fromJson(json))
  //       //       .where((event) {
  //       //     DateTime endDate = DateTime.parse(event.dateEnd);
  //       //     return endDate.isBefore(DateTime.now());
  //       //   }).toList();
  //       // });
  //       // Tampilkan semua event yang sudah berakhir
  //       setState(() {
  //         _pastEvents = (pastData['data'] as List)
  //             .map((json) => Registration.fromJson(json))
  //             .toList();
  //       });
  //     } else if (pastResponse.statusCode != 404) {
  //       // Hanya tampilkan error jika bukan 404
  //       _handleHttpError(200, pastResponse.statusCode);
  //       return false;
  //     }

  //     setState(() {
  //       _isLoading = false;
  //       _retryCount = 0;
  //     });

  //     return true;
  //   } catch (e) {
  //     _handleFetchError(e);
  //     return false;
  //   }
  // }

  // Future<bool> _fetchEventsWithRetry({String search = ''}) async {
  //   try {
  //     setState(() {
  //       _isLoading = true;
  //       _errorMessage = '';
  //     });

  //     final authService = AuthService();
  //     final userData = await authService.getUserData();

  //     if (userData == null) {
  //       throw Exception('User tidak ditemukan');
  //     }

  //     final accessToken = await TokenService.getAccessToken();

  //     if (accessToken == null) {
  //       throw Exception('Access token tidak ditemukan');
  //     }

  //     final headers = {
  //       'Authorization': 'Bearer $accessToken',
  //       'Content-Type': 'application/json',
  //     };

  //     // Upcoming Events - only fetch if not_present filter is active
  //     if (_showNotPresent && !_showHasPresent) {
  //       final upcomingUrl = _buildUrl(
  //         path: '/registration',
  //         params: {
  //           'user_id': userData.userId,
  //           'upcoming': 'true',
  //           'not_present': 'true',
  //           if (search.isNotEmpty) 'search': search,
  //         },
  //       );

  //       final upcomingResponse =
  //           await http.get(Uri.parse(upcomingUrl), headers: headers);

  //       if (upcomingResponse.statusCode == 200) {
  //         final upcomingData = json.decode(upcomingResponse.body);
  //         setState(() {
  //           _upcomingEvents = (upcomingData['data'] as List)
  //               .map((json) => Registration.fromJson(json))
  //               .toList();
  //         });
  //       } else if (upcomingResponse.statusCode != 404) {
  //         _handleHttpError(upcomingResponse.statusCode, 200);
  //         return false;
  //       }
  //     } else {
  //       // Clear upcoming events if filter is not active
  //       setState(() {
  //         _upcomingEvents = [];
  //       });
  //     }

  //     // Past Events - only fetch if has_present filter is active
  //     if (_showHasPresent && !_showNotPresent) {
  //       final pastUrl = _buildUrl(
  //         path: '/registration',
  //         params: {
  //           'user_id': userData.userId,
  //           'has_present': 'true',
  //           if (search.isNotEmpty) 'search': search,
  //         },
  //       );

  //       final pastResponse =
  //           await http.get(Uri.parse(pastUrl), headers: headers);

  //       if (pastResponse.statusCode == 200) {
  //         final pastData = json.decode(pastResponse.body);
  //         setState(() {
  //           _pastEvents = (pastData['data'] as List)
  //               .map((json) => Registration.fromJson(json))
  //               .toList();
  //         });
  //       } else if (pastResponse.statusCode != 404) {
  //         _handleHttpError(200, pastResponse.statusCode);
  //         return false;
  //       }
  //     } else {
  //       // Clear past events if filter is not active
  //       setState(() {
  //         _pastEvents = [];
  //       });
  //     }

  //     // If both filters are active, clear both lists
  //     if (_showNotPresent && _showHasPresent) {
  //       setState(() {
  //         _upcomingEvents = [];
  //         _pastEvents = [];
  //       });
  //     }

  //     setState(() {
  //       _isLoading = false;
  //       _retryCount = 0;
  //     });

  //     return true;
  //   } catch (e) {
  //     _handleFetchError(e);
  //     return false;
  //   }
  // }

  Future<bool> _fetchEventsWithRetry({String search = ''}) async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final authService = AuthService();
      final userData = await authService.getUserData();

      if (userData == null) {
        throw Exception('User tidak ditemukan');
      }

      final accessToken = await TokenService.getAccessToken();

      if (accessToken == null) {
        throw Exception('Access token tidak ditemukan');
      }

      final headers = {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };

      // Upcoming Events Tab
      if (_tabController.index == 0) {
        final upcomingUrl = _buildUrl(
          path: '/registration',
          params: {
            'user_id': userData.userId,
            'upcoming': 'true',
            if (_showNotPresent) 'not_present': 'true',
            if (search.isNotEmpty) 'search': search,
          },
        );

        final upcomingResponse =
            await http.get(Uri.parse(upcomingUrl), headers: headers);

        if (upcomingResponse.statusCode == 200) {
          final upcomingData = json.decode(upcomingResponse.body);
          setState(() {
            _upcomingEvents = (upcomingData['data'] as List)
                .map((json) => Registration.fromJson(json))
                .toList();
            _pastEvents = []; // Clear past events when in upcoming tab
          });
        } else if (upcomingResponse.statusCode != 404) {
          _handleHttpError(upcomingResponse.statusCode, 200);
          return false;
        }
      }
      // Past Events Tab
      else {
        final pastUrl = _buildUrl(
          path: '/registration',
          params: {
            'user_id': userData.userId,
            if (_showHasPresent) 'has_present': 'true',
            if (search.isNotEmpty) 'search': search,
          },
        );

        final pastResponse =
            await http.get(Uri.parse(pastUrl), headers: headers);

        if (pastResponse.statusCode == 200) {
          final pastData = json.decode(pastResponse.body);
          setState(() {
            _pastEvents = (pastData['data'] as List)
                .map((json) => Registration.fromJson(json))
                .toList();
            _upcomingEvents = []; // Clear upcoming events when in past tab
          });
          // Filter events yang sudah berakhir
          // setState(() {
          //   _pastEvents = (pastData['data'] as List)
          //       .map((json) => Registration.fromJson(json))
          //       .where((event) {
          //     DateTime endDate = DateTime.parse(event.dateEnd);
          //     return endDate.isBefore(DateTime.now());
          //   }).toList();
          // });
        } else if (pastResponse.statusCode != 404) {
          _handleHttpError(200, pastResponse.statusCode);
          return false;
        }
      }

      setState(() {
        _isLoading = false;
        _retryCount = 0;
      });

      return true;
    } catch (e) {
      _handleFetchError(e);
      return false;
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  String _buildUrl({
    required String path,
    Map<String, dynamic>? params,
  }) {
    // Gunakan baseUrl yang diberikan atau default
    const effectiveBaseUrl = prodApiBaseUrl;

    // Bangun query parameters
    final queryParams = params?.entries
        .map((entry) =>
            '${entry.key}=${Uri.encodeComponent(entry.value.toString())}')
        .join('&');

    // Gabungkan URL
    return queryParams != null
        ? '$effectiveBaseUrl$path?$queryParams'
        : '$effectiveBaseUrl$path';
  }

  void _handleHttpError(int upcomingStatusCode, int pastStatusCode) {
    debugPrint(
        'HTTP Error - Upcoming: $upcomingStatusCode, Past: $pastStatusCode');

    String errorMessage = 'Terjadi kesalahan';

    // Tangani berbagai status code
    if (upcomingStatusCode == 401 || pastStatusCode == 401) {
      errorMessage = 'Sesi Anda telah berakhir. Silakan login ulang.';
      // Logout user atau refresh token
      _forceLogout();
    } else if (upcomingStatusCode == 403 || pastStatusCode == 403) {
      errorMessage = 'Anda tidak memiliki akses';
    } else if (upcomingStatusCode == 404 || pastStatusCode == 404) {
      errorMessage = 'Sumber data tidak ditemukan';
    } else if (upcomingStatusCode >= 500 || pastStatusCode >= 500) {
      errorMessage = 'Kesalahan server. Silakan coba lagi nanti.';
    }

    setState(() {
      _errorMessage = errorMessage;
      _isLoading = false;
    });
  }

  void _handleFetchError(dynamic error) {
    debugPrint('Event History Fetch Error: $error');

    setState(() {
      _errorMessage = _getErrorMessage(error);
      _isLoading = false;
    });

    // Retry mechanism
    if (_retryCount < _maxRetries) {
      _retryCount++;
      debugPrint('Retry attempt: $_retryCount');
      Future.delayed(Duration(seconds: 2 * _retryCount), () {
        _checkConnectivityAndFetchEvents();
      });
    } else {
      debugPrint('Max retries reached. Stopping retry attempts.');
    }
  }

  String _getErrorMessage(dynamic error) {
    debugPrint('Error Type: ${error.runtimeType}');

    if (error is TimeoutException) {
      return 'Koneksi timeout. Periksa koneksi internet Anda.';
    } else if (error is SocketException) {
      return 'Tidak ada koneksi internet. Silakan periksa jaringan Anda.';
    } else if (error is http.ClientException) {
      return 'Gagal terhubung ke server. Periksa koneksi internet.';
    } else {
      return 'Terjadi kesalahan: ${error.toString()}';
    }
  }

  void _forceLogout() async {
    // Implementasi logout
    await AuthService().logout(context);

    // Navigasi ke halaman login
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(
              Icons.filter_list,
              color: Colors.black,
            ),
            onPressed: _showFilterModal,
          ),
          const SizedBox(width: 8), // Tambahkan margin kanan
        ],
        automaticallyImplyLeading: false, // Hapus tombol back
        centerTitle: true,
        backgroundColor:
            UIColor.solidWhite, // Sesuaikan dengan warna di kode asli
        title: const Text(
          "Tiket Saya",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color:
                UIColor.typoBlack, // Sesuaikan dengan warna teks di kode asli
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: UIColor.primaryColor, // Warna tab yang aktif
          unselectedLabelColor: UIColor.typoGray, // Warna tab yang tidak aktif
          indicatorColor: UIColor.primaryColor, // Warna garis indikator
          tabs: const [
            Tab(text: 'Akan Hadir'),
            Tab(text: 'Telah Hadir'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _checkConnectivityAndFetchEvents(),
        child: Column(
          children: [
            // Search Bar dengan desain yang mirip kode asli
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari tiket',
                  hintStyle:
                      const TextStyle(color: UIColor.typoGray, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: UIColor.typoGray),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  // enabledBorder: OutlineInputBorder(
                  //   borderRadius: BorderRadius.circular(10),
                  //   // borderSide: const BorderSide(color: UIColor.typoGray),
                  // ),
                  // focusedBorder: OutlineInputBorder(
                  //   borderRadius: BorderRadius.circular(10),
                  //   // borderSide: const BorderSide(color: UIColor.primaryColor),
                  // ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon:
                              const Icon(Icons.clear, color: UIColor.typoGray),
                          onPressed: () {
                            _searchController.clear();
                            _checkConnectivityAndFetchEvents(); // Reset pencarian
                          },
                        )
                      : null,
                ),
                style: const TextStyle(color: UIColor.typoBlack),
                onChanged: (value) {
                  // Debounce pencarian
                  Future.delayed(const Duration(milliseconds: 500), () {
                    _checkConnectivityAndFetchEvents(search: value);
                  });
                },
              ),
            ),

            //

            // Sisanya tetap sama seperti sebelumnya
            if (_isLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_errorMessage.isNotEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 60),
                      const SizedBox(height: 16),
                      Text(
                        'Error: $_errorMessage',
                        style: const TextStyle(color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: UIColor.primaryColor,
                        ),
                        onPressed: () => _checkConnectivityAndFetchEvents(),
                        child: const Text(
                          'Coba Lagi',
                          style: TextStyle(color: UIColor.white),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildEventList(_upcomingEvents, isUpcoming: true),
                    _buildEventList(_pastEvents, isUpcoming: false),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          FilterChip(
            label: const Text('Belum Hadir'),
            selected: _showNotPresent,
            onSelected: (bool selected) {
              setState(() {
                _showNotPresent = selected;
              });
              _checkConnectivityAndFetchEvents();
            },
            selectedColor: UIColor.primaryColor.withOpacity(0.2),
            checkmarkColor: UIColor.primaryColor,
            labelStyle: TextStyle(
              color: _showNotPresent ? UIColor.primaryColor : UIColor.typoGray,
            ),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Sudah Hadir'),
            selected: _showHasPresent,
            onSelected: (bool selected) {
              setState(() {
                _showHasPresent = selected;
              });
              _checkConnectivityAndFetchEvents();
            },
            selectedColor: UIColor.primaryColor.withOpacity(0.2),
            checkmarkColor: UIColor.primaryColor,
            labelStyle: TextStyle(
              color: _showHasPresent ? UIColor.primaryColor : UIColor.typoGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventList(List<Registration> events, {bool isUpcoming = true}) {
    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Image(
              image: AssetImage('assets/images/no-tickets.png'),
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 12),
            Text(
              isUpcoming
                  ? "Tidak Ada Tiket Akan Dihadiri"
                  : "Tidak Ada Tiket Telah Dihadiri",
              style: const TextStyle(
                color: UIColor.primaryColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48.0),
              child: Text(
                isUpcoming
                    ? "Anda belum memiliki tiket yang akan dihadiri. Jelajahi event menarik sekarang!"
                    : "Anda belum memiliki riwayat tiket event yang telah dihadiri.",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: UIColor.typoGray,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 20, bottom: 20),
      itemCount: events.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: _buildEventCard(events[index], isUpcoming),
        );
      },
    );
  }

  Widget _buildEventCard(Registration event, bool isUpcoming) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
              color: isUpcoming ? UIColor.primaryColor : Colors.grey, width: 6),
        ),
        color: UIColor.solidWhite,
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(6)),
                  child: Image.network(
                    event.poster,
                    height: 120,
                    width: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 120,
                        width: 90,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported),
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 8, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        '${event.categoryName}: ${event.title}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: UIColor.typoBlack,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      _buildInfoRow(UIconsPro.regularRounded.user_time,
                          '${event.quota} peserta'),
                      _buildInfoRow(
                          UIconsPro.regularRounded.house_building, event.place),
                      _buildInfoRow(
                          UIconsPro.regularRounded.marker, event.location),
                      _buildInfoRow(UIconsPro.regularRounded.calendar,
                          _formatEventDate(event)),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Buttons Section
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _navigateToDetailScreen(event);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isUpcoming
                          ? UIColor.primaryColor
                          : UIColor.solidWhite,
                      foregroundColor: isUpcoming
                          ? UIColor.solidWhite
                          : UIColor.primaryColor,
                      side: const BorderSide(color: UIColor.primaryColor),
                    ),
                    child: const Text("Lihat Detail"),
                  ),
                ),
                if (!isUpcoming) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _showcommentDialog(event);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: UIColor.primaryColor,
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: UIColor.primaryColor),
                      ),
                      child: const Text("Beri Ulasan"),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, color: UIColor.primaryColor, size: 12),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: UIColor.typoBlack,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatEventDate(Registration event) {
    final startDate = DateTime.parse(event.dateStart);
    final endDate = DateTime.parse(event.dateEnd);

    final formatter = DateFormat('dd MMM yyyy');
    return '${formatter.format(startDate)} - ${formatter.format(endDate)}';
  }

  // Fungsi navigasi di dalam EventHistoryPage
  void _navigateToDetailScreen(Registration event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TicketDetailPage(registration: event),
      ),
    );
  }

  void _showcommentDialog(Registration event) {
    // int _rating = 0;
    final TextEditingController commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      backgroundColor: Colors.white,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Judul dan Close Button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Beri Ulasan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: UIColor.primaryColor,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              // Nama Event
              Text(
                event.title,
                style: const TextStyle(
                  fontSize: 20,
                  color: UIColor.typoBlack,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),

              // const SizedBox(height: 20),

              // // Rating Bintang
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: List.generate(5, (index) {
              //     return GestureDetector(
              //       onTap: () {
              //         setState(() {
              //           _rating = index + 1;
              //         });
              //       },
              //       child: Padding(
              //         padding: const EdgeInsets.symmetric(horizontal: 4),
              //         child: Icon(
              //           index < _rating ? Icons.star : Icons.star_border,
              //           color: UIColor.primaryColor,
              //           size: 40,
              //         ),
              //       ),
              //     );
              //   }),
              // ),

              const SizedBox(height: 20),

              // Input Ulasan
              TextField(
                controller: commentController,
                decoration: InputDecoration(
                  hintText: 'Ceritakan pengalaman Anda mengikuti event',
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: UIColor.primaryColor.withOpacity(0.5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: UIColor.primaryColor,
                      width: 2,
                    ),
                  ),
                ),
                maxLines: 4,
                cursorColor: UIColor.primaryColor,
              ),

              const SizedBox(height: 20),

              // Tombol Kirim
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Validasi input
                    final comment = commentController.text.trim();

                    // if (_rating == 0) {
                    //   ScaffoldMessenger.of(context).showSnackBar(
                    //     const SnackBar(
                    //       content: Text('Silakan pilih rating'),
                    //       backgroundColor: Colors.red,
                    //     ),
                    //   );
                    //   return;
                    // }

                    if (comment.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ulasan tidak boleh kosong'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // Proses penyimpanan ulasan
                    _saveComment(event, comment);

                    // Tutup bottom sheet
                    Navigator.pop(context);

                    // Tampilkan konfirmasi
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Ulasan berhasil disimpan'),
                        backgroundColor: UIColor.primaryColor,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: UIColor.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: const Text(
                    'Kirim Ulasan',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: UIColor.solidWhite),
                  ),
                ),
              ),

              // Tambahkan padding bottom
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

// Ubah nama fungsi dan parameter
  Future<void> _saveComment(Registration event, String comment) async {
    try {
      final CommentService commentService = CommentService();

      // Panggil method createComment dari CommentService
      final newComment = await commentService.createComment(
        eventId: event.eventId, // Pastikan Registration model memiliki eventId
        content: comment,
      );

      if (newComment != null) {
        debugPrint('Komentar berhasil disimpan untuk event: ${event.title}');
        debugPrint('Komentar: $comment');
        debugPrint('ID Komentar: ${newComment.commentId}');
      } else {
        debugPrint('Gagal menyimpan komentar');

        // Tampilkan pesan error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyimpan komentar'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saat menyimpan komentar: $e');

      // Tampilkan pesan error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan komentar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  bool get wantKeepAlive => true;
}
