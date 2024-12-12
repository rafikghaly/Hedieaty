import '../controllers/gift_controller.dart';
import 'gift.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';
import '../init_database.dart';

class Event {
  late int? id;
  final String name;
  final String category;
  final String status;
  final String date;
  final String location;
  final String description;
  final int userId;
  final List<Gift> gifts;
  String? docId;

  Event({
    this.id,
    required this.docId,
    required this.name,
    required this.category,
    required this.status,
    required this.date,
    required this.location,
    required this.description,
    required this.userId,
    required this.gifts,
  });

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      docId: map['docId'],
      name: map['name'],
      category: map['category'],
      status: map['status'],
      date: map['date'],
      location: map['location'],
      description: map['description'],
      userId: map['userId'],
      gifts: [], // gifts will be populated separately
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'docId': docId,
      'name': name,
      'category': category,
      'status': status,
      'date': date,
      'location': location,
      'description': description,
      'userId': userId,
    };
  }
}

class EventService {
  static final EventService _instance = EventService._internal();

  factory EventService() => _instance;

  EventService._internal();

  Future<Database> get database async {
    return await DatabaseInitializer().database;
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
      return Event.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<Event?> getEventByIdFirestore(int id) async {
    var querySnapshot = await FirebaseFirestore.instance.collection('events').where('id', isEqualTo: id).get();
    if (querySnapshot.docs.isNotEmpty) {
      var doc = querySnapshot.docs.first;
      return Event.fromMap(doc.data());
    } else {
      return null;
    }
  }

  Future<List<Event>> eventsLocal(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> eventMaps = await db.query(
      'events',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    return List.generate(eventMaps.length, (i) {
      return Event.fromMap(eventMaps[i]);
    });
  }

  Future<List<Event>> eventsFirestore(int userId) async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('userId', isEqualTo: userId)
        .get();
    return querySnapshot.docs.map((doc) => Event.fromMap(doc.data())).toList();
  }

  Future<void> updateEventLocal(Event event) async {
    final db = await database;
    await db.update(
      'events',
      event.toMap(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  Future<void> updateEventFirestore(Event event) async {
    final docRef = FirebaseFirestore.instance.collection('events').doc(event.docId);
    if (event.docId != null && event.docId!.isNotEmpty) {
      var docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        await docRef.update(event.toMap());
      }
    }
  }

  Future<void> deleteEventLocal(int id) async {
    final db = await database;
    await db.delete(
      'pledged_gifts',
      where: 'eventId = ?',
      whereArgs: [id],
    );
    await db.delete(
      'gifts',
      where: 'eventId = ?',
      whereArgs: [id],
    );
    await db.delete(
      'events',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteEventFirestore(String id) async {
    var eventDoc = FirebaseFirestore.instance.collection('events').doc(id);
    var giftsQuery = await FirebaseFirestore.instance.collection('gifts').where('eventId', isEqualTo: id.hashCode).get();
    for (var doc in giftsQuery.docs) {
      await FirebaseFirestore.instance.collection('gifts').doc(doc.id).delete();
    }
    var pledgedGiftsQuery = await FirebaseFirestore.instance.collection('pledged_gifts').where('eventId', isEqualTo: id.hashCode).get();
    for (var doc in pledgedGiftsQuery.docs) {
      await FirebaseFirestore.instance.collection('pledged_gifts').doc(doc.id).delete();
    }
    await eventDoc.delete();
  }

  ///THIS IS ONLY FOR LOCAL_EVENTS TABLE
  Future<int> insertLocalEventTable(Event event) async {
    final db = await database;
    final eventMap = event.toMap();
    eventMap.remove('id');
    return await db.insert(
      'local_events',
      eventMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Event>> getLocalEventsTable(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'local_events',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) {
      return Event.fromMap(maps[i]);
    });
  }

  Future<void> deleteLocalEventTable(int id) async {
    final db = await database;
    await db.delete(
      'local_events',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> publishLocalEventTable(Event event) async {
    List<Gift> localGifts = await GiftController().getGiftsLocalTABLE(event.id!);
    final docRef = FirebaseFirestore.instance.collection('events').doc();
    event.docId = docRef.id;
    int originalEventId = event.id!;
    event.id = docRef.id.hashCode;
    await docRef.set(event.toMap());

    for (Gift localGift in localGifts) {
      Gift updatedGift = Gift(
        id: localGift.id,
        docId: localGift.docId,
        name: localGift.name,
        description: localGift.description,
        category: localGift.category,
        price: localGift.price,
        status: localGift.status,
        isPledged: localGift.isPledged,
        imageUrl: localGift.imageUrl,
        eventId: event.id!, // Using the new Firestore event ID
      );
      await GiftController().insertGiftFirestore(updatedGift);
    }

    await deleteLocalEventTable(originalEventId);
    await GiftController().deleteGiftsForEventLocalTABLE(originalEventId);
  }

  Future<void> updateLocalEventTable(Event event) async {
    final db = await database;
    await db.update(
      'local_events',
      event.toMap(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  Future<void> updatePledgedGiftsWithNewEventDate(int eventId, String newDate) async {
    final db = await database;
    await db.rawUpdate(
      '''UPDATE pledged_gifts SET dueDate = ? WHERE eventId = ?''',
      [newDate, eventId],
    );
  }

  Future<void> updatePledgedGiftsWithEventOwner(int eventId, String newName) async {
    final db = await database;
    await db.rawUpdate(
      '''UPDATE pledged_gifts SET friendName = ? WHERE eventId = ?''',
      [newName, eventId],
    );
  }

  Future<void> updateDueDateInPledgedGifts(int eventId, String newDueDate) async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('pledged_gifts')
        .where('eventId', isEqualTo: eventId)
        .get();

    for (var doc in querySnapshot.docs) {
      await FirebaseFirestore.instance.collection('pledged_gifts').doc(doc.id).update({
        'dueDate': newDueDate,
      });
    }
  }
}
