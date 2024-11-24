import 'package:sqflite/sqflite.dart';
import '../models/friend.dart';
import '../models/event.dart';
import 'event_controller.dart';
import '../init_database.dart';

class FriendController {
  static final FriendController _instance = FriendController._internal();
  factory FriendController() => _instance;
  FriendController._internal();

  Future<Database> get database async {
    return await DatabaseInitializer().database;
  }

  Future<void> insertFriend(Friend friend) async {
    final db = await database;
    await db.insert(
      'friends',
      {
        'userId1': friend.userId1,
        'userId2': friend.userId2,
        'name': friend.name,
        'picture': friend.picture,
        'upcomingEvents': friend.upcomingEvents,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore, // To avoid duplicates
    );
  }

  Future<bool> _friendshipExists(int userId1, int userId2) async {
    final db = await database;
    final List<Map<String, dynamic>> friendMaps = await db.query(
      'friends',
      where: '(userId1 = ? AND userId2 = ?) OR (userId1 = ? AND userId2 = ?)',
      whereArgs: [userId1, userId2, userId2, userId1],
    );

    return friendMaps.isNotEmpty;
  }

  Future<void> addMutualFriends(int userId1, int userId2, String userName1, String userName2) async {
    // Check if the friendship already exists
    if (await _friendshipExists(userId1, userId2)) {
      // print('Friendship already exists between $userId1 and $userId2');
      return;
    }

    // Add a single entry for the friendship
    Friend friend = Friend(
      id: null, // Set to null to let the DB handle auto-increment
      userId1: userId1,
      userId2: userId2,
      name: userName2,
      picture: 'assets/images/default.jpg', // Assume a default picture
      upcomingEvents: 0,
      events: [],
    );
    await insertFriend(friend);
  }

  Future<List<Friend>> friends(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> friendMaps = await db.query(
      'friends',
      where: 'userId1 = ? OR userId2 = ?',
      whereArgs: [userId, userId],
    );

    List<Friend> friends = [];

    for (var friendMap in friendMaps) {
      int friendUserId = friendMap['userId1'] == userId ? friendMap['userId2'] : friendMap['userId1'];
      List<Event> friendEvents = await EventController().events(userId: friendUserId);

      Friend friend = Friend(
        id: friendMap['id'] as int,
        userId1: friendMap['userId1'] as int,
        userId2: friendMap['userId2'] as int,
        name: friendMap['name'] as String,
        picture: friendMap['picture'] as String,
        upcomingEvents: friendEvents.length,
        events: friendEvents,
      );

      friends.add(friend);
    }

    return friends;
  }

  Future<void> updateFriend(Friend friend) async {
    final db = await database;
    await db.update(
      'friends',
      friend.toMap(),
      where: 'id = ?',
      whereArgs: [friend.id],
    );
  }

  Future<void> deleteFriend(int id) async {
    final db = await database;
    await db.delete(
      'friends',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
