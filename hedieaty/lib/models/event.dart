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
  
  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      status: map['status'],
      date: map['date'],
      location: map['location'],
      description: map['description'],
      userId: map['userId'],
      gifts: [], // gifts will be populated separately
    );
  }

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
