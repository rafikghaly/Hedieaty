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

  Future<List<Gift>> gifts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('gifts');

    return List.generate(maps.length, (i) {
      return Gift(
        id: maps[i]['id'],
        name: maps[i]['name'],
        description: maps[i]['description'],
        category: maps[i]['category'],
        price: maps[i]['price'],
        status: maps[i]['status'],
        isPledged: maps[i]['isPledged'] == 1,
        imageUrl: maps[i]['imageUrl'],
        eventId: maps[i]['eventId'],
      );
    });
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
