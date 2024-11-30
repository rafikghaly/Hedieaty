import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<void> insertGiftLocal(Gift gift) async {
    final db = await database;
    await db.insert(
      'gifts',
      gift.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertGiftFirestore(Gift gift) async {
    await FirebaseFirestore.instance.collection('gifts').add(gift.toMap());
  }

  Future<List<Gift>> giftsLocal(int eventId) async {
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

  Future<List<Gift>> giftsFirestore(int eventId) async {
    var querySnapshot = await FirebaseFirestore.instance.collection('gifts').where('eventId', isEqualTo: eventId).get();
    return querySnapshot.docs.map((doc) => Gift.fromMap(doc.data())).toList();
  }

  Future<Gift?> getGiftByIdLocal(int id) async {
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

  Future<Gift?> getGiftByIdFirestore(int id) async {
    var docSnapshot = await FirebaseFirestore.instance.collection('gifts').doc(id.toString()).get();
    if (docSnapshot.exists) {
      return Gift.fromMap(docSnapshot.data() as Map<String, dynamic>);
    } else {
      return null;
    }
  }

  Future<void> updateGiftLocal(Gift gift) async {
    final db = await database;
    await db.update(
      'gifts',
      gift.toMap(),
      where: 'id = ?',
      whereArgs: [gift.id],
    );
  }

  Future<void> updateGiftFirestore(Gift gift) async {
    await FirebaseFirestore.instance.collection('gifts').doc(gift.id.toString()).update(gift.toMap());
  }

  Future<void> deleteGiftLocal(int id) async {
    final db = await database;
    await db.delete(
      'gifts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteGiftFirestore(int id) async {
    await FirebaseFirestore.instance.collection('gifts').doc(id.toString()).delete();
  }
}
