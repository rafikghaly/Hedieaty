import 'gift.dart';

class Event {
  final int? id;
  final String name;
  final String category;
  final String status;
  final String date;
  final String location;
  final String description;
  final int userId;
  final List<Gift> gifts;

  Event({
    this.id,
    required this.name,
    required this.category,
    required this.status,
    required this.date,
    required this.location,
    required this.description,
    required this.userId,
    required this.gifts,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'status': status,
      'date': date,
      'location': location,
      'description': description,
      'userId': userId,
    };
  }
}
