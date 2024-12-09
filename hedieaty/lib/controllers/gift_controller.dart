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

  Future<void> insertGiftFirestore(Gift gift) async {
    final docRef = FirebaseFirestore.instance.collection('gifts').doc();
    gift.docId = docRef.id;
    gift.id = docRef.id.hashCode;
    await docRef.set(gift.toMap());
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
    var querySnapshot = await FirebaseFirestore.instance
        .collection('gifts')
        .where('eventId', isEqualTo: eventId)
        .get();
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

  Future<Gift?> getGiftByIdFirestore(String docId) async {
    var docSnapshot =
        await FirebaseFirestore.instance.collection('gifts').doc(docId).get();
    if (docSnapshot.exists) {
      return Gift.fromMap(docSnapshot.data() as Map<String, dynamic>);
    } else {
      return null;
    }
  }

  Future<Gift?> getGiftById_for_pledged_Firestore(int id) async {
    var querySnapshot = await FirebaseFirestore.instance.collection('gifts').where('id', isEqualTo: id).get();
    if (querySnapshot.docs.isNotEmpty) {
      var docSnapshot = querySnapshot.docs.first;
      // print('Gift data retrieved: ${docSnapshot.data()}');
      return Gift.fromMap(docSnapshot.data() as Map<String, dynamic>);
    } else {
      // print('No gift found for gift ID: $id');
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
    await FirebaseFirestore.instance
        .collection('gifts')
        .doc(gift.docId)
        .update(gift.toMap());
  }

  Future<void> deleteGiftLocal(int id) async {
    final db = await database;
    await db.delete(
      'gifts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteGiftFirestore(String docId) async {
    await FirebaseFirestore.instance.collection('gifts').doc(docId).delete();
  }

  ///THIS IS ONLY FOR LOCAL_GIFTS TABLE
  Future<int> insertGiftLocalTABLE(Gift gift) async {
    final db = await database;
    final giftMap = gift.toMap();
    giftMap.remove('id'); // Ensure ID is not set for auto-increment
    return await db.insert(
      'local_gifts',
      giftMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Gift>> getGiftsLocalTABLE(int eventId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'local_gifts',
      where: 'eventId = ?',
      whereArgs: [eventId],
    );
    return List.generate(maps.length, (i) {
      return Gift(
        id: maps[i]['id'],
        docId: maps[i]['docId'],
        name: maps[i]['name'],
        description: maps[i]['description'],
        category: maps[i]['category'],
        price: maps[i]['price'],
        status: maps[i]['status'],
        isPledged: maps[i]['isPledged'] ==1,
        imageUrl: maps[i]['imageUrl'],
        eventId: maps[i]['eventId'],
      );
    });
  }

  Future<void> deleteGiftsForEventLocalTABLE(int eventId) async {
    final db = await database;
    await db.delete(
      'local_gifts',
      where: 'eventId = ?',
      whereArgs: [eventId],
    );
  }

  Future<void> updateGiftLocalTABLE(Gift gift) async {
    final db = await database;
    await db.update(
      'local_gifts',
      gift.toMap(),
      where: 'id = ?',
      whereArgs: [gift.id],
    );
  }

  Future<void> deleteGiftLocalTABLE(int giftId) async {
    final db = await database;
    await db.delete(
      'local_gifts',
      where: 'id = ?',
      whereArgs: [giftId],
    );
  }



///////////////////////////////////////////////////////////////////////////////
}
