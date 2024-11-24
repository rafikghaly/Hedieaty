import 'event.dart';

class Friend {
  final int? id;
  final int userId1;
  final int userId2;
  final String name;
  final String picture;
  final int upcomingEvents;
  final List<Event> events;

  Friend({
    required this.id,
    required this.userId1,
    required this.userId2,
    required this.name,
    required this.picture,
    required this.upcomingEvents,
    required this.events,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId1': userId1,
      'userId2': userId2,
      'name': name,
      'picture': picture,
      'upcomingEvents': upcomingEvents,
    };
  }
}
