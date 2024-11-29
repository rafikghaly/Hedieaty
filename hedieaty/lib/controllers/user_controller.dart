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

  Future<void> insertUser(User user) async {
    final db = await database;
    await db.insert(
      'users',
      user.toMap()..remove('id'), // Ensure id is not set manually
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }

  Future<User?> getUserByEmail(String email) async {
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

  Future<User?> getUserById(int id) async {
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

  Future<User?> getUserByFirebaseUid(String firebaseUid) async {
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

  Future<void> updateUser(User user) async {
    final db = await database;
    await db.update(
      'users',
      {'name': user.name, 'email': user.email},
      where: 'id = ?',
      whereArgs: [user.id],
    );
    await _updatePledgedGiftsWithNewUserName(user.id!, user.name);
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

  Future<void> deleteUser(int id) async {
    final db = await database;
    await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> registerUser(String email, String password, String name, String preferences) async {
    final hashedPassword = _hashPassword(password);

    try {
      // Register user with Firebase Authentication
      print("Controller");

      firebase_auth.UserCredential userCredential = await firebase_auth.FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get the Firebase UID
      String firebaseUid = userCredential.user!.uid;

      // Create a new User object with Firebase UID
      User newUser = User(
        id: firebaseUid.hashCode, // Using Firebase UID's hash as a local ID "So I don't have to change the local structure"
        firebaseUid: firebaseUid,
        name: name,
        email: email,
        preferences: preferences,
        password: hashedPassword,
      );

      // Insert the new user into the local database
      await insertUser(newUser);
      print("User registered successfully with Firebase UID: $firebaseUid");

    } catch (e) {
      print("Failed to register user: $e");
    }
  }

  Future<User?> authenticateUser(String email, String password) async {
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

  // New method to fetch all users
  Future<List<User>> users() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) {
      return User.fromMap(maps[i]);
    });
  }
}
