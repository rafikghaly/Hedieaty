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
      friend.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Friend>> friends() async {
    final db = await database;
    final List<Map<String, dynamic>> friendMaps = await db.query('friends');

    List<Friend> friends = [];

    for (var friendMap in friendMaps) {
      int userId = friendMap['userId'];
      List<Event> friendEvents = await EventController().events(userId: userId);

      Friend friend = Friend(
        id: friendMap['id'],
        name: friendMap['name'],
        picture: friendMap['picture'],
        upcomingEvents: friendEvents.length,
        events: friendEvents,
        userId: userId,
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
