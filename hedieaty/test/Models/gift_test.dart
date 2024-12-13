import 'package:flutter_test/flutter_test.dart';
import 'package:hedieaty/models/gift.dart';

void main() {
  group('Gift Model Tests', () {
    test('Gift model serialization to map', () {
      final gift = Gift(
        id: 1,
        eventId: 10,
        name: 'Test Gift',
        description: 'This is a test gift',
        category: 'Toys',
        status: 'available',
        isPledged: false,
        imageUrl: 'image_url',
        price: 19.99,
        docId: 'doc_id',
        isPurchased: true,
      );

      final giftMap = gift.toMap();

      expect(giftMap['id'], 1);
      expect(giftMap['eventId'], 10);
      expect(giftMap['name'], 'Test Gift');
      expect(giftMap['description'], 'This is a test gift');
      expect(giftMap['category'], 'Toys');
      expect(giftMap['status'], 'available');
      expect(giftMap['isPledged'], 0); // false -> 0
      expect(giftMap['imageUrl'], 'image_url');
      expect(giftMap['price'], 19.99);
      expect(giftMap['docId'], 'doc_id');
      expect(giftMap['isPurchased'], 1); // true -> 1
    });

    test('Gift model deserialization from map', () {
      final map = {
        'id': 1,
        'eventId': 10,
        'name': 'Test Gift',
        'description': 'This is a test gift',
        'category': 'Toys',
        'status': 'available',
        'isPledged': 0, // false -> 0
        'imageUrl': 'image_url',
        'price': 19.99,
        'docId': 'doc_id',
        'isPurchased': 1, // true -> 1
      };

      final gift = Gift.fromMap(map);

      expect(gift.id, 1);
      expect(gift.eventId, 10);
      expect(gift.name, 'Test Gift');
      expect(gift.description, 'This is a test gift');
      expect(gift.category, 'Toys');
      expect(gift.status, 'available');
      expect(gift.isPledged, false);
      expect(gift.imageUrl, 'image_url');
      expect(gift.price, 19.99);
      expect(gift.docId, 'doc_id');
      expect(gift.isPurchased, true);
    });

  });
}
