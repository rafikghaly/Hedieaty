class Gift {
  final int? id;
  final int eventId;
  final String name;
  final String description;
  final String category;
  String status;
  bool isPledged;
  final String? imageUrl;
  final double price;

  Gift({
    required this.id,
    required this.eventId,
    required this.name,
    required this.description,
    required this.category,
    required this.status,
    required this.isPledged,
    required this.imageUrl,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventId': eventId,
      'name': name,
      'description': description,
      'category': category,
      'status': status, // Now mutable
      'isPledged': isPledged ? 1 : 0,
      'imageUrl': imageUrl,
      'price': price,
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
    );
  }
}
