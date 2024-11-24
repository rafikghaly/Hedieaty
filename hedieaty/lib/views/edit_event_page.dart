import 'package:flutter/material.dart';
import '../models/event.dart';
import '../controllers/event_controller.dart';

class EditEventPage extends StatefulWidget {
  final Event event;
  final Function(Event) onEventEdited;

  const EditEventPage({super.key, required this.event, required this.onEventEdited});

  @override
  _EditEventPageState createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _dateController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;
  late String _selectedStatus;

  final List<String> _statusOptions = ['Upcoming', 'Current', 'Past'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.event.name);
    _categoryController = TextEditingController(text: widget.event.category);
    _selectedStatus = widget.event.status;
    _dateController = TextEditingController(text: widget.event.date);
    _locationController = TextEditingController(text: widget.event.location);
    _descriptionController = TextEditingController(text: widget.event.description);
  }

  void _editEvent() async {
    Event updatedEvent = Event(
      id: widget.event.id,
      name: _nameController.text,
      category: _categoryController.text,
      status: _selectedStatus,
      date: _dateController.text,
      location: _locationController.text,
      description: _descriptionController.text,
      userId: widget.event.userId,
      gifts: widget.event.gifts,
    );

    await EventController().updateEvent(updatedEvent);
    widget.onEventEdited(updatedEvent);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Event'),
        backgroundColor: Colors.amber[300],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Event Name'),
              ),
              TextField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(labelText: 'Status'),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedStatus = newValue!;
                  });
                },
                items: _statusOptions.map((String status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
              ),
              TextField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: 'Date'),
              ),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _editEvent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[500],
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
