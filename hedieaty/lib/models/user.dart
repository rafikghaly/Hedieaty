import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../controllers/event_controller.dart';
import '../init_database.dart';

class User {
  final int? id;
  final String firebaseUid;
  final String name;
  final String email;
  String preferences;
  String password;
  final String? profileImageBase64;
  final String? phoneNumber;

  User({
    this.id,
    this.phoneNumber,
    required this.firebaseUid,
    required this.name,
    required this.email,
    required this.preferences,
    required this.password,
    this.profileImageBase64,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      firebaseUid: map['firebase_uid'],
      name: map['name'],
      email: map['email'],
      phoneNumber: map['phoneNumber'],
      preferences: map['preferences'],
      password: map['password'],
      profileImageBase64: map['profileImageBase64'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firebase_uid': firebaseUid,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'preferences': preferences,
      'password': password,
      'profileImageBase64': profileImageBase64,
    };
  }

  bool get isDarkMode {
    return preferences.contains('darkMode=true');
  }

  void setDarkMode(bool isDarkMode) {
    if (isDarkMode) {
      preferences = 'darkMode=true';
    } else {
      preferences = 'darkMode=false';
    }
  }
}

/// UserService ///
class UserService {
  static final UserService _instance = UserService._internal();

  factory UserService() => _instance;

  UserService._internal();

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

  Future<bool> updateUserFirestore(User user) async {
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
      return true;
    } else {
      return false;
      // print('No user found with firebaseUid: ${user.firebaseUid}');
    }
  }

  Future<void> _updatePledgedGiftsWithNewUserName(int userId, String newName) async {
    // Find all events created by this user
    final db = await database;
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
    final List<Map<String, dynamic>> userMaps = await db.query('users');
    List<User> users = List.generate(userMaps.length, (i) {
      return User.fromMap(userMaps[i]);
    });
    final List<Map<String, dynamic>> friendMaps =
        await db.query('friend_local');
    List<User> friends = List.generate(friendMaps.length, (i) {
      return User(
          id: friendMaps[i]['friendUserId'],
          name: friendMaps[i]['name'],
          firebaseUid: '',
          email: '',
          preferences: '',
          password: '');
    });

    users.addAll(friends);
    return users;
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

  Future<String?> getProfileImageBase64(int userIntID) async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('id', isEqualTo: userIntID)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      var docSnapshot = querySnapshot.docs.first;
      var userData = docSnapshot.data();
      return userData['profileImageBase64'];
    } else {
      return null; // No user found
    }
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
      //print('Error getting user by eventId: $e');
    }
    return null;
  }
}
