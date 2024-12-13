import 'package:flutter_test/flutter_test.dart';
import 'package:hedieaty/models/friend.dart';

void main() {
  group('Friend Model Tests', () {
    test('Friend model serialization to map', () {
      final friend = Friend(
        id: 1,
        userId1: 100,
        userId2: 200,
        name: 'Test Friend',
        picture: 'test_picture_url',
        upcomingEvents: 3,
        events: [],
      );

      final friendMap = friend.toMap();

      expect(friendMap['id'], 1);
      expect(friendMap['userId1'], 100);
      expect(friendMap['userId2'], 200);
      expect(friendMap['name'], 'Test Friend');
      expect(friendMap['picture'], 'test_picture_url');
      expect(friendMap['upcomingEvents'], 3);
    });

    test('Friend model deserialization from map', () {
      final map = {
        'id': 1,
        'userId1': 100,
        'userId2': 200,
        'name': 'Test Friend',
        'picture': 'test_picture_url',
        'upcomingEvents': 3,
      };

      final friend = Friend.fromMap(map);

      expect(friend.id, 1);
      expect(friend.userId1, 100);
      expect(friend.userId2, 200);
      expect(friend.name, 'Test Friend');
      expect(friend.picture, 'test_picture_url');
      expect(friend.upcomingEvents, 3);
      expect(friend.events, []);
    });

    test('Friend model handles missing optional fields gracefully', () {
      final map = {
        'userId1': 101,
        'userId2': 201,
        'name': 'Another Friend',
        'picture': 'another_picture_url',
        'upcomingEvents': 5,
      };

      final friend = Friend.fromMap(map);

      expect(friend.id, null); // id should be null
      expect(friend.userId1, 101);
      expect(friend.userId2, 201);
      expect(friend.name, 'Another Friend');
      expect(friend.picture, 'another_picture_url');
      expect(friend.upcomingEvents, 5);
      expect(friend.events, []);
    });
  });
}
