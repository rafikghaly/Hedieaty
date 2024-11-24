import 'event.dart';
class Friend {
  final int id;
  final int userId;
  final String name;
  final String picture;
  final int upcomingEvents;
  final List<Event> events;


  Friend({
    required this.id,
    required this.userId,
    required this.name,
    required this.picture,
    required this.upcomingEvents,
    required this.events,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'picture': picture,
      'upcomingEvents': upcomingEvents,
      'userId': userId,
    };
  }
}
