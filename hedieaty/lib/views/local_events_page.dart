import 'package:flutter/material.dart';
import '../models/event.dart';
import 'package:hedieaty/controllers/repository.dart';
import 'edit_event_page.dart';
import 'local_gift_list_page.dart';
import 'add_event_page.dart';

class LocalEventsPage extends StatefulWidget {
  final int userId;
  const LocalEventsPage({super.key, required this.userId});

  @override
  _LocalEventsPageState createState() => _LocalEventsPageState();
}

class _LocalEventsPageState extends State<LocalEventsPage> {
  List<Event> _localEvents = [];
  String _selectedSortOption = 'Name';
  final Repository _repository = Repository();

  @override
  void initState() {
    super.initState();
    _fetchLocalEvents();
  }

  void _sortEvents(String sortOption) {
    setState(() {
      _selectedSortOption = sortOption;
      if (sortOption == 'Name') {
        _localEvents.sort((a, b) => a.name.compareTo(b.name));
      } else if (sortOption == 'Category') {
        _localEvents.sort((a, b) => a.category.compareTo(b.category));
      } else if (sortOption == 'Status') {
        _localEvents.sort((a, b) => a.status.compareTo(b.status));
      }
    });
  }

  Future<void> _fetchLocalEvents() async {
    try {
      List<Event> localEvents = await _repository.getLocalEventsTable(widget.userId);
      setState(() {
        _localEvents = localEvents;
      });
    } catch (e) {
      //print('Error fetching local events: $e');
    }
  }

  Future<void> _publishEvent(Event event) async {
    try {
      await _repository.publishEventTable(event);
      _fetchLocalEvents();
    } catch (e) {
      //print('Error publishing event: $e');
    }
  }

  void _editLocalEvent(Event event) async {
    bool? edited = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditEventPage(
          event: event,
          onEventEdited: (editedEvent) async {
            await _repository.updateLocalEventTable(editedEvent);
            _fetchLocalEvents();
          },
        ),
      ),
    );

    if (edited == true) {
      _fetchLocalEvents();
    }
  }

  Future<void> _deleteLocalEvent(Event event) async {
    await _repository.deleteLocalEventTable(event.id!);
    setState(() {
      _localEvents.remove(event);
    });
    _fetchLocalEvents();
  }

  void _addNewEvent() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEventPage(
          userId: widget.userId,
          onEventAdded: (newEvent) {
            _fetchLocalEvents();
          }, firebaseId: widget.userId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Local Events',style: TextStyle(color: Colors.white )),
        backgroundColor: Colors.amber[700],
        elevation: 10.0,
        shadowColor: Colors.black,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[Color(0xFFFE6B8B), Color(0xFFFF8E53)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchLocalEvents,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Text('Sort by:'),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: _selectedSortOption,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        _sortEvents(newValue);
                      }
                    },
                    items: <String>['Name', 'Category', 'Status']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _localEvents.isEmpty
                  ? const Center(child: Text('No local events available.'))
                  : ListView.builder(
                itemCount: _localEvents.length,
                itemBuilder: (context, index) {
                  final event = _localEvents[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 12.0),
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16.0),
                      leading: Icon(
                        Icons.event,
                        size: 40.0,
                        color: Colors.amber[800],
                      ),
                      title: Text(
                        event.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                          color: Colors.amber[800],
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Category: ${event.category}'),
                          Text('Status: ${event.status}'),
                          Text('Date: ${event.date}'),
                          Text('Location: ${event.location}'),
                          Text('Description: ${event.description}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              _editLocalEvent(event);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              _deleteLocalEvent(event);
                            },
                          ),
                          ElevatedButton(
                            onPressed: () => _publishEvent(event),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber[800],
                            ),
                            child: const Text('Publish',style: TextStyle(color: Colors.white),),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LocalGiftListPage(
                              eventId: event.id!,
                              isPrivate: true, userId: widget.userId, eventName: event.name,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(17),
              child: ElevatedButton(
                onPressed: _addNewEvent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[800],
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'Add New Event',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
