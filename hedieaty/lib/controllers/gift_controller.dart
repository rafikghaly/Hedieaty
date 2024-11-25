import 'package:sqflite/sqflite.dart';
import '../models/gift.dart';
import '../init_database.dart';

class GiftController {
  static final GiftController _instance = GiftController._internal();
  factory GiftController() => _instance;
  GiftController._internal();

  Future<Database> get database async {
    return await DatabaseInitializer().database;
  }

  Future<void> insertGift(Gift gift) async {
    final db = await database;
    await db.insert(
      'gifts',
      gift.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Gift>> gifts(int eventId) async {
    final db = await database;
    final List<Map<String, dynamic>> giftMaps = await db.query(
      'gifts',
      where: 'eventId = ?',
      whereArgs: [eventId],
    );

    return List.generate(giftMaps.length, (i) {
      return Gift.fromMap(giftMaps[i]);
    });
  }

  Future<Gift?> getGiftById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'gifts',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Gift.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<void> updateGift(Gift gift) async {
    final db = await database;
    await db.update(
      'gifts',
      gift.toMap(),
      where: 'id = ?',
      whereArgs: [gift.id],
    );
  }

  Future<void> deleteGift(int id) async {
    final db = await database;
    await db.delete(
      'gifts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
