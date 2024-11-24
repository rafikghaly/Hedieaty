import 'package:sqflite/sqflite.dart';
import '../models/event.dart';
import '../init_database.dart';

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
    eventMap.remove('id'); // Remove id to let the database handle auto-increment
    await db.insert(
      'events',
      eventMap,
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
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
        gifts: [], // TODO Retrieve gifts separately based on eventId in the next phase
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
