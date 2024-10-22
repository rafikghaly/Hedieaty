import 'package:flutter/material.dart';
import 'models/event.dart';
import 'gift_list.dart';

class EventListPage extends StatefulWidget {
  final List<Event> events;

  const EventListPage({super.key, required this.events});

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
        title: const Text('Event List'),
        backgroundColor: Colors.amber[300],
      ),
      body: Column(
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
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          // Edit event logic
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          // Delete event logic
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GiftListPage(gifts: _events[index].gifts),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Add new event logic
            },
            child: const Text('Add New Event'),
          ),
        ],
      ),
    );
  }
}
