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

  Future<void> insertEvent(Event event) async {
    final db = await database;
    final eventMap = event.toMap();
    eventMap.remove('id');
    await db.insert(
      'events',
      eventMap,
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }

  Future<Event?> getEventById(int id) async {
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
        gifts: await GiftController().gifts(map['id']),
      );
    } else {
      return null;
    }
  }

  Future<List<Event>> events({required int userId}) async {
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

  Future<void> updateEvent(Event event) async {
    final db = await database;
    await db.update(
      'events',
      event.toMap(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
    await _updatePledgedGiftsWithNewEventDate(event.id!, event.date);
  }

  Future<void> _updatePledgedGiftsWithNewEventDate(
      int eventId, String newDate) async {
    final db = await database;
    int updatedCount = await db.rawUpdate(
      ''' UPDATE pledged_gifts SET dueDate = ? WHERE eventId = ? ''',
      [newDate, eventId],
    );
    //print('Updated $updatedCount pledged gifts with new due date for eventId: $eventId');
  }

  Future<void> updatePledgedGiftsWithEventOwner(
      int eventId, String newName) async {
    final db = await database;
    int updatedCount = await db.rawUpdate(
      ''' UPDATE pledged_gifts SET friendName = ? WHERE eventId = ? ''',
      [newName, eventId],
    );
    //print('Updated $updatedCount pledged gifts with new friend name for eventId: $eventId');
  }

  Future<void> deleteEvent(int id) async {
    final db = await database;
    await db.delete(
      'events',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
