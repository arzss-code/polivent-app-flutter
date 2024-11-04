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
      eventId: json['event_id'],
      title: json['title'],
      dateAdd: json['date_add'],
      categoryId: json['category_id'],
      descEvent: json['desc_event'],
      poster: json['poster'],
      location: json['location'],
      quota: json['quota'],
      dateStart: json['date_start'],
      dateEnd: json['date_end'],
    );
  }
}