import 'package:polivent_app/models/search_events.dart';
import 'package:polivent_app/models/ui_colors.dart';
import 'package:intl/intl.dart';
import 'package:uicons_pro/uicons_pro.dart';
import 'package:flutter/material.dart';

class HomeTicket extends StatefulWidget {
  const HomeTicket({super.key});

  @override
  State<HomeTicket> createState() => _HomeTicketState();
}

class _HomeTicketState extends State<HomeTicket> {
  late List<Events> _events;

  @override
  void initState() {
    super.initState();
    _events = getEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      AppBar(
        automaticallyImplyLeading: false, // remove leading(left) back icon
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
      ),
      Expanded(
          child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: SearchEventsWidget(),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: _events.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: _buildEventCard(_events[index]),
                );
              },
            ),
          ),
        ],
      ))
    ]);
  }

  Widget _buildEventCard(Events event) {
    // Color statusColor;
    // //! COLORING STATUS BADGE
    // if (event.status == "Available") {
    //   statusColor = UIColor.secondaryColor;
    // } else if (event.status == "Full") {
    //   statusColor = UIColor.rejected;
    // } else {
    //   statusColor = UIColor.close;
    // }
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: UIColor.solidWhite,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              child: Image.network(
                event.posterUrl,
                // height: (MediaQuery.of(context).size.width / 3),
                // width: (MediaQuery.of(context).size.width / 4),
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
                  // const SizedBox(height: 8),
                  // Container(
                  //   decoration: BoxDecoration(
                  //     color: statusColor,
                  //     borderRadius: BorderRadius.circular(4),
                  //   ),
                  //   padding:
                  //       const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                  //   child: Text(
                  //     event.status,
                  //     style: const TextStyle(
                  //       color: UIColor.solidWhite,
                  //       fontSize: 10,
                  //       fontWeight: FontWeight.w400,
                  //     ),
                  //   ),
                  // ),
                  // const SizedBox(height: 8),
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
  return events;
}
