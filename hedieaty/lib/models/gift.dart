import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';
import '../init_database.dart';

class Gift {
  late int? id;
  final int eventId;
  final String name;
  final String description;
  final String category;
  String status;
  bool isPledged;
  final String? imageUrl;
  final double price;
  String? docId;
  bool isPurchased;

  Gift({
    this.id,
    required this.eventId,
    required this.name,
    required this.description,
    required this.category,
    required this.status,
    required this.isPledged,
    required this.imageUrl,
    required this.price,
    required this.docId,
    this.isPurchased = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventId': eventId,
      'name': name,
      'description': description,
      'category': category,
      'status': status,
      'isPledged': isPledged ? 1 : 0,
      'imageUrl': imageUrl,
      'price': price,
      'docId': docId,
      'isPurchased': isPurchased ? 1 : 0,
    };
  }

  factory Gift.fromMap(Map<String, dynamic> map) {
    return Gift(
      id: map['id'] as int?,
      eventId: map['eventId'] as int,
      name: map['name'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      status: map['status'] as String,
      isPledged: map['isPledged'] == 1,
      imageUrl: map['imageUrl'] as String?,
      price: map['price'] as double,
      docId: map['docId'] as String?,
      isPurchased: map['isPurchased'] == 1,
    );
  }

  // For real-time Listeners
  factory Gift.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Gift(
      id: data['id'],
      eventId: data['eventId'],
      name: data['name'],
      description: data['description'],
      category: data['category'],
      status: data['status'],
      isPledged: data['isPledged'] == 1,
      imageUrl: data['imageUrl'],
      price: data['price'],
      docId: doc.id,
      isPurchased: data['isPurchased'] == 1,
    );
  }
}

/// GiftService ///
class GiftService {
  static final GiftService _instance = GiftService._internal();

  factory GiftService() => _instance;

  GiftService._internal();

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

  Future<Gift?> getGiftByIdForPledgedFirestore(int id) async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('gifts')
        .where('id', isEqualTo: id)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      var docSnapshot = querySnapshot.docs.first;
      // print('Gift data retrieved: ${docSnapshot.data()}');
      return Gift.fromMap(docSnapshot.data());
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

  Future<void> markGiftAsPurchased(String? giftId) async {
    if (giftId != null) {
      final db = await database;
      await db.update(
        'gifts',
        {
          'isPurchased': 1,
          'status': 'purchased'
        },
        where: 'id = ?',
        whereArgs: [giftId],
      );

      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      try {
        DocumentSnapshot docSnapshot =
        await firestore.collection('gifts').doc(giftId).get();
        if (docSnapshot.exists) {
          await firestore.collection('gifts').doc(giftId).update({
            'isPurchased': 1,
            'status': 'purchased'
          });
          // print('Gift $giftId marked as purchased in Firestore');
        } else {
          // print('Gift $giftId not found in Firestore');
        }
      } catch (e) {
        // print('Error marking gift as purchased in Firestore: $e');
      }
    }
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
        isPledged: maps[i]['isPledged'] == 1,
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
