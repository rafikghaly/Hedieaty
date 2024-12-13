import 'package:flutter_test/flutter_test.dart';
import 'package:hedieaty/models/notification.dart';

void main() {
  group('Notification Model Tests', () {
    test('Notification model serialization to map', () {
      final notification = Notification(
        id: '1',
        userId: 'user_123',
        title: 'Test Notification',
        message: 'This is a test notification',
        isRead: true,
        timestamp: DateTime.parse('2023-01-01T00:00:00.000Z'),
      );

      final notificationMap = notification.toMap();

      expect(notificationMap['id'], '1');
      expect(notificationMap['userId'], 'user_123');
      expect(notificationMap['title'], 'Test Notification');
      expect(notificationMap['message'], 'This is a test notification');
      expect(notificationMap['isRead'], true);
      expect(notificationMap['timestamp'], '2023-01-01T00:00:00.000Z');
    });

    test('Notification model deserialization from map', () {
      final map = {
        'id': '1',
        'userId': 'user_123',
        'title': 'Test Notification',
        'message': 'This is a test notification',
        'isRead': true,
        'timestamp': '2024-01-01T00:00:00.000Z',
      };

      final notification = Notification.fromMap(map);

      expect(notification.id, '1');
      expect(notification.userId, 'user_123');
      expect(notification.title, 'Test Notification');
      expect(notification.message, 'This is a test notification');
      expect(notification.isRead, true);
      expect(notification.timestamp, DateTime.parse('2024-01-01T00:00:00.000Z'));
    });

    test('Notification model default isRead value', () {
      final notification = Notification(
        id: '2',
        userId: 'user_456',
        title: 'Another Test Notification',
        message: 'This is another test notification',
        timestamp: DateTime.parse('2024-01-01T00:00:00.000Z'),
      );

      expect(notification.isRead, false);
    });
  });
}
