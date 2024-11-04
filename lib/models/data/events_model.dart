class Event {
  final int eventId;
  final String title;
  final String dateAdd;
  final int categoryId;
  final String descEvent;
  final String poster;
  final String location;
  final int quota;
  final String dateStart;
  final String dateEnd;

  Event({
    required this.eventId,
    required this.title,
    required this.dateAdd,
    required this.categoryId,
    required this.descEvent,
    required this.poster,
    required this.location,
    required this.quota,
    required this.dateStart,
    required this.dateEnd,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      eventId:
          json['event_id'] != null ? int.parse(json['event_id'].toString()) : 0,
      title: json['title']?.toString() ?? 'No Title',
      dateAdd: json['date_add']?.toString() ?? '',
      categoryId: json['category_id'] != null
          ? int.parse(json['category_id'].toString())
          : 0,
      descEvent: json['desc_event']?.toString() ?? '',
      poster: json['poster']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      quota: json['quota'] != null ? int.parse(json['quota'].toString()) : 0,
      dateStart: json['date_start']?.toString() ?? '',
      dateEnd: json['date_end']?.toString() ?? '',
    );
  }
}

// class Event {
//   final int eventId;
//   final String title;
//   final String dateAdd;
//   final int categoryId;
//   final String descEvent;
//   final String poster;
//   final String location;
//   final int quota;
//   final String dateStart;
//   final String dateEnd;

//   Event({
//     required this.eventId,
//     required this.title,
//     required this.dateAdd,
//     required this.categoryId,
//     required this.descEvent,
//     required this.poster,
//     required this.location,
//     required this.quota,
//     required this.dateStart,
//     required this.dateEnd,
//   });

//   factory Event.fromJson(Map<String, dynamic> json) {
//     return Event(
//       eventId: json['event_id'] ?? 0,
//       title: json['title'] ?? 'No Title',
//       dateAdd: json['date_add'] ?? '',
//       categoryId: json['category_id'] ?? 0,
//       descEvent: json['desc_event'] ?? '',
//       poster: json['poster'] ?? '',
//       location: json['location'] ?? '',
//       quota: json['quota'] ?? 0,
//       dateStart: json['date_start'] ?? '',
//       dateEnd: json['date_end'] ?? '',
//     );
//   }
// }