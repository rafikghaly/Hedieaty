import 'package:flutter/material.dart';
import 'event.dart';

class EventListPage extends StatefulWidget {
  final List<Event> events;

  EventListPage({required this.events});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text('Sort by:'),
                SizedBox(width: 10),
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
            child: ListView.builder(
              itemCount: _events.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_events[index].name),
                  subtitle: Text('${_events[index].category} - ${_events[index].status}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          // Edit event logic
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          // Delete event logic
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Add new event logic
            },
            child: Text('Add New Event'),
          ),
        ],
      ),
    );
  }
}
