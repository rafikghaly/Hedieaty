import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';
import '../models/friend.dart';
import '../models/event.dart';
import '../init_database.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class Repository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Database> get database async {
    return await DatabaseInitializer().database;
  }

  Future<List<Friend>> fetchFriends(int userId) async {
    if (await _hasNetworkConnection()) {
      // Fetch from Firebase
      List<Friend> friends = [];
      QuerySnapshot snapshot = await _firestore.collection('friends').where('userId', isEqualTo: userId).get();
      for (var doc in snapshot.docs) {
        friends.add(Friend.fromMap(doc.data() as Map<String, dynamic>));
      }
      // Save to SQLite for offline access
      await _saveFriendsToLocalDatabase(friends);
      return friends;
    } else {
      // Fetch from SQLite
      return await _fetchFriendsFromLocalDatabase(userId);
    }
  }

  Future<void> _saveFriendsToLocalDatabase(List<Friend> friends) async {
    final db = await database;
    for (var friend in friends) {
      await db.insert('friends', friend.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<List<Friend>> _fetchFriendsFromLocalDatabase(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('friends', where: 'userId = ?', whereArgs: [userId]);
    return List.generate(maps.length, (i) => Friend.fromMap(maps[i]));
  }

  Future<bool> _hasNetworkConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

  Future<List<Event>> fetchEvents(int userId) async {
    if (await _hasNetworkConnection()) {
      // Fetch from Firebase
      List<Event> events = [];
      QuerySnapshot snapshot = await _firestore.collection('events').where('userId', isEqualTo: userId).get();
      for (var doc in snapshot.docs) {
        events.add(Event.fromMap(doc.data() as Map<String, dynamic>));
      }
      // Save to SQLite for offline access
      await _saveEventsToLocalDatabase(events);
      return events;
    } else {
      // Fetch from SQLite
      return await _fetchEventsFromLocalDatabase(userId);
    }
  }

  Future<void> _saveEventsToLocalDatabase(List<Event> events) async {
    final db = await database;
    for (var event in events) {
      await db.insert('events', event.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<List<Event>> _fetchEventsFromLocalDatabase(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('events', where: 'userId = ?', whereArgs: [userId]);
    return List.generate(maps.length, (i) => Event.fromMap(maps[i]));
  }
}
