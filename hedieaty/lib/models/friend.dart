import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';
import '../controllers/event_controller.dart';
import '../init_database.dart';
import 'event.dart';

class Friend {
  final int? id;
  final int userId1;
  final int userId2;
  final String name;
  final String picture;
  final int upcomingEvents;
  final List<Event> events;

  Friend({
    required this.id,
    required this.userId1,
    required this.userId2,
    required this.name,
    required this.picture,
    required this.upcomingEvents,
    required this.events,
  });

  factory Friend.fromMap(Map<String, dynamic> map) {
    return Friend(
      id: map['id'],
      userId1: map['userId1'],
      userId2: map['userId2'],
      name: map['name'],
      picture: map['picture'],
      upcomingEvents: map['upcomingEvents'],
      events: [], // events will be populated separately
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId1': userId1,
      'userId2': userId2,
      'name': name,
      'picture': picture,
      'upcomingEvents': upcomingEvents,
    };
  }
}

/// FriendService ///
class FriendService {
  static final FriendService _instance = FriendService._internal();

  factory FriendService() => _instance;

  FriendService._internal();

  Future<Database> get database async {
    return await DatabaseInitializer().database;
  }

  Future<void> insertFriendLocal(Friend friend) async {
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

  Future<void> insertFriendFirestore(Friend friend) async {
    await FirebaseFirestore.instance.collection('friends').add(friend.toMap());
  }

  Future<bool> _friendshipExistsLocal(int userId1, int userId2) async {
    final db = await database;
    final List<Map<String, dynamic>> friendMaps = await db.query(
      'friends',
      where: '(userId1 = ? AND userId2 = ?) OR (userId1 = ? AND userId2 = ?)',
      whereArgs: [userId1, userId2, userId2, userId1],
    );

    return friendMaps.isNotEmpty;
  }

  Future<bool> _friendshipExistsFirestore(int userId1, int userId2) async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('friends')
        .where('userId1', isEqualTo: userId1)
        .where('userId2', isEqualTo: userId2)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      return true;
    }
    return false;
  }

  Future<String> _getUserProfileImage(int userId) async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('id', isEqualTo: userId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      var docSnapshot = querySnapshot.docs.first;
      var userData = docSnapshot.data();
      return userData['profileImageBase64'] ??
          'assets/images/profile-default.png';
    }

    return 'assets/images/profile-default.png';
  }

  Future<void> addMutualFriendsLocal(
      int userId1, int userId2, String userName1, String userName2) async {
    if (await _friendshipExistsLocal(userId1, userId2)) {
      return;
    }

    String userProfileImage2 = await _getUserProfileImage(userId2);

    Friend friend1 = Friend(
      id: null,
      userId1: userId1,
      userId2: userId2,
      name: userName2,
      picture: userProfileImage2,
      upcomingEvents: 0,
      events: [],
    );

    await insertFriendLocal(friend1);
  }

  Future<void> addMutualFriendsFirestore(
      int userId1, int userId2, String userName1, String userName2) async {
    if (await _friendshipExistsFirestore(userId1, userId2)) {
      return;
    }

    String userProfileImage2 = await _getUserProfileImage(userId2);

    Friend friend1 = Friend(
      id: null,
      userId1: userId1,
      userId2: userId2,
      name: userName2,
      picture: userProfileImage2,
      upcomingEvents: 0,
      events: [],
    );

    await insertFriendFirestore(friend1);
  }

  Future<List<Friend>> friendsLocal(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> friendMaps = await db.query(
      'friends',
      where: 'userId1 = ? OR userId2 = ?',
      whereArgs: [userId, userId],
    );

    List<Friend> friends = [];

    for (var friendMap in friendMaps) {
      int friendUserId = friendMap['userId1'] == userId
          ? friendMap['userId2']
          : friendMap['userId1'];
      List<Event> friendEvents =
          await EventController().eventsLocal(userId: friendUserId);
      List<Event> upcomingEvents = friendEvents.where((event) {
        return event.status != "Past";
      }).toList();

      Friend friend = Friend(
        id: friendMap['id'] as int,
        userId1: friendMap['userId1'] as int,
        userId2: friendMap['userId2'] as int,
        name: friendMap['name'] as String,
        picture: friendMap['picture'] as String,
        upcomingEvents: upcomingEvents.length,
        events: friendEvents,
      );

      friends.add(friend);
    }

    return friends;
  }

  Future<List<Friend>> friendsFirestore(int userId) async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('friends')
        .where('userId1', isEqualTo: userId)
        .get();

    var querySnapshot2 = await FirebaseFirestore.instance
        .collection('friends')
        .where('userId2', isEqualTo: userId)
        .get();

    List<Friend> friends = [];

    for (var doc in querySnapshot.docs) {
      var data = doc.data();
      int friendUserId =
          data['userId1'] == userId ? data['userId2'] : data['userId1'];
      List<Event> friendEvents =
          await EventController().eventsFirestore(userId: friendUserId);

      List<Event> upcomingEvents = friendEvents.where((event) {
        return event.status != "Past";
      }).toList();

      friends.add(Friend(
        id: doc.id.hashCode,
        userId1: data['userId1'],
        userId2: data['userId2'],
        name: data['name'],
        picture: data['picture'],
        upcomingEvents: upcomingEvents.length,
        events: friendEvents,
      ));
    }

    for (var doc in querySnapshot2.docs) {
      var data = doc.data();
      int friendUserId =
          data['userId1'] == userId ? data['userId2'] : data['userId1'];
      List<Event> friendEvents =
          await EventController().eventsFirestore(userId: friendUserId);

      List<Event> upcomingEvents = friendEvents.where((event) {
        return event.status != "Past";
      }).toList();

      friends.add(Friend(
        id: doc.id.hashCode,
        userId1: data['userId1'],
        userId2: data['userId2'],
        name: data['name'],
        picture: data['picture'],
        upcomingEvents: upcomingEvents.length,
        events: friendEvents,
      ));
    }

    return friends;
  }

  Future<void> updateFriendLocal(Friend friend) async {
    final db = await database;
    await db.update(
      'friends',
      friend.toMap(),
      where: 'id = ?',
      whereArgs: [friend.id],
    );
  }

  Future<void> updateFriendFirestore(Friend friend) async {
    await FirebaseFirestore.instance
        .collection('friends')
        .doc(friend.id.toString())
        .update(friend.toMap());
  }

  Future<void> deleteFriendLocal(int id) async {
    final db = await database;
    await db.delete(
      'friends',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteFriendFirestore(int id) async {
    await FirebaseFirestore.instance
        .collection('friends')
        .doc(id.toString())
        .delete();
  }
}
