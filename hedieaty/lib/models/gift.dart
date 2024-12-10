import 'package:cloud_firestore/cloud_firestore.dart';

class Gift {
  late int? id;
  final int eventId;
  final String name;
  final String description;
  final String category;
  String status;
  bool isPledged;
  final String? imageUrl;
  final double price;
  String? docId;
  bool isPurchased;

  Gift({
    this.id,
    required this.eventId,
    required this.name,
    required this.description,
    required this.category,
    required this.status,
    required this.isPledged,
    required this.imageUrl,
    required this.price,
    required this.docId,
    this.isPurchased = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventId': eventId,
      'name': name,
      'description': description,
      'category': category,
      'status': status,
      'isPledged': isPledged ? 1 : 0,
      'imageUrl': imageUrl,
      'price': price,
      'docId': docId,
      'isPurchased': isPurchased ? 1 : 0,
    };
  }

  factory Gift.fromMap(Map<String, dynamic> map) {
    return Gift(
      id: map['id'] as int?,
      eventId: map['eventId'] as int,
      name: map['name'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      status: map['status'] as String,
      isPledged: map['isPledged'] == 1,
      imageUrl: map['imageUrl'] as String?,
      price: map['price'] as double,
      docId: map['docId'] as String?,
      isPurchased: map['isPurchased'] == 1,
    );
  }

  // For real-time Listeners
  factory Gift.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Gift(
      id: data['id'],
      eventId: data['eventId'],
      name: data['name'],
      description: data['description'],
      category: data['category'],
      status: data['status'],
      isPledged: data['isPledged'] == 1,
      imageUrl: data['imageUrl'],
      price: data['price'],
      docId: doc.id,
      isPurchased: data['isPurchased'] == 1,
    );
  }
}
