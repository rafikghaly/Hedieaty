import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<void> insertPledgedGiftLocal(PledgedGift pledgedGift) async {
    final db = await database;
    await db.insert(
      'pledged_gifts',
      pledgedGift.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertPledgedGiftFirestore(PledgedGift pledgedGift) async {
    await FirebaseFirestore.instance.collection('pledged_gifts').add(pledgedGift.toMap());
  }

  Future<List<PledgedGift>> getPledgedGiftsForUserLocal(int userId) async {
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

  Future<List<PledgedGift>> getPledgedGiftsForUserFirestore(int userId) async {
    var querySnapshot = await FirebaseFirestore.instance.collection('pledged_gifts').where('userId', isEqualTo: userId).get();
    return querySnapshot.docs.map((doc) => PledgedGift.fromMap(doc.data())).toList();
  }

  Future<List<PledgedGift>> getPledgedGiftsForEventLocal(int eventId) async {
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

  Future<List<PledgedGift>> getPledgedGiftsForEventFirestore(int eventId) async {
    var querySnapshot = await FirebaseFirestore.instance.collection('pledged_gifts').where('eventId', isEqualTo: eventId).get();
    return querySnapshot.docs.map((doc) => PledgedGift.fromMap(doc.data())).toList();
  }

  Future<void> deletePledgedGiftLocal(int id) async {
    final db = await database;
    await db.delete(
      'pledged_gifts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deletePledgedGiftFirestore(int id) async {
    await FirebaseFirestore.instance.collection('pledged_gifts').doc(id.toString()).delete();
  }
}
