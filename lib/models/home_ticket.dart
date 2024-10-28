import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uicons_pro/uicons_pro.dart';
import 'package:polivent_app/models/ui_colors.dart';

class HomeTicket extends StatefulWidget {
  const HomeTicket({super.key});

  @override
  State<HomeTicket> createState() => _HomeTicketState();
}

class _HomeTicketState extends State<HomeTicket> {
  late List<Events> _events;
  late List<Events> _upcomingEvents;
  late List<Events> _completedEvents;

  @override
  void initState() {
    super.initState();
    _events = getEvents(); // Ambil semua event
    // Filter acara berdasarkan statusnya (Upcoming & Completed)
    _upcomingEvents =
        _events.where((event) => event.status == "Available").toList();
    _completedEvents =
        _events.where((event) => event.status != "Available").toList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // Remove back button
          centerTitle: true,
          backgroundColor: UIColor.solidWhite,
          scrolledUnderElevation: 0,
          title: const Text(
            "Ticket",
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
                  "Upcoming",
                  style: TextStyle(
                    fontSize: 16, // Ukuran teks
                    fontWeight: FontWeight.w500, // Berat huruf
                  ),
                ),
              ),
              Tab(
                child: Text(
                  "Completed",
                  style: TextStyle(
                    fontSize: 16, // Ukuran teks
                    fontWeight: FontWeight.w500, // Berat huruf
                  ),
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildEventList(_upcomingEvents), // Tab Upcoming Events
            _buildEventList(_completedEvents), // Tab Completed Events
          ],
        ),
      ),
    );
  }

  // Method untuk menampilkan list event
  Widget _buildEventList(List<Events> events) {
    if (events.isEmpty) {
      return const Center(
        child: Text(
          "No events available",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 20, bottom: 20),
      itemCount: events.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: _buildEventCard(events[index]),
        );
      },
    );
  }

  // Method untuk membuat kartu event
  Widget _buildEventCard(Events event) {
    // Tentukan warna berdasarkan status event
    Color borderColor = event.status == "Available"
        ? UIColor.primaryColor // Warna biru untuk "Available" (Upcoming)
        : Colors.grey; // Warna abu-abu untuk lainnya (Completed)

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(color: borderColor, width: 10), // Terapkan warna dinamis di sini
        ),
        color: UIColor.solidWhite,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(6)),
              child: Image.network(
                event.posterUrl,
                height: 120,
                width: 90,
                fit: BoxFit.cover,
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
                    '${event.category}: ${event.tittle}',
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
                      '${event.quota} participants'),
                  _buildInfoRow(
                      UIconsPro.regularRounded.house_building, event.place),
                  _buildInfoRow(
                      UIconsPro.regularRounded.marker, event.location),
                  _buildInfoRow(
                      UIconsPro.regularRounded.calendar, event.dateStart),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Method untuk membuat row informasi dengan ikon
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
}

class Events {
  String tittle;
  String category;
  String quota;
  String posterUrl;
  String place;
  String location;
  String dateStart;
  String status;

  Events({
    required this.tittle,
    required this.category,
    required this.quota,
    required this.posterUrl,
    required this.place,
    required this.location,
    required this.dateStart,
    required this.status,
  });
}

List<Events> getEvents() {
  DateTime now = DateTime.now();
  List<Events> events = [];

  events.add(Events(
    tittle: 'Techcom Fest 2027',
    category: 'Competition',
    quota: '12',
    posterUrl: "https://i.ibb.co.com/pW4RQff/poster-techomfest.jpg",
    place: "GKT II",
    location: "Semarang, Indonesia",
    dateStart: DateFormat('E, d MMM yyy').format(now),
    status: "Available",
  ));
  events.add(Events(
    tittle: 'AI For Technology ',
    category: 'Seminar',
    quota: '120',
    posterUrl: "https://i.ibb.co.com/pW4RQff/poster-techomfest.jpg",
    place: "GKT I",
    location: "Semarang, Indonesia",
    dateStart: DateFormat('E, d MMM yyy').format(now),
    status: "Available",
  ));
  events.add(Events(
    tittle: 'Electro Fest',
    category: 'Expo',
    quota: '100',
    posterUrl: "https://i.ibb.co.com/pW4RQff/poster-techomfest.jpg",
    place: "GKT I",
    location: "Semarang, Indonesia",
    dateStart: DateFormat('E, d MMM yyy').format(now),
    status: "Avaliable",
  ));
  events.add(Events(
    tittle: 'Electro Fest',
    category: 'Expo',
    quota: '100',
    posterUrl: "https://i.ibb.co.com/pW4RQff/poster-techomfest.jpg",
    place: "GKT I",
    location: "Semarang, Indonesia",
    dateStart: DateFormat('E, d MMM yyy').format(now),
    status: "Full",
  ));
  events.add(Events(
    tittle: 'Electro Fest',
    category: 'Expo',
    quota: '100',
    posterUrl: "https://i.ibb.co.com/pW4RQff/poster-techomfest.jpg",
    place: "GKT I",
    location: "Semarang, Indonesia",
    dateStart: DateFormat('E, d MMM yyy').format(now),
    status: "Full",
  ));
  events.add(Events(
    tittle: 'Electro Fest',
    category: 'Expo',
    quota: '100',
    posterUrl: "https://i.ibb.co.com/pW4RQff/poster-techomfest.jpg",
    place: "GKT I",
    location: "Semarang, Indonesia",
    dateStart: DateFormat('E, d MMM yyy').format(now),
    status: "Close",
  ));
  events.add(Events(
    tittle: 'Electro Fest',
    category: 'Expo',
    quota: '100',
    posterUrl: "https://i.ibb.co.com/pW4RQff/poster-techomfest.jpg",
    place: "GKT I",
    location: "Semarang, Indonesia",
    dateStart: DateFormat('E, d MMM yyy').format(now),
    status: "Close",
  ));
  events.add(Events(
    tittle: 'Electro Fest',
    category: 'Expo',
    quota: '100',
    posterUrl: "https://i.ibb.co.com/pW4RQff/poster-techomfest.jpg",
    place: "GKT I",
    location: "Semarang, Indonesia",
    dateStart: DateFormat('E, d MMM yyy').format(now),
    status: "Close",
  ));
  events.add(Events(
    tittle: 'Electro Fest',
    category: 'Expo',
    quota: '100',
    posterUrl: "https://i.ibb.co.com/pW4RQff/poster-techomfest.jpg",
    place: "GKT I",
    location: "Semarang, Indonesia",
    dateStart: DateFormat('E, d MMM yyy').format(now),
    status: "Available",
  ));
  events.add(Events(
    tittle: 'Electro Fest',
    category: 'Expo',
    quota: '100',
    posterUrl: "https://i.ibb.co.com/pW4RQff/poster-techomfest.jpg",
    place: "GKT I",
    location: "Semarang, Indonesia",
    dateStart: DateFormat('E, d MMM yyy').format(now),
    status: "Available",
  ));
  events.add(Events(
    tittle: 'Electro Fest',
    category: 'Expo',
    quota: '100',
    posterUrl: "https://i.ibb.co.com/pW4RQff/poster-techomfest.jpg",
    place: "GKT I",
    location: "Semarang, Indonesia",
    dateStart: DateFormat('E, d MMM yyy').format(now),
    status: "Close",
  ));

  events.add(Events(
    tittle: 'Electro Fest',
    category: 'Expo',
    quota: '100',
    posterUrl: "https://i.ibb.co.com/pW4RQff/poster-techomfest.jpg",
    place: "GKT I",
    location: "Semarang, Indonesia",
    dateStart: DateFormat('E, d MMM yyy').format(now),
    status: "Full",
  ));
  events.add(Events(
    tittle: 'Electro Fest',
    category: 'Expo',
    quota: '100',
    posterUrl: "https://i.ibb.co.com/pW4RQff/poster-techomfest.jpg",
    place: "GKT I",
    location: "Semarang, Indonesia",
    dateStart: DateFormat('E, d MMM yyy').format(now),
    status: "Close",
  ));
  events.add(Events(
    tittle: 'Techcom Fest 2027',
    category: 'Competition',
    quota: '12',
    posterUrl: "https://i.ibb.co.com/pW4RQff/poster-techomfest.jpg",
    place: "GKT II",
    location: "Semarang, Indonesia",
    dateStart: DateFormat('E, d MMM yyy').format(now),
    status: "Available",
  ));

  // Tambahkan beberapa event yang sudah "Completed"
  events.add(Events(
    tittle: 'AI For Technology',
    category: 'Seminar',
    quota: '120',
    posterUrl: "https://i.ibb.co.com/pW4RQff/poster-techomfest.jpg",
    place: "GKT I",
    location: "Semarang, Indonesia",
    dateStart: DateFormat('E, d MMM yyy')
        .format(now.subtract(const Duration(days: 30))),
    status: "Completed",
  ));
  return events;
}
