import 'package:flutter/material.dart';
import '../models/event.dart';
import 'gift_list.dart';
import '../controllers/event_controller.dart';
import 'add_event_page.dart';

class EventListPage extends StatefulWidget {
  final List<Event> events;
  final int userId;

  const EventListPage({super.key, required this.events, required this.userId});

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
    List<Event> updatedEvents = await EventController().events(userId: widget.userId);
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

  void _editEvent(Event event) {
    // Logic for editing the event
    // You might want to navigate to a new page for event editing
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
        onRefresh: _refreshEvents, // Trigger the refresh when the list is pulled down
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
                  final bool isOwner = event.userId == widget.userId; //TODO Check if the event belongs to the user
                  print(event.userId);
                  print(widget.userId);

                  return ListTile(
                    title: Text(event.name),
                    subtitle: Text(
                      '${event.category} - ${event.status}',
                    ),
                    trailing: isOwner
                        ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _editEvent(event);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _deleteEvent(event);
                          },
                        ),
                      ],
                    )
                        : null,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GiftListPage(gifts: event.gifts),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: _addNewEvent,
                child: const Text('Add New Event'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
