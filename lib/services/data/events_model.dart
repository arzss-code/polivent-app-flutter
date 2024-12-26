class Event {
  final int eventId;
  final String title;
  final String dateAdd;
  final int categoryId;
  final String description; // Pastikan ini sesuai dengan key di JSON
  final String poster;
  final String location;
  final String place;
  final int quota;
  final String dateStart;
  final String dateEnd;
  final String? category;
  final String? proposeUser;
  final String? proposeUserAvatar;
  final String? status;
  final String? schedule;
  final String? updated;
  final String? adminUser;
  final String? note;
  final List<InvitedUser>? invitedUsers;
  final int totalLikes;

  const Event({
    required this.eventId,
    required this.title,
    required this.dateAdd,
    required this.categoryId,
    required this.description,
    required this.poster,
    required this.location,
    required this.place,
    required this.quota,
    required this.dateStart,
    required this.dateEnd,
    this.category,
    this.proposeUser,
    this.proposeUserAvatar,
    this.status,
    this.schedule,
    this.updated,
    this.adminUser,
    this.note,
    this.invitedUsers,
    required this.totalLikes,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      eventId: _parseIntSafely(json['event_id']),
      title: _parseStringSafely(json['title'], defaultValue: 'No Title'),
      dateAdd: _parseStringSafely(json['date_add']),
      categoryId: _parseIntSafely(json['category_id']),
      description: _parseStringSafely(
          json['desc_event'] ?? json['description']), // Tambahkan fallback
      poster: _parseStringSafely(json['poster']),
      location: _parseStringSafely(json['location']),
      place: _parseStringSafely(json['place']),
      quota: _parseIntSafely(json['quota']),
      dateStart: _parseStringSafely(json['date_start']),
      dateEnd: _parseStringSafely(json['date_end']),
      category: json['category']?.toString(),
      proposeUser: json['propose_user']?.toString(),
      proposeUserAvatar: json['propose_user_avatar']?.toString(),
      status: json['status']?.toString(),
      schedule: json['schedule']?.toString(),
      updated: json['updated']?.toString(),
      adminUser: json['admin_user']?.toString(),
      note: json['note']?.toString(),
      invitedUsers: json['invited_users'] != null
          ? (json['invited_users'] as List)
              .map((userJson) => InvitedUser.fromJson(userJson))
              .toList()
          : null,
      totalLikes: _parseIntSafely(json['total_likes']),
    );
  }

  // Tambahkan method toString untuk debugging
  @override
  String toString() {
    return 'Event(eventId: $eventId, title: $title, description: $description)';
  }

  // Metode pembantu untuk parsing aman
  static int _parseIntSafely(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    return int.tryParse(value.toString()) ?? defaultValue;
  }

  static String _parseStringSafely(dynamic value, {String defaultValue = ''}) {
    return value?.toString() ?? defaultValue;
  }
}

class InvitedUser {
  final String username;
  final String? avatar;

  const InvitedUser({
    required this.username,
    this.avatar,
  });

  factory InvitedUser.fromJson(Map<String, dynamic> json) {
    return InvitedUser(
      username: json['username']?.toString() ?? '',
      avatar: json['avatar']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'avatar': avatar,
    };
  }
}
