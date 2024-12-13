import 'package:flutter_test/flutter_test.dart';
import 'package:hedieaty/models/event.dart';

void main() {
  group('Event Model Tests', () {
    test('Event model serialization to map', () {
      final event = Event(
        id: 1,
        docId: 'doc_123',
        name: 'Test Event',
        category: 'Birthday',
        status: 'Upcoming',
        date: '2023-01-01',
        location: 'Test Location',
        description: 'This is a test event',
        userId: 100,
        gifts: [],
      );

      final eventMap = event.toMap();

      expect(eventMap['id'], 1);
      expect(eventMap['docId'], 'doc_123');
      expect(eventMap['name'], 'Test Event');
      expect(eventMap['category'], 'Birthday');
      expect(eventMap['status'], 'Upcoming');
      expect(eventMap['date'], '2023-01-01');
      expect(eventMap['location'], 'Test Location');
      expect(eventMap['description'], 'This is a test event');
      expect(eventMap['userId'], 100);
    });

    test('Event model deserialization from map', () {
      final map = {
        'id': 1,
        'docId': 'doc_123',
        'name': 'Test Event',
        'category': 'Birthday',
        'status': 'Upcoming',
        'date': '2023-01-01',
        'location': 'Test Location',
        'description': 'This is a test event',
        'userId': 100,
      };

      final event = Event.fromMap(map);

      expect(event.id, 1);
      expect(event.docId, 'doc_123');
      expect(event.name, 'Test Event');
      expect(event.category, 'Birthday');
      expect(event.status, 'Upcoming');
      expect(event.date, '2023-01-01');
      expect(event.location, 'Test Location');
      expect(event.description, 'This is a test event');
      expect(event.userId, 100);
      expect(event.gifts, []);
    });

    test('Event model handles missing optional fields gracefully', () {
      final map = {
        'name': 'Another Event',
        'category': 'Conference',
        'status': 'Completed',
        'date': '2023-02-01',
        'location': 'Another Location',
        'description': 'This is another test event',
        'userId': 101,
      };

      final event = Event.fromMap(map);

      expect(event.id, null); // id should be null
      expect(event.docId, null); // docId should be null
      expect(event.name, 'Another Event');
      expect(event.category, 'Conference');
      expect(event.status, 'Completed');
      expect(event.date, '2023-02-01');
      expect(event.location, 'Another Location');
      expect(event.description, 'This is another test event');
      expect(event.userId, 101);
      expect(event.gifts, []);
    });
  });
}
