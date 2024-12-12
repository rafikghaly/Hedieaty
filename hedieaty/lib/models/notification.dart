import 'package:cloud_firestore/cloud_firestore.dart';

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

/// NotificationService ///
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  /// Insert Operations ///
  Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
  }) async {
    String notificationId =
        FirebaseFirestore.instance.collection('notifications').doc().id;

    var notification = Notification(
      id: notificationId,
      userId: userId,
      title: title,
      message: message,
      timestamp: DateTime.now(),
    );

    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(notification.id)
        .set(notification.toMap());
  }

  /// Update Operations ///
  Future<void> updateNotification(String notificationId) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  /// Delete Operations ///
  Future<void> deleteNotification(String notificationId) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }

  /// Read Operations ///
  Stream<QuerySnapshot> getNotificationsStream(String userId) {
    return FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }
}
