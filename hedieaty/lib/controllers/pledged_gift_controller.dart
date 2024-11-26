import 'package:sqflite/sqflite.dart';
import '../models/pledged_gift.dart';
import '../init_database.dart';

class PledgedGiftController {
  static final PledgedGiftController _instance = PledgedGiftController._internal();
  factory PledgedGiftController() => _instance;
  PledgedGiftController._internal();

  Future<Database> get database async {
    return await DatabaseInitializer().database;
  }

  Future<void> insertPledgedGift(PledgedGift pledgedGift) async {
    final db = await database;
    await db.insert(
      'pledged_gifts',
      pledgedGift.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<PledgedGift>> getPledgedGiftsForUser(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pledged_gifts',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    return List.generate(maps.length, (i) {
      return PledgedGift.fromMap(maps[i]);
    });
  }

  Future<List<PledgedGift>> getPledgedGiftsForEvent(int eventId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pledged_gifts',
      where: 'eventId = ?',
      whereArgs: [eventId],
    );

    return List.generate(maps.length, (i) {
      return PledgedGift.fromMap(maps[i]);
    });
  }

  Future<void> deletePledgedGift(int id) async {
    final db = await database;
    await db.delete(
      'pledged_gifts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
