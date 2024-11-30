import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';
import '../models/event.dart';
import '../init_database.dart';
import 'gift_controller.dart';

class EventController {
  static final EventController _instance = EventController._internal();
  factory EventController() => _instance;
  EventController._internal();

  Future<Database> get database async {
    return await DatabaseInitializer().database;
  }

  Future<int> insertEventLocal(Event event) async {
    final db = await database;
    final eventMap = event.toMap();
    eventMap.remove('id'); // Ensure ID is not set for auto-increment
    return await db.insert(
      'events',
      eventMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertEventFirestore(Event event) async {
    final docRef = FirebaseFirestore.instance.collection('events').doc();
    event.docId = docRef.id;
    event.id = docRef.id.hashCode;
    await docRef.set(event.toMap());
  }

  Future<Event?> getEventByIdLocal(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'events',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      final map = maps.first;
      return Event(
        id: map['id'],
        docId: map['docId'], // Add docId here
        name: map['name'],
        category: map['category'],
        date: map['date'],
        status: map['status'],
        location: map['location'],
        description: map['description'],
        userId: map['userId'],
        gifts: await GiftController().giftsLocal(map['id']),
      );
    } else {
      return null;
    }
  }

  Future<Event?> getEventByIdFirestore(int id) async {
    var querySnapshot = await FirebaseFirestore.instance.collection('events').where('id', isEqualTo: id).get();
    if (querySnapshot.docs.isNotEmpty) {
      var doc = querySnapshot.docs.first;
      var data = doc.data();
      var gifts = await GiftController().giftsFirestore(data['id']);
      return Event(
        id: data['id'],
        docId: doc.id, // Add docId here
        name: data['name'],
        category: data['category'],
        date: data['date'],
        status: data['status'],
        location: data['location'],
        description: data['description'],
        userId: data['userId'],
        gifts: gifts,
      );
    } else {
      return null;
    }
  }

  Future<List<Event>> eventsLocal({required int userId}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'events',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    return List.generate(maps.length, (i) {
      return Event(
        id: maps[i]['id'],
        docId: maps[i]['docId'], // Add docId here
        name: maps[i]['name'],
        category: maps[i]['category'],
        status: maps[i]['status'],
        date: maps[i]['date'],
        location: maps[i]['location'],
        description: maps[i]['description'],
        userId: maps[i]['userId'],
        gifts: [], // Retrieving gifts separately based on eventId
      );
    });
  }

  Future<List<Event>> eventsFirestore({required int userId}) async {
    var querySnapshot = await FirebaseFirestore.instance.collection('events').where('userId', isEqualTo: userId).get();
    return querySnapshot.docs.map((doc) {
      var data = doc.data();
      return Event(
        id: data['id'],
        docId: doc.id, // Add docId here
        name: data['name'],
        category: data['category'],
        status: data['status'],
        date: data['date'],
        location: data['location'],
        description: data['description'],
        userId: data['userId'],
        gifts: [], // Retrieve gifts separately based on eventId
      );
    }).toList();
  }

  Future<void> updateEventLocal(Event event) async {
    final db = await database;
    await db.update(
      'events',
      event.toMap(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
    await _updatePledgedGiftsWithNewEventDate(event.id!, event.date);
  }

  Future<void> updateEventFirestore(Event event) async {
    // Reference the document by the stored Firestore document ID
    final docRef = FirebaseFirestore.instance.collection('events').doc(event.docId);

    // print("Document ID (update): ${docRef.id}");
    // print("event.docId: ${event.docId}");

    // Ensure the document ID exists
    if (event.docId != null && event.docId!.isNotEmpty) {
      // Attempt to get the document snapshot
      var docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        await docRef.update(event.toMap());
        // print("Document successfully updated!");
      } else {
        // print("No document found with the provided docId.");
      }
    } else {
      // print("Invalid document ID.");
    }
  }

  Future<void> _updatePledgedGiftsWithNewEventDate(int eventId, String newDate) async {
    final db = await database;
    int updatedCount = await db.rawUpdate(
      ''' UPDATE pledged_gifts SET dueDate = ? WHERE eventId = ? ''',
      [newDate, eventId],
    );
  }

  Future<void> updatePledgedGiftsWithEventOwner(int eventId, String newName) async {
    final db = await database;
    int updatedCount = await db.rawUpdate(
      ''' UPDATE pledged_gifts SET friendName = ? WHERE eventId = ? ''',
      [newName, eventId],
    );
  }

  Future<void> deleteEventLocal(int id) async {
    final db = await database;
    await db.delete(
      'events',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteEventFirestore(String id) async {
    await FirebaseFirestore.instance.collection('events').doc(id).delete();
  }
}
