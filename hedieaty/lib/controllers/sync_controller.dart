import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hedieaty/init_database.dart';
import 'package:sqflite/sqflite.dart';

class SyncController {
  final DatabaseInitializer _databaseInitializer = DatabaseInitializer();

  Future<void> clearLocalDatabase() async {
    final db = await _databaseInitializer.database;
    await db.execute('DELETE FROM users');
    await db.execute('DELETE FROM friends');
    await db.execute('DELETE FROM events');
    await db.execute('DELETE FROM gifts');
    await db.execute('DELETE FROM pledged_gifts');
    await db.execute('DELETE FROM friend_local');
    // print('Cleared DB');
  }

  Future<Map<String, dynamic>> fetchUserDataFromFirebase(int userId) async {
    var userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('id', isEqualTo: userId)
        .get();
    var user = userSnapshot.docs.map((doc) => doc.data()).toList();

    // Fetch events associated with the user
    var eventsSnapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('userId', isEqualTo: userId)
        .get();
    var events = eventsSnapshot.docs.map((doc) => doc.data()).toList();
    // print('User events: $events');

    var eventIds = eventsSnapshot.docs.map((doc) => doc['id'] as int).toList();

    // Fetch gifts associated with the events
    List<Map<String, dynamic>> gifts = [];
    for (int eventId in eventIds) {
      var giftsSnapshot = await FirebaseFirestore.instance
          .collection('gifts')
          .where('eventId', isEqualTo: eventId)
          .get();
      gifts.addAll(giftsSnapshot.docs.map((doc) => doc.data()).toList());
    }

    // Fetch pledged gifts associated with the user
    var pledgedGiftsSnapshot = await FirebaseFirestore.instance
        .collection('pledged_gifts')
        .where('userId', isEqualTo: userId)
        .get();
    var pledgedGifts = pledgedGiftsSnapshot.docs.map((doc) => doc.data()).toList();

    // Fetch friends associated with the user
    var friendsSnapshot = await FirebaseFirestore.instance
        .collection('friends')
        .where('userId2', isEqualTo: userId)
        .get();
    var friends = friendsSnapshot.docs.map((doc) => doc.data()).toList();

    if (friends.isEmpty) {
      friendsSnapshot = await FirebaseFirestore.instance
          .collection('friends')
          .where('userId1', isEqualTo: userId)
          .get();
      friends = friendsSnapshot.docs.map((doc) => doc.data()).toList();
    }

    // Fetch friend user data
    List<Map<String, dynamic>> friendUsers = [];
    for (var friend in friends) {
      var friendUserSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('id', isEqualTo: friend['userId2'])
          .get();
      friendUsers.addAll(friendUserSnapshot.docs.map((doc) => doc.data()).toList());
    }

    // Fetch friends' events and gifts
    for (var friend in friends) {
      // Fetch events associated with the friend
      var friendEventsSnapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('userId', isEqualTo: friend['userId2'])
          .get();
      var friendEvents = friendEventsSnapshot.docs.map((doc) => doc.data()).toList();
      events.addAll(friendEvents);

      // Fetch event IDs for the friend's events
      var friendEventIds = friendEventsSnapshot.docs.map((doc) => doc['id'] as int).toList();

      // Fetch gifts associated with the friend's events
      for (int eventId in friendEventIds) {
        var friendGiftsSnapshot = await FirebaseFirestore.instance
            .collection('gifts')
            .where('eventId', isEqualTo: eventId)
            .get();
        var friendGifts = friendGiftsSnapshot.docs.map((doc) => doc.data()).toList();
        gifts.addAll(friendGifts);
      }
    }

    return {
      'user': user,
      'events': events,
      'gifts': gifts,
      'pledged_gifts': pledgedGifts,
      'friends': friends,
      'friendUsers': friendUsers,
    };
  }

  Future<void> insertDataIntoLocalDatabase(Map<String, dynamic> data) async {
    await clearLocalDatabase();
    final db = await _databaseInitializer.database;

    // Insert user data into local database
    for (var user in data['user']) {
      await db.insert('users', user, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // Insert friend user data into friend_local table
    for (var friendUser in data['friendUsers']) {
      await db.insert('friend_local', {
        'friendUserId': friendUser['id'],
        'name': friendUser['name'],
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // Insert events data into local database
    for (var event in data['events']) {
      await db.insert('events', event, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // Insert gifts data into local database
    for (var gift in data['gifts']) {
      await db.insert('gifts', gift, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // Insert pledged gifts data into local database
    for (var pledgedGift in data['pledged_gifts']) {
      await db.insert('pledged_gifts', pledgedGift, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // Insert friends data into local database
    for (var friend in data['friends']) {
      await db.insert('friends', friend, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<void> syncUserData(int userId) async {
    var data = await fetchUserDataFromFirebase(userId);
    await insertDataIntoLocalDatabase(data);
  }
}
