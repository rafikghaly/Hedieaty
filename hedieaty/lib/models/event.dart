import 'gift.dart';

class Event {
  late int? id;
  final String name;
  final String category;
  final String status;
  final String date;
  final String location;
  final String description;
  final int userId;
  final List<Gift> gifts;
  String? docId;

  Event({
    this.id,
    required this.docId,
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
      docId: map['docId'],
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
      'docId': docId,
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
