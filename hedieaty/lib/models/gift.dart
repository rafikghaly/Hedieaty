class Gift {
  final int id;  // New attribute for SQLite
  final String name;
  final String description;
  final String category;
  final String status;
  final bool isPledged;
  final String? imageUrl;
  final double price;
  final int eventId;

  Gift({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.status,
    required this.price,
    this.isPledged = false,
    this.imageUrl,
    required this.eventId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'status': status,
      'isPledged': isPledged ? 1 : 0,
      'imageUrl': imageUrl,
      'price': price,
      'eventId': eventId,
    };
  }
}
