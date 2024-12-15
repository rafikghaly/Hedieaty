import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Request permissions for iOS
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Initialize local notifications for displaying notifications while the app is in foreground
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Set up foreground message handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showNotification(message);
    });

    // Handle background and terminated state messages
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle your background message
    });
  }

  static Future<void> _showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails('high_importance_channel', 'High Importance Channel',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false);

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  static Future<String?> getToken() async {
    String? token = await _firebaseMessaging.getToken();
    //print("FCM Token: $token");
    return token;
  }

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

    // Fetch FCM token for the user and send push notification
    var userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('id', isEqualTo: int.parse(userId))
        .get();

    if (userSnapshot.docs.isNotEmpty) {
      var userData = userSnapshot.docs.first.data();
      String? token = userData['fcmToken'];
      if (token != null) {
        await sendPushNotification(token, title, message);
      }
    }
  }


  Future<void> sendPushNotification(String token, String title, String body) async {
    var url = Uri.parse('https://script.google.com/macros/s/AKfycbwv2F7jDhKfKVN1V70nWLorbVUaIe0DIiSVAg4KMJ33g92ccz5kjty6eupCmeyb1gnykw/exec');

    try {
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token, 'title': title, 'body': body}),
      );

      if (response.statusCode == 200) {
        // print('Notification sent successfully.');
      } else {
        // print('Failed to send notification. Response: ${response.body}');
      }
    } catch (e) {
      // print('Error sending push notification: $e');
    }
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
