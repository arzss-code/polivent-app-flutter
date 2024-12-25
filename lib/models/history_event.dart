import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:polivent_app/config/app_config.dart';
import 'package:polivent_app/services/auth_services.dart';
import 'package:polivent_app/services/data/events_model.dart';
import 'package:polivent_app/models/ui_colors.dart';
// import 'package:uicons_pro/uicons_pro.dart';

class HomeTicket extends StatefulWidget {
  const HomeTicket({super.key});

  @override
  State<HomeTicket> createState() => _HomeTicketState();
}

class _HomeTicketState extends State<HomeTicket> {
  List<Event> _upcomingEvents = [];
  List<Event> _completedEvents = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchEventHistory();
  }

  Future<void> _fetchEventHistory() async {
    try {
      final authService = AuthService();
      final userData = await authService.getUserData();
      final accessToken = await _getAccessToken();

      final response = await http.get(
        Uri.parse('$prodApiBaseUrl/registration/user/${userData.userId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['status'] == 'success') {
          final List<dynamic> eventsData = jsonResponse['data'];

          setState(() {
            // Memisahkan event berdasarkan tanggal
            _upcomingEvents = eventsData
                .map((eventJson) => Event.fromJson(eventJson))
                .where((event) => _isUpcomingEvent(event.dateStart))
                .toList();

            _completedEvents = eventsData
                .map((eventJson) => Event.fromJson(eventJson))
                .where((event) => !_isUpcomingEvent(event.dateStart))
                .toList();

            _isLoading = false;
          });
        } else {
          throw Exception(jsonResponse['message'] ?? 'Gagal mengambil event');
        }
      } else if (response.statusCode == 404) {
        setState(() {
          _upcomingEvents = [];
          _completedEvents = [];
          _isLoading = false;
        });
      } else {
        throw Exception(
            'Gagal mengambil event. Status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      debugPrint('Error fetching events: $e');
    }
  }

  Future<String> _getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token') ?? '';
  }

  bool _isUpcomingEvent(String dateStart) {
    try {
      DateTime eventDate = DateTime.parse(dateStart);
      return eventDate.isAfter(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          backgroundColor: UIColor.solidWhite,
          scrolledUnderElevation: 0,
          title: const Text(
            "Tiket Saya",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: UIColor.typoBlack,
            ),
          ),
          bottom: const TabBar(
            labelColor: UIColor.primaryColor,
            unselectedLabelColor: UIColor.typoBlack,
            indicatorColor: UIColor.primaryColor,
            tabs: [
              Tab(
                child: Text(
                  "Akan Datang",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  "Selesai",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
                ? Center(child: Text('Error: $_errorMessage'))
                : TabBarView(
                    children: [
                      _buildTicketList(_upcomingEvents),
                      _buildTicketList(_completedEvents),
                    ],
                  ),
      ),
    );
  }

  Widget _buildTicketList(List<Event> tickets) {
    if (tickets.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage('assets/images/no-tickets.png'),
              width: 150,
              height: 150,
            ),
            SizedBox(height: 12),
            Text(
              "Tidak Ada Tiket",
              style: TextStyle(
                color: UIColor.primaryColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 48.0),
              child: Text(
                "Saat ini tidak ada tiket yang tersedia. Silakan periksa kembali nanti untuk pembaruan.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
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
      itemCount: tickets.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: _buildTicketCard(tickets[index]),
        );
      },
    );
  }

  Widget _buildTicketCard(Event ticket) {
    // Tentukan status tiket berdasarkan tanggal
    bool isUpcoming = _isUpcomingEvent(ticket.dateStart);
    Color borderColor = isUpcoming ? UIColor.primaryColor : Colors.grey;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(color: borderColor, width: 6),
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
                    ticket.poster,
                    height: 120,
                    width: 90,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 8, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticket.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Kategori: ${ticket.category}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Lokasi: ${ticket.location}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tanggal: ${_formatDate(ticket.dateStart)}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isUpcoming ? 'Akan Datang' : 'Selesai',
                  style: TextStyle(
                    color: isUpcoming ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () {
                    // Navigasi ke detail event
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => EventDetailScreen(eventId: ticket.eventId),
                    //   ),
                    // );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      return DateFormat('dd MMMM yyyy').format(dateTime);
    } catch (e) {
      return dateString;
    }
  }
}
