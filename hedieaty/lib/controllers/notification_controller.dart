import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/notification.dart';

class NotificationController {
  static final NotificationController _instance =
  NotificationController._internal();
  final NotificationService _notificationService = NotificationService();

  factory NotificationController() => _instance;

  NotificationController._internal();

  Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
  }) async {
    await _notificationService.createNotification(
        userId: userId, title: title, message: message);
  }

  Future<void> updateNotification(String notificationId) async {
    await _notificationService.updateNotification(notificationId);
  }

  Stream<QuerySnapshot> getNotifications(String userId)  {
    return _notificationService.getNotificationsStream(userId);
  }

  Future<void> deleteNotification(String notificationId) async {
    await _notificationService.deleteNotification(notificationId);
  }
}
