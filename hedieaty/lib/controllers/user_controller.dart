import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/user.dart';
import '../init_database.dart';
import 'event_controller.dart';

class UserController {
  static final UserController _instance = UserController._internal();

  factory UserController() => _instance;

  UserController._internal();

  Future<Database> get database async {
    return await DatabaseInitializer().database;
  }

  Future<void> insertUserLocal(User user) async {
    final db = await database;
    await db.insert(
      'users',
      user.toMap()..remove('id'), // Ensure id is not set manually
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }

  Future<void> insertUserFirestore(User user) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.firebaseUid)
        .set(user.toMap());
  }

  Future<User?> getUserByEmailLocal(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      final map = maps.first;
      return User.fromMap(map);
    } else {
      return null;
    }
  }

  Future<User?> getUserByEmailFirestore(String email) async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      var doc = querySnapshot.docs.first;
      return User.fromMap(doc.data());
    } else {
      return null;
    }
  }

  Future<User?> getUserByIdLocal(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      final map = maps.first;
      return User.fromMap(map);
    } else {
      return null;
    }
  }

  Future<String> getFriendNameByIdLocal(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'friend_local',
      columns: ['name'],
      where: 'friendUserId = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return maps.first['name'] as String;
    } else {
      return 'Unknown';
    }
  }

  Future<User?> getUserByIdFirestore(int id) async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('id', isEqualTo: id)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      var doc = querySnapshot.docs.first;
      return User.fromMap(doc.data());
    } else {
      return null;
    }
  }

  Future<User?> getUserByFirebaseUidLocal(String firebaseUid) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'firebase_uid = ?',
      whereArgs: [firebaseUid],
    );

    if (maps.isNotEmpty) {
      final map = maps.first;
      return User.fromMap(map);
    } else {
      return null;
    }
  }

  Future<User?> getUserByFirebaseUidFirestore(String firebaseUid) async {
    var docSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUid)
        .get();
    if (docSnapshot.exists) {
      return User.fromMap(docSnapshot.data() as Map<String, dynamic>);
    } else {
      return null;
    }
  }

  Future<void> updateUserLocal(User user) async {
    final db = await database;
    await db.update(
      'users',
      {'name': user.name, 'email': user.email},
      where: 'id = ?',
      whereArgs: [user.id],
    );
    await _updatePledgedGiftsWithNewUserName(user.id!, user.name);
  }

  Future<void> updateUserFirestore(User user) async {
    // print('Updating user with firebaseUid: ${user.firebaseUid}');
    int userIntID = int.parse(user.firebaseUid);
    // print(userIntID);
    var querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('id', isEqualTo: userIntID)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      var docSnapshot = querySnapshot.docs.first;
      // print('User document found: ${docSnapshot.id}');
      await FirebaseFirestore.instance
          .collection('users')
          .doc(docSnapshot.id)
          .update({
        'name': user.name,
        'phoneNumber': user.phoneNumber,
      });
      // print('User updated successfully');

      // Update pledged gifts and friends
      await updatePledgedGiftsForUser(user.name, userIntID);
      await updateFriendsForUser(user.name, userIntID);
    } else {
      // print('No user found with firebaseUid: ${user.firebaseUid}');
    }
  }

  Future<void> _updatePledgedGiftsWithNewUserName(
      int userId, String newName) async {
    final db = await database; // Find all events created by this user
    final List<Map<String, dynamic>> eventMaps = await db.query(
      'events',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    for (var eventMap in eventMaps) {
      int eventId = eventMap['id'];
      await EventController()
          .updatePledgedGiftsWithEventOwner(eventId, newName);
    }
  }

  Future<void> deleteUserLocal(int id) async {
    final db = await database;
    await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteUserByFirebaseUidFirestore(String firebaseUid) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUid)
        .delete();
  }

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> registerUser(String email, String password, String name,
      String preferences, String phoneNumber) async {
    final hashedPassword = _hashPassword(password);

    try {
      firebase_auth.UserCredential userCredential = await firebase_auth
          .FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String firebaseUid = userCredential.user!.uid;

      User newUser = User(
        id: firebaseUid.hashCode,
        // Using Firebase UID's hash as a local ID "So I don't have to change the local structure"
        firebaseUid: firebaseUid,
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        preferences: preferences,
        password: hashedPassword,
      );

      await insertUserLocal(newUser);
      await insertUserFirestore(newUser);
      // print("User registered successfully with Firebase UID: $firebaseUid");
    } catch (e) {
      // print("Failed to register user: $e");
    }
  }

  Future<bool> _isOnline() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult[0] != ConnectivityResult.none;
  }

  Future<User?> authenticateUser(String email, String password) async {
    // Check network connectivity
    if (await _isOnline()) {
      try {
        var querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .where('password', isEqualTo: _hashPassword(password))
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          var userData = querySnapshot.docs.first.data();
          return User.fromMap(userData);
        }
      } catch (e) {
        // Handle any Firestore errors (e.g., network issues)
      }
    }

    // Fallback to local authentication
    final db = await database;
    final hashedPassword = _hashPassword(password);
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, hashedPassword],
    );

    if (maps.isNotEmpty) {
      final map = maps.first;
      return User.fromMap(map);
    } else {
      return null;
    }
  }

  Future<bool> emailExists(String email, int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'email = ? AND id != ?',
      whereArgs: [email, userId],
    );
    return result.isNotEmpty;
  }

  Future<List<User>> usersLocal() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) {
      return User.fromMap(maps[i]);
    });
  }

  Future<List<User>> usersFirestore() async {
    var querySnapshot =
        await FirebaseFirestore.instance.collection('users').get();
    return querySnapshot.docs.map((doc) => User.fromMap(doc.data())).toList();
  }

  Future<void> updateFriendsForUser(String newName, int userId) async {
    // print('Updating friends for userId2: $userId with new name: $newName');
    var querySnapshot = await FirebaseFirestore.instance
        .collection('friends')
        .where('userId2', isEqualTo: userId)
        .get();

    for (var doc in querySnapshot.docs) {
      // print('Friend document found: ${doc.id}');
      await FirebaseFirestore.instance
          .collection('friends')
          .doc(doc.id)
          .update({
        'name': newName,
      });
      // print('Friend updated successfully');
    }
  }

  Future<void> updatePledgedGiftsForUser(String newName, int userId) async {
    // Fetch event IDs for the user
    List<int> eventIds = await getEventIdsForUser(userId);

    for (int eventId in eventIds) {
      // print('Updating pledged gifts for eventId: $eventId');
      var querySnapshot = await FirebaseFirestore.instance
          .collection('pledged_gifts')
          .where('eventId', isEqualTo: eventId)
          .get();

      for (var doc in querySnapshot.docs) {
        // print('Pledged gift document found: ${doc.id}');
        await FirebaseFirestore.instance
            .collection('pledged_gifts')
            .doc(doc.id)
            .update({
          'friendName': newName,
        });
        // print('Pledged gift updated successfully');
      }
    }
  }

  Future<List<int>> getEventIdsForUser(int userId) async {
    // print('Fetching event IDs for userId: $userId');
    var querySnapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('userId', isEqualTo: userId)
        .get();

    List<int> eventIds =
        querySnapshot.docs.map((doc) => doc['id'] as int).toList();
    // print('Event IDs for userId: $eventIds');
    return eventIds;
  }

  Future<void> retrieveAndSaveProfileImage(String firebaseUid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int userIntID = int.parse(firebaseUid);
    var querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('id', isEqualTo: userIntID)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      var docSnapshot = querySnapshot.docs.first;
      var userData = docSnapshot.data();
      String? profileImageBase64 = userData['profileImageBase64'];

      if (profileImageBase64 != null) {
        await prefs.setString('profileImageBase64', profileImageBase64);
      }
    } else {
      //print('No user found with firebaseUid: $firebaseUid');
    }
  }

  Future<String?> getUserProfileImage(int userId) async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('id', isEqualTo: userId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      var docSnapshot = querySnapshot.docs.first;
      var userData = docSnapshot.data();
      return userData['profileImageBase64'];
    }
    return null;
  }

  Future<User?> getUserByPhoneNumber(String phoneNumber) async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        var doc = querySnapshot.docs.first;
        return User.fromMap(doc.data());
      }
    } catch (e) {
      //print('Error getting user by phone number: $e');
    }
    return null;
  }

  Future<User?> getUserByEventId(int eventId) async {
    try {
      var eventQuerySnapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('id', isEqualTo: eventId)
          .get();
      if (eventQuerySnapshot.docs.isNotEmpty) {
        var eventDoc = eventQuerySnapshot.docs.first;
        var userId = eventDoc.data()['userId'];

        var userQuerySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('id', isEqualTo: userId)
            .get();
        if (userQuerySnapshot.docs.isNotEmpty) {
          var userDoc = userQuerySnapshot.docs.first;
          return User.fromMap(userDoc.data());
        }
      }
    } catch (e) {
      print('Error getting user by eventId: $e');
    }
    return null;
  }

}
