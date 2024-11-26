import 'package:sqflite/sqflite.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/user.dart';
import '../init_database.dart';

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
      return User(
        id: map['id'],
        name: map['name'],
        email: map['email'],
        preferences: map['preferences'],
        password: map['password'],
      );
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
      return User(
        id: map['id'],
        name: map['name'],
        email: map['email'],
        preferences: map['preferences'],
        password: map['password'],
      );
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

  Future<void> registerUser(User user) async {
    final hashedPassword = _hashPassword(user.password);
    User userWithHashedPassword = User(
      id: null, // Ensure id is null to let the DB handle auto-increment
      name: user.name,
      email: user.email,
      preferences: user.preferences,
      password: hashedPassword,
    );
    await insertUser(userWithHashedPassword);
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
      return User(
        id: map['id'],
        name: map['name'],
        email: map['email'],
        preferences: map['preferences'],
        password: map['password'],
      );
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
}
