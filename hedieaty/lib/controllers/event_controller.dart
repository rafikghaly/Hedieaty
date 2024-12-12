import 'package:intl/intl.dart';
import '../models/event.dart';
import 'gift_controller.dart';

class EventController {
  static final EventController _instance = EventController._internal();
  final EventService _eventService = EventService();
  factory EventController() => _instance;
  EventController._internal();

  Future<void> insertEventFirestore(Event event) async {
    await _eventService.insertEventFirestore(event);
  }

  Future<Event?> getEventByIdLocal(int id) async {
    return await _eventService.getEventByIdLocal(id);
  }

  Future<Event?> getEventByIdFirestore(int id) async {
    return await _eventService.getEventByIdFirestore(id);
  }

  Future<List<Event>> eventsLocal({required int userId}) async {
    return await _eventService.eventsLocal(userId);
  }

  Future<List<Event>> eventsFirestore({required int userId}) async {
    return await _eventService.eventsFirestore(userId);
  }

  Future<void> updateEventStatus(Event event) async {
    try {
      final now = DateTime.now();
      final dateFormat = DateFormat('yyyy-MM-dd h:mm a');
      final eventDateTime = dateFormat.parse(event.date);
      final isSameDay = now.year == eventDateTime.year &&
          now.month == eventDateTime.month &&
          now.day == eventDateTime.day;

      String newStatus;
      if (eventDateTime.isBefore(now) && !isSameDay) {
        newStatus = 'Past';
      } else if (isSameDay) {
        newStatus = 'Current';
      } else {
        newStatus = 'Upcoming';
      }

      if (event.status != newStatus) {
        await _eventService.updateEventFirestore(event);
      }
    } catch (e) {
      //print('Error updating event status: $e');
    }
  }


  Future<void> updateEventFirestore(Event event) async {
    await _eventService.updateEventFirestore(event);
  }

  Future<void> updatePledgedGiftsWithEventOwner(int eventId, String newName) async {
    await _eventService.updatePledgedGiftsWithEventOwner(eventId, newName);
  }

  Future<void> deleteEventFirestore(String id) async {
    await _eventService.deleteEventFirestore(id);
  }

  Future<int> insertLocalEventTable(Event event) async {
    return await _eventService.insertLocalEventTable(event);
  }

  Future<List<Event>> getLocalEventsTable({required int userId}) async {
    return await _eventService.getLocalEventsTable(userId);
  }

  Future<void> deleteLocalEventTable(int id) async {
    await _eventService.deleteLocalEventTable(id);
  }

  Future<void> publishLocalEventTable(Event event) async {
    await _eventService.publishLocalEventTable(event);
    await deleteLocalEventTable(event.id!);
    await GiftController().deleteGiftsForEventLocalTABLE(event.id!);
  }

  Future<void> updateLocalEventTable(Event event) async {
    await _eventService.updateLocalEventTable(event);
  }

}
