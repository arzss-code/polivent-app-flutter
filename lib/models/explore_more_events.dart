import 'package:polivent_app/models/ui_colors.dart';
import 'package:intl/intl.dart';
import 'package:uicons_pro/uicons_pro.dart';
import 'package:flutter/material.dart';

class EventList extends StatefulWidget {
  const EventList({super.key});

  @override
  State<EventList> createState() => _EventListWidgetState();
}

class _EventListWidgetState extends State<EventList> {
  List<EventsMore> _eventsMore = [];

  @override
  void initState() {
    super.initState();
    _eventsMore = getEventsMore();
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            // Wrap will automatically adjust the children horizontally and vertically
            spacing: 10,
            runSpacing: 10,
            children: List.generate(_eventsMore.length, (index) {
              //! COLORING STATUS BADGE
              if (_eventsMore[index].status == "Open") {
                statusColor = UIColor.solidWhite;
              } else {
                statusColor = UIColor.close;
              }

              return Container(
                width: (MediaQuery.of(context).size.width - 44) /
                    2, // Adaptive width for two columns
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: UIColor.solidWhite,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Align contents to the start
                  children: [
                    //! Section Tittle
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child:
                              // Image.asset('assets/background.png',
                              Image.network(
                            _eventsMore[index].posterUrl,
                            height: (MediaQuery.of(context).size.width - 44) /
                                3, // Adjust image size
                            width: double.infinity,
                            alignment: Alignment.topCenter,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    //! Content
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // const SizedBox(height: 0),
                          // Container(
                          //   // decoration: BoxDecoration(
                          //   //   color: statusColor,
                          //   //   borderRadius: BorderRadius.circular(24),
                          //   // ),
                          //   // padding: const EdgeInsets.symmetric(
                          //   //     vertical: 2, horizontal: 10),
                          //   child: Text(
                          //     _eventsMore[index].status,
                          //     style: const TextStyle(
                          //       color: UIColor.solidWhite,
                          //       fontSize: 10,
                          //       fontWeight: FontWeight.w400,
                          //     ),
                          //   ),
                          // ),
                          // const SizedBox(height: 4),
                          Text(
                            '${_eventsMore[index].category} : ${_eventsMore[index].tittle}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: UIColor.typoBlack,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                UIconsPro.regularRounded.user_time,
                                color: UIColor.typoGray,
                                size: 12,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${_eventsMore[index].quota} participants',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: UIColor.typoBlack,
                                ),
                              )
                            ],
                          ),
                          // const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                UIconsPro.regularRounded.house_building,
                                color: UIColor.typoGray,
                                size: 12,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _eventsMore[index].place,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: UIColor.typoBlack,
                                ),
                              )
                            ],
                          ),
                          // const SizedBox(height: 4),
                          // Row(
                          //   children: [
                          //     Icon(
                          //       UIconsPro.regularRounded.marker,
                          //       color: UIColor.typoGray,
                          //       size: 12,
                          //     ),
                          //     const SizedBox(width: 4),
                          //     Text(
                          //       _eventsMore[index].location,
                          //       style: const TextStyle(
                          //         fontSize: 12,
                          //         fontWeight: FontWeight.w400,
                          //         color: UIColor.typoBlack,
                          //       ),
                          //     )
                          //   ],
                          // ),
                          // const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                UIconsPro.regularRounded.calendar,
                                color: UIColor.typoGray,
                                size: 12,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _eventsMore[index].dateStart,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: UIColor.typoBlack,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              );
            }),
          ),
        ),
        const SizedBox(
          height: 12,
        ),
      ],
    );
  }
}

class EventsMore {
  String tittle;
  String category;
  String quota;
  String posterUrl;
  String place;
  String location;
  String dateStart;
  String status;

  EventsMore({
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

List<EventsMore> getEventsMore() {
  DateTime now = DateTime.now();
  List<EventsMore> events = [];

  events.add(EventsMore(
    tittle: 'Techcomfest',
    category: 'Seminar',
    quota: '200',
    posterUrl: "https://i.ibb.co.com/pW4RQff/poster-techomfest.jpg",
    place: "GKT Lt. 2",
    location: "Semarang, Indonesia",
    dateStart: DateFormat('E, d MMM yyy').format(now),
    status: "Open",
  ));
  events.add(EventsMore(
    tittle: 'AI For Technology ',
    category: 'Seminar',
    quota: '120',
    posterUrl: "https://i.ibb.co.com/pW4RQff/poster-techomfest.jpg",
    place: "GKT I",
    location: "Semarang, Indonesia",
    dateStart: DateFormat('E, d MMM yyy').format(now),
    status: "Available",
  ));
  events.add(EventsMore(
    tittle: 'Seminar Nasional Techcomfest',
    category: 'Seminar',
    quota: '200',
    posterUrl: "https://i.ibb.co.com/pW4RQff/poster-techomfest.jpg",
    place: "GKT Lt. 2",
    location: "Semarang, Indonesia",
    dateStart: DateFormat('E, d MMM yyy').format(now),
    status: "Full",
  ));
  events.add(EventsMore(
    tittle: 'Seminar Nasional Techcomfest',
    category: 'Seminar',
    quota: '200',
    posterUrl: "https://i.ibb.co.com/pW4RQff/poster-techomfest.jpg",
    place: "GKT Lt. 2",
    location: "Semarang, Indonesia",
    dateStart: DateFormat('E, d MMM yyy').format(now),
    status: "Close",
  ));
  events.add(EventsMore(
    tittle: 'Seminar Nasional Techcomfest',
    category: 'Seminar',
    quota: '200',
    posterUrl: "https://i.ibb.co.com/pW4RQff/poster-techomfest.jpg",
    place: "GKT Lt. 2",
    location: "Semarang, Indonesia",
    dateStart: DateFormat('E, d MMM yyy').format(now),
    status: "Full",
  ));
  events.add(EventsMore(
    tittle: 'Electro Fest',
    category: 'Expo',
    quota: '100',
    posterUrl: "https://i.ibb.co.com/pW4RQff/poster-techomfest.jpg",
    place: "GKT I",
    location: "Semarang, Indonesia",
    dateStart: DateFormat('E, d MMM yyy').format(now),
    status: "Available",
  ));
  return events;
}
