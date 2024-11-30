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

  Future<void> insertEventLocal(Event event) async {
    final db = await database;
    final eventMap = event.toMap();
    eventMap.remove('id');
    await db.insert(
      'events',
      eventMap,
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }

  Future<void> insertEventFirestore(Event event) async {
    await FirebaseFirestore.instance.collection('events').add(event.toMap());
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
    await FirebaseFirestore.instance.collection('events').doc(event.id.toString()).update(event.toMap());
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

  Future<void> deleteEventFirestore(int id) async {
    await FirebaseFirestore.instance.collection('events').doc(id.toString()).delete();
  }
}
