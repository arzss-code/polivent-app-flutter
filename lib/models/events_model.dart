class Event {
  final int eventId;
  final String title;
  final String date;
  final int? categoryId;
  final String? descEvent;
  final String? poster;
  final String? location;
  final int? quota;
  final String? status;

  Event({
    required this.eventId,
    required this.title,
    required this.date,
    this.categoryId,
    this.descEvent,
    this.poster,
    this.location,
    this.quota,
    this.status,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      eventId: json['event_id'],
      title: json['title'],
      date: json['date_add'],
      categoryId: json['category_id'],
      descEvent: json['desc_event'],
      poster: json['poster'],
      location: json['location'],
      quota: json['quota'],
    );
  }
}
