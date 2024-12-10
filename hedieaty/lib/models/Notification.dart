class Notification {
  final String id;
  final String userId; // User to whom the notification is addressed
  final String title;
  final String message;
  final bool isRead;
  final DateTime timestamp;

  Notification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    this.isRead = false,
    required this.timestamp,
  });

  factory Notification.fromMap(Map<String, dynamic> map) {
    return Notification(
      id: map['id'],
      userId: map['userId'],
      title: map['title'],
      message: map['message'],
      isRead: map['isRead'] ?? false,
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'isRead': isRead,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
