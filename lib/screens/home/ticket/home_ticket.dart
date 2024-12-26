import 'package:flutter/material.dart';
import 'package:uicons_pro/uicons_pro.dart';
import 'package:polivent_app/models/ui_colors.dart';
import 'package:intl/intl.dart';

class HomeTicket extends StatefulWidget {
  const HomeTicket({super.key});

  @override
  State<HomeTicket> createState() => _HomeTicketState();
}

class _HomeTicketState extends State<HomeTicket> {
  late List<Tickets> _tickets;
  late List<Tickets> _upcomingTickets;
  late List<Tickets> _completedTickets;

  @override
  void initState() {
    super.initState();
    _tickets = getTickets(); // Ambil semua tiket
    // Filter tiket berdasarkan statusnya (Akan Datang & Selesai)
    _upcomingTickets =
        _tickets.where((ticket) => ticket.status == "Available").toList();
    _completedTickets =
        _tickets.where((ticket) => ticket.status != "Available").toList();
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
        body: TabBarView(
          children: [
            _buildTicketList(_upcomingTickets), // Tab Tiket Akan Datang
            _buildTicketList(_completedTickets), // Tab Tiket Selesai
          ],
        ),
      ),
    );
  }

  Widget _buildTicketList(List<Tickets> tickets) {
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

  Widget _buildTicketCard(Tickets ticket) {
    Color borderColor =
        ticket.status == "Available" ? UIColor.primaryColor : Colors.grey;

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
                    ticket.posterUrl,
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
                        '${ticket.category}: ${ticket.tittle}',
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
                          '${ticket.quota} peserta'),
                      _buildInfoRow(UIconsPro.regularRounded.house_building,
                          ticket.place),
                      _buildInfoRow(
                          UIconsPro.regularRounded.marker, ticket.location),
                      _buildInfoRow(
                          UIconsPro.regularRounded.calendar, ticket.dateStart),
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
                // Conditional for "Available" ticket
                if (ticket.status == "Available")
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Implementasi view ticket
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: UIColor.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Lihat Tiket"),
                    ),
                  )
                else ...[
                  // View Ticket Button (for non-available tickets)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Implementasi view ticket
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: UIColor.primaryColor,
                        side: const BorderSide(color: UIColor.primaryColor),
                      ),
                      child: const Text("Lihat Tiket"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Leave Review Button (only for completed tickets)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Implementasi leave review
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
}

class Tickets {
  String tittle;
  String category;
  String quota;
  String posterUrl;
  String place;
  String location;
  String dateStart;
  String status;

  Tickets({
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

List<Tickets> getTickets() {
  DateTime now = DateTime.now();
  List<Tickets> tickets = [];

  // DateFormat dateFormat = DateFormat('E, d MMM yyyy', 'id_ID');

  // 1. Techcom Fest 2027
  tickets.add(Tickets(
    tittle: 'Techcom Fest 2027',
    category: 'Kompetisi',
    quota: '200',
    posterUrl: "https://i.ibb.co.com/pW4RQff/poster-techomfest.jpg",
    place: "Gedung Prof Soedarto",
    location: "Semarang, Indonesia",
    dateStart:
        DateFormat('E, d MMM yyy').format(now.add(const Duration(days: 30))),
    status: "Available",
  ));

  // 2. Workshop UI/UX Design
  tickets.add(Tickets(
    tittle: 'Workshop UI/UX Design Fundamental',
    category: 'Workshop',
    quota: '50',
    posterUrl: "https://i.ibb.co.com/pW4RQff/poster-techomfest.jpg",
    place: "GKB III",
    location: "Semarang, Indonesia",
    dateStart:
        DateFormat('E, d MMM yyy').format(now.add(const Duration(days: 15))),
    status: "Available",
  ));

  // 3. Seminar Artificial Intelligence
  tickets.add(Tickets(
    tittle: 'Seminar AI: Masa Depan Teknologi',
    category: 'Seminar',
    quota: '300',
    posterUrl: "https://i.ibb.co.com/pW4RQff/poster-techomfest.jpg",
    place: "Auditorium Utama",
    location: "Semarang, Indonesia",
    dateStart:
        DateFormat('E, d MMM yyy').format(now.add(const Duration(days: 45))),
    status: "Available",
  ));

  // 4. Electro Fair 2024
  tickets.add(Tickets(
    tittle: 'Electro Fair 2024',
    category: 'Expo',
    quota: '500',
    posterUrl: "https://i.ibb.co.com/pW4RQff/poster-techomfest.jpg",
    place: "Lapangan Utama",
    location: "Semarang, Indonesia",
    dateStart: DateFormat('E, d MMM yyy')
        .format(now.subtract(const Duration(days: 10))),
    status: "Full",
  ));

  // 5. Web Development Bootcamp
  tickets.add(Tickets(
    tittle: 'Web Development Bootcamp',
    category: 'Workshop',
    quota: '75',
    posterUrl: "https://i.ibb.co.com/pW4RQff/poster-techomfest.jpg",
    place: "Lab Komputer Terpadu",
    location: "Semarang, Indonesia",
    dateStart: DateFormat('E, d MMM yyy')
        .format(now.subtract(const Duration(days: 20))),
    status: "Close",
  ));

  // 6. Startup Summit 2024
  tickets.add(Tickets(
    tittle: 'Startup Summit 2024',
    category: 'Seminar',
    quota: '250',
    posterUrl: "https://i.ibb.co.com/pW4RQff/poster-techomfest.jpg",
    place: "Convention Hall",
    location: "Semarang, Indonesia",
    dateStart: DateFormat('E, d MMM yyy')
        .format(now.subtract(const Duration(days: 5))),
    status: "Close",
  ));

  // 7. Mobile App Competition
  tickets.add(Tickets(
    tittle: 'Mobile App Innovation Challenge',
    category: 'Kompetisi',
    quota: '100',
    posterUrl: "https://i.ibb.co.com/pW4RQff/poster-techomfest.jpg",
    place: "Innovation Center",
    location: "Semarang, Indonesia",
    dateStart:
        DateFormat('E, d MMM yyy').format(now.add(const Duration(days: 60))),
    status: "Available",
  ));

  // 8. Data Science Workshop
  tickets.add(Tickets(
    tittle: 'Workshop Data Science & Analytics',
    category: 'Workshop',
    quota: '80',
    posterUrl: "https://i.ibb.co.com/pW4RQff/poster-techomfest.jpg",
    place: "GKB II",
    location: "Semarang, Indonesia",
    dateStart: DateFormat('E, d MMM yyy')
        .format(now.subtract(const Duration(days: 15))),
    status: "Close",
  ));

  // 9. Cyber Security Conference
  tickets.add(Tickets(
    tittle: 'Cyber Security Conference 2024',
    category: 'Konferensi',
    quota: '150',
    posterUrl: "https://i.ibb.co.com/pW4RQff/poster-techomfest.jpg",
    place: "Auditorium IT Center",
    location: "Semarang, Indonesia",
    dateStart:
        DateFormat('E, d MMM yyy').format(now.add(const Duration(days: 25))),
    status: "Available",
  ));

  // 10. IoT Exhibition
  tickets.add(Tickets(
    tittle: 'Internet of Things Exhibition',
    category: 'Expo',
    quota: '400',
    posterUrl: "https://i.ibb.co.com/pW4RQff/poster-techomfest.jpg",
    place: "Innovation Hub",
    location: "Semarang, Indonesia",
    dateStart: DateFormat('E, d MMM yyy')
        .format(now.subtract(const Duration(days: 8))),
    status: "Close",
  ));

  return tickets;
}
