import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';
import '../models/event.dart';
import '../init_database.dart';
import '../models/gift.dart';
import 'gift_controller.dart';

class EventController {
  static final EventController _instance = EventController._internal();
  factory EventController() => _instance;
  EventController._internal();

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
      final map = maps.first;
      return Event(
        id: map['id'],
        docId: map['docId'],
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

    // Ensure the document ID exists
    if (event.docId != null && event.docId!.isNotEmpty) {
      // Attempt to get the document snapshot
      var docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        await docRef.update(event.toMap());
        // print("Event document successfully updated!");

        // Update dueDate in pledged gifts associated with this event
        await updateDueDateInPledgedGifts(event.id!, event.date);
      } else {
        // print("No document found with the provided docId.");
      }
    } else {
      // print("Invalid document ID.");
    }
  }

// Method to update the dueDate in pledged gifts associated with the event
  Future<void> updateDueDateInPledgedGifts(int eventId, String newDueDate) async {
    // print('Updating dueDate for pledged gifts with eventId: $eventId');
    var querySnapshot = await FirebaseFirestore.instance
        .collection('pledged_gifts')
        .where('eventId', isEqualTo: eventId)
        .get();

    for (var doc in querySnapshot.docs) {
      // print('Pledged gift document found: ${doc.id}');
      await FirebaseFirestore.instance.collection('pledged_gifts').doc(doc.id).update({
        'dueDate': newDueDate,
      });
      // print('Pledged gift dueDate updated successfully');
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

    // Delete related gifts and pledged gifts
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
// Insert local event into local_events table
  Future<int> insertLocalEventTable(Event event) async {
    final db = await database;
    final eventMap = event.toMap();
    eventMap.remove('id'); // Ensure ID is not set for auto-increment
    return await db.insert(
      'local_events',
      eventMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Fetch local events from local_events table
  Future<List<Event>> getLocalEventsTable({required int userId}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'local_events',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) {
      return Event(
        id: maps[i]['id'],
        docId: maps[i]['docId'],
        name: maps[i]['name'],
        category: maps[i]['category'],
        status: maps[i]['status'],
        date: maps[i]['date'],
        location: maps[i]['location'],
        description: maps[i]['description'],
        userId: maps[i]['userId'],
        gifts: [], // Retrieve gifts separately based on eventId
      );
    });
  }

  // Delete local event from local_events table
  Future<void> deleteLocalEventTable(int id) async {
    final db = await database;
    await db.delete(
      'local_events',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Publish local event to Firestore and delete from local_events table
  Future<void> publishLocalEventTable(Event event) async {
    List<Gift> localGifts = await GiftController().getGiftsLocalTABLE(event.id!);
    final docRef = FirebaseFirestore.instance.collection('events').doc();
    event.docId = docRef.id;
    int originalEventId = event.id!;
    event.id = docRef.id.hashCode; await docRef.set(event.toMap());

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

  // Update local event in local_events table
  Future<void> updateLocalEventTable(Event event) async {
    final db = await database;
    await db.update(
      'local_events',
      event.toMap(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }
}
