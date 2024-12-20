import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';
import '../init_database.dart';

class PledgedGift {
  late int? id;
  late String? docId;
  final int eventId;
  final int userId;
  final int giftId;
  final String friendName;
  final String dueDate;

  PledgedGift({
    this.id,
    required this.docId,
    required this.eventId,
    required this.userId,
    required this.giftId,
    required this.friendName,
    required this.dueDate,
  });

  factory PledgedGift.fromMap(Map<String, dynamic> map) {
    return PledgedGift(
      id: map['id'],
      docId: map['docId'],
      eventId: map['eventId'],
      userId: map['userId'],
      giftId: map['giftId'],
      friendName: map['friendName'],
      dueDate: map['dueDate'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'docId': docId,
      'eventId': eventId,
      'userId': userId,
      'giftId': giftId,
      'friendName': friendName,
      'dueDate': dueDate,
    };
  }
}

/// PledgeService ///
class PledgedGiftService {
  static final PledgedGiftService _instance = PledgedGiftService._internal();

  factory PledgedGiftService() => _instance;

  PledgedGiftService._internal();

  Future<Database> get database async {
    return await DatabaseInitializer().database;
  }

  /// Insert Operations ///
  Future<int> insertPledgedGiftLocal(PledgedGift pledgedGift) async {
    final db = await database;
    final pledgedGiftMap = pledgedGift.toMap();
    pledgedGiftMap.remove('id'); // Ensure ID is not set for auto-increment
    return await db.insert(
      'pledged_gifts',
      pledgedGiftMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertPledgedGiftFirestore(PledgedGift pledgedGift) async {
    // Create a reference to a new document with an auto-generated ID
    final docRef = FirebaseFirestore.instance.collection('pledged_gifts').doc();

    // The unique Firestore document ID
    pledgedGift.docId = docRef.id;
    pledgedGift.id = docRef.id.hashCode;

    // Set the pledged gift data with the newly assigned document ID
    await docRef.set(pledgedGift.toMap());
  }

  /// Read Operations ///
  Future<PledgedGift?> getPledgedGiftByIdLocal(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pledged_gifts',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      final map = maps.first;
      return PledgedGift.fromMap(map);
    } else {
      return null;
    }
  }

  Future<PledgedGift?> getPledgedGiftByIdFirestore(String docId) async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('pledged_gifts')
        .doc(docId)
        .get();
    if (docSnapshot.exists) {
      return PledgedGift.fromMap(docSnapshot.data()!);
    } else {
      return null;
    }
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

  Future<List<PledgedGift>> getPledgedGiftsForEventFirestore(
      int eventId) async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('pledged_gifts')
        .where('eventId', isEqualTo: eventId)
        .get();
    return querySnapshot.docs.map((doc) {
      return PledgedGift.fromMap(doc.data());
    }).toList();
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
    var querySnapshot = await FirebaseFirestore.instance
        .collection('pledged_gifts')
        .where('userId', isEqualTo: userId)
        .get();
    return querySnapshot.docs.map((doc) {
      return PledgedGift.fromMap(doc.data());
    }).toList();
  }

  /// Update Operations ///
  Future<void> updatePledgedGiftLocal(PledgedGift pledgedGift) async {
    final db = await database;
    await db.update(
      'pledged_gifts',
      pledgedGift.toMap(),
      where: 'id = ?',
      whereArgs: [pledgedGift.id],
    );
  }

  Future<void> updatePledgedGiftFirestore(PledgedGift pledgedGift) async {
    final docRef = FirebaseFirestore.instance
        .collection('pledged_gifts')
        .doc(pledgedGift.docId);

    if (pledgedGift.docId != null && pledgedGift.docId!.isNotEmpty) {
      var docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        await docRef.update(pledgedGift.toMap());
        // print("Document successfully updated!");
      } else {
        // print("No document found with the provided docId.");
      }
    } else {
      // print("Invalid document ID.");
    }
  }

  /// Delete Operations ///
  Future<void> deletePledgedGiftLocal(int id) async {
    final db = await database;
    await db.delete(
      'pledged_gifts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deletePledgedGiftFirestore(String docId) async {
    await FirebaseFirestore.instance
        .collection('pledged_gifts')
        .doc(docId)
        .delete();
  }
}
