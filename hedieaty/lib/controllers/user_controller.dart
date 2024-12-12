import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class UserController {
  static final UserController _instance = UserController._internal();
  final UserService _userService = UserService();

  factory UserController() => _instance;

  UserController._internal();

  Future<void> insertUserLocal(User user) async {
    await _userService.insertUserLocal(user);
  }

  Future<void> insertUserFirestore(User user) async {
    await _userService.insertUserFirestore(user);
  }

  Future<User?> getUserByEmailLocal(String email) async {
    return await _userService.getUserByEmailLocal(email);
  }

  Future<User?> getUserByEmailFirestore(String email) async {
    return await _userService.getUserByEmailFirestore(email);
  }

  Future<User?> getUserByIdLocal(int id) async {
    return await _userService.getUserByIdLocal(id);
  }

  Future<String> getFriendNameByIdLocal(int id) async {
    return await _userService.getFriendNameByIdLocal(id);
  }

  Future<User?> getUserByIdFirestore(int id) async {
    return await _userService.getUserByIdFirestore(id);
  }

  Future<User?> getUserByFirebaseUidLocal(String firebaseUid) async {
    return await _userService.getUserByFirebaseUidLocal(firebaseUid);
  }

  Future<User?> getUserByFirebaseUidFirestore(String firebaseUid) async {
    return await _userService.getUserByFirebaseUidFirestore(firebaseUid);
  }

  Future<void> updateUserLocal(User user) async {
    await _userService.updateUserLocal(user);
  }

  Future<void> updateUserFirestore(User user) async {
    var result = await _userService.updateUserFirestore(user);
    int userIntID = int.parse(user.firebaseUid);
    if (result) {
      await updatePledgedGiftsForUser(user.name, userIntID);
      await updateFriendsForUser(user.name, userIntID);
    }
  }

  Future<void> deleteUserLocal(int id) async {
    await _userService.deleteUserLocal(id);
  }

  Future<void> deleteUserByFirebaseUidFirestore(String firebaseUid) async {
    await _userService.deleteUserByFirebaseUidFirestore(firebaseUid);
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
      User? userExists = await _userService.getUserByPhoneNumber(phoneNumber);
      if (userExists != null) {
        throw Exception(
            'The phone number you entered is already in use.\nPlease use a different phone number.');
      }
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
      throw Exception(e);
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

    final db = await _userService.database;
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
    return await _userService.emailExists(email, userId);
  }

  Future<List<User>> usersLocal() async {
    return await _userService.usersLocal();
  }

  Future<List<User>> usersFirestore() async {
    return await _userService.usersFirestore();
  }

  Future<void> updateFriendsForUser(String newName, int userId) async {
    await _userService.updateFriendsForUser(newName, userId);
  }

  Future<void> updatePledgedGiftsForUser(String newName, int userId) async {
    await _userService.updatePledgedGiftsForUser(newName, userId);
  }

  Future<List<int>> getEventIdsForUser(int userId) async {
    return await _userService.getEventIdsForUser(userId);
  }

  Future<void> retrieveAndSaveProfileImage(String firebaseUid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userIntID = int.parse(firebaseUid);
    String? profileImageBase64 =
        await _userService.getProfileImageBase64(userIntID);
    if (profileImageBase64 != null) {
      await prefs.setString('profileImageBase64', profileImageBase64);
    } else {
      //print('No user found with firebaseUid: $firebaseUid');
    }
  }

  Future<String?> getUserProfileImage(int userId) async {
    return await _userService.getProfileImageBase64(userId);
  }

  Future<User?> getUserByPhoneNumber(String phoneNumber) async {
    return await _userService.getUserByPhoneNumber(phoneNumber);
  }

  Future<User?> getUserByEventId(int eventId) async {
    return await _userService.getUserByEventId(eventId);
  }
}
