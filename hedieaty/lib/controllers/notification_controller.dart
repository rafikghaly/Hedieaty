import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/Notification.dart';

class NotificationController {
  void createNotification(
      {required String userId,
      required String title,
      required String message}) {
    String notificationId =
        FirebaseFirestore.instance.collection('notifications').doc().id;

    var notification = Notification(
      id: notificationId,
      userId: userId,
      title: title,
      message: message,
      timestamp: DateTime.now(),
    );

    FirebaseFirestore.instance
        .collection('notifications')
        .doc(notification.id)
        .set(notification.toMap());
  }

  Future<void> updateNotification(notificationId) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  Future<void> deleteNotification(notificationId) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }
}
