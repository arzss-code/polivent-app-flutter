import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:polivent_app/models/ui_colors.dart';

import 'package:uicons_pro/uicons_pro.dart';
import 'package:intl/intl.dart';

class CarouselSection extends StatefulWidget {
  const CarouselSection({super.key});

  @override
  State<CarouselSection> createState() => _CarouselEventsState();
}

class _CarouselEventsState extends State<CarouselSection> {
  List<CarouselEventsModel> _eventsCarousel = [];

  @override
  void initState() {
    super.initState();
    _eventsCarousel = getEventsCarousel();
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //! Section Tittle
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Text(
            'Trending Events',
            textAlign: TextAlign.right,
            style: TextStyle(
                color: UIColor.typoBlack,
                fontSize: 16,
                fontWeight: FontWeight.w800),
          ),
        ),
        //! Carousel Content
        SizedBox(
          height: (MediaQuery.of(context).size.width - 40) / 1.66,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: _eventsCarousel.length,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20, right: 20),
            separatorBuilder: (context, index) => const SizedBox(
              width: 10,
            ),
            itemBuilder: (context, index) {
              //! COLORING STATUS BADGE
              if (_eventsCarousel[index].status == "Available") {
                statusColor = UIColor.secondaryColor;
              } else if (_eventsCarousel[index].status == "Full") {
                statusColor = UIColor.rejected;
              } else {
                statusColor = UIColor.close;
              }
              return Container(
                width: MediaQuery.of(context).size.width - 40,
                decoration: BoxDecoration(
                    color: UIColor.solidWhite,
                    image: DecorationImage(
                        // image: AssetImage('assets/image_welcome.png'),
                        image: NetworkImage(_eventsCarousel[index].posterUrl),
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter),
                    borderRadius: BorderRadius.circular(12)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: BackdropFilter(
                          blendMode: BlendMode.src,
                          //! menambahkan efek blur
                          filter: ImageFilter.blur(
                              sigmaX: 4,
                              sigmaY: 4,
                              tileMode: TileMode.repeated),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                            color: UIColor.bgCarousel.withOpacity(0.4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Icon(
                                          color: UIColor.solidWhite,
                                          UIconsPro.regularRounded.user,
                                          size: 12,
                                        ),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        Text(
                                          "${_eventsCarousel[index].quota} people",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            color: UIColor.solidWhite,
                                          ),
                                          textAlign: TextAlign.left,
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          color: UIColor.solidWhite,
                                          UIconsPro
                                              .regularRounded.house_building,
                                          size: 12,
                                        ),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        Text(_eventsCarousel[index].place,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                              color: UIColor.solidWhite,
                                            ))
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          color: UIColor.solidWhite,
                                          UIconsPro.regularRounded.marker,
                                          size: 12,
                                        ),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        Text(_eventsCarousel[index].location,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                              color: UIColor.solidWhite,
                                            ))
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          color: UIColor.solidWhite,
                                          UIconsPro.regularRounded.calendar,
                                          size: 12,
                                        ),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        Text(_eventsCarousel[index].dateStart,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                              color: UIColor.solidWhite,
                                            ))
                                      ],
                                    ),
                                  ],
                                ),
                                Column(children: [
                                  Container(
                                      width: 100,
                                      height: 30,
                                      decoration: BoxDecoration(
                                          color: statusColor,
                                          borderRadius:
                                              BorderRadius.circular(30)),
                                      child: Text(_eventsCarousel[index].status,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              color: UIColor.solidWhite,
                                              height: 2.5,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12)))
                                ])
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class CarouselEventsModel {
  String tittle;
  String quota;
  String posterUrl;
  String place;
  String location;
  String dateStart;
  String status;

  CarouselEventsModel({
    required this.tittle,
    required this.quota,
    required this.posterUrl,
    required this.place,
    required this.location,
    required this.dateStart,
    required this.status,
  });
}

List<CarouselEventsModel> getEventsCarousel() {
  DateTime now = DateTime.now();
  List<CarouselEventsModel> events = [];

  events.add(CarouselEventsModel(
    tittle: 'Seminar Nasional Techcomfest',
    quota: '200',
    posterUrl: "https://i.ibb.co.com/pW4RQff/poster-techomfest.jpg",
    place: "GKT Lt. 2",
    location: "Semarang, Indonesia",
    dateStart: DateFormat('E, d MMM yyy').format(now),
    status: "Available",
  ));
  events.add(CarouselEventsModel(
    tittle: 'Seminar Nasional Techcomfest',
    quota: '120',
    posterUrl: "https://i.ibb.co.com/pW4RQff/poster-techomfest.jpg",
    place: "GKT Lt. 2",
    location: "Semarang, Indonesia",
    dateStart: DateFormat('E, d MMM yyy').format(now),
    status: "Available",
  ));
  events.add(CarouselEventsModel(
    tittle: 'Seminar Nasional Techcomfest',
    quota: '200',
    posterUrl: "https://i.ibb.co.com/pW4RQff/poster-techomfest.jpg",
    place: "GKT Lt. 2",
    location: "Semarang, Indonesia",
    dateStart: DateFormat('E, d MMM yyy').format(now),
    status: "Full",
  ));
  events.add(CarouselEventsModel(
    tittle: 'Seminar Nasional Techcomfest',
    quota: '120',
    posterUrl: "https://i.ibb.co.com/pW4RQff/poster-techomfest.jpg",
    place: "GKT Lt. 2",
    location: "Semarang, Indonesia",
    dateStart: DateFormat('E, d MMM yyy').format(now),
    status: "Close",
  ));
  return events;
}
