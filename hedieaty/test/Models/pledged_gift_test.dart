import 'package:flutter_test/flutter_test.dart';
import 'package:hedieaty/models/pledged_gift.dart';

void main() {
  group('PledgedGift Model Tests', () {
    test('PledgedGift model serialization to map', () {
      final pledgedGift = PledgedGift(
        id: 1,
        docId: 'doc_123',
        eventId: 10,
        userId: 20,
        giftId: 30,
        friendName: 'Test Friend',
        dueDate: '2023-01-01',
      );

      final pledgedGiftMap = pledgedGift.toMap();

      expect(pledgedGiftMap['id'], 1);
      expect(pledgedGiftMap['docId'], 'doc_123');
      expect(pledgedGiftMap['eventId'], 10);
      expect(pledgedGiftMap['userId'], 20);
      expect(pledgedGiftMap['giftId'], 30);
      expect(pledgedGiftMap['friendName'], 'Test Friend');
      expect(pledgedGiftMap['dueDate'], '2023-01-01');
    });

    test('PledgedGift model deserialization from map', () {
      final map = {
        'id': 1,
        'docId': 'doc_123',
        'eventId': 10,
        'userId': 20,
        'giftId': 30,
        'friendName': 'Test Friend',
        'dueDate': '2023-01-01',
      };

      final pledgedGift = PledgedGift.fromMap(map);

      expect(pledgedGift.id, 1);
      expect(pledgedGift.docId, 'doc_123');
      expect(pledgedGift.eventId, 10);
      expect(pledgedGift.userId, 20);
      expect(pledgedGift.giftId, 30);
      expect(pledgedGift.friendName, 'Test Friend');
      expect(pledgedGift.dueDate, '2023-01-01');
    });

    test('PledgedGift model handles missing fields', () {
      final map = {
        'docId': 'doc_456',
        'eventId': 11,
        'userId': 21,
        'giftId': 31,
        'friendName': 'Another Friend',
        'dueDate': '2023-02-01',
      };

      final pledgedGift = PledgedGift.fromMap(map);

      expect(pledgedGift.id, null); // id should be null
      expect(pledgedGift.docId, 'doc_456');
      expect(pledgedGift.eventId, 11);
      expect(pledgedGift.userId, 21);
      expect(pledgedGift.giftId, 31);
      expect(pledgedGift.friendName, 'Another Friend');
      expect(pledgedGift.dueDate, '2023-02-01');
    });
  });
}
