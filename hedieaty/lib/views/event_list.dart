import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event.dart';
import 'gift_list.dart';
import '../controllers/event_controller.dart';
import 'add_event_page.dart';
import 'edit_event_page.dart'; // Import the EditEventPage

class EventListPage extends StatefulWidget {
  final List<Event> events;
  final int userId;
  final bool isOwner;

  const EventListPage(
      {super.key,
      required this.events,
      required this.userId,
      required this.isOwner});

  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  late List<Event> _events;
  String _selectedSortOption = 'Name';

  @override
  void initState() {
    super.initState();
    _events = widget.events;
  }

  void _sortEvents(String sortOption) {
    setState(() {
      _selectedSortOption = sortOption;
      if (sortOption == 'Name') {
        _events.sort((a, b) => a.name.compareTo(b.name));
      } else if (sortOption == 'Category') {
        _events.sort((a, b) => a.category.compareTo(b.category));
      } else if (sortOption == 'Status') {
        _events.sort((a, b) => a.status.compareTo(b.status));
      }
    });
  }

  Future<void> _refreshEvents() async {
    List<Event> updatedEvents =
        await EventController().events(userId: widget.userId);
    setState(() {
      _events = updatedEvents;
    });
  }

  void _addNewEvent() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEventPage(
          userId: widget.userId,
          onEventAdded: (event) {
            _refreshEvents(); // Refresh the entire list after adding a new event
          },
        ),
      ),
    );
  }

  void _editEvent(Event event) async {
    bool? edited = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditEventPage(
          event: event,
          onEventEdited: (editedEvent) {
            _refreshEvents(); // Refresh the list after editing the event
          },
        ),
      ),
    );

    // If the event was edited, refresh the event list
    if (edited == true) {
      _refreshEvents();
    }
  }

  Future<void> _deleteEvent(Event event) async {
    await EventController().deleteEvent(event.id!);
    setState(() {
      _events.remove(event);
    });
    // After deletion, refresh the list from the database
    _refreshEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event List'),
        backgroundColor: Colors.amber[300],
        shadowColor: Colors.black45,
      ),
      body: RefreshIndicator(
        onRefresh:
            _refreshEvents, // Trigger the refresh when the list is pulled down
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
              child: _events.isEmpty
                  ? const Center(child: Text('No events available.'))
                  : ListView.builder(
                      itemCount: _events.length,
                      itemBuilder: (context, index) {
                        final event = _events[index];
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
                              color: Colors.amber[500],
                            ),
                            title: Text(
                              event.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                                color: Colors.amber[500],
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
                            trailing: widget.isOwner
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () {
                                          _editEvent(event);
                                        },
                                        color: Colors.blue,
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () {
                                          _deleteEvent(event);
                                        },
                                        color: Colors.red,
                                      ),
                                    ],
                                  )
                                : null,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GiftListPage(
                                      eventId: event.id!,
                                      userId: widget.userId,isOwner: widget.isOwner,),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
            if (widget.isOwner) ...[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: _addNewEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[500],
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
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
          ],
        ),
      ),
    );
  }
}
