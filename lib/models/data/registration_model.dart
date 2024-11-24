class Registration {
  final int eventId;
  final int userId;

  Registration({required this.eventId, required this.userId});

  Map<String, dynamic> toJson() {
    return {
      'event_id': eventId,
      'users_id': userId,
    };
  }
}
