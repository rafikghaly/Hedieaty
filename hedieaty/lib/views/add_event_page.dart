import 'package:flutter/material.dart';
import '../models/event.dart';
import 'package:hedieaty/controllers/repository.dart';

class AddEventPage extends StatefulWidget {
  final int userId;
  final int firebaseId;
  final Function(Event) onEventAdded;

  const AddEventPage({super.key, required this.userId, required this.onEventAdded, required this.firebaseId});

  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  String status = "Upcoming";

  final Repository _repository = Repository();

  void _addEvent() async {
    final String name = nameController.text;
    final String category = categoryController.text;
    final String location = locationController.text;
    final String description = descriptionController.text;
    final String date = dateController.text;

    Event newEvent = Event(
      id: 0, // 0 means it will be auto-incremented in the database
      name: name,
      category: category,
      status: status,
      date: date,
      location: location,
      description: description,
      userId: widget.firebaseId, // Use the actual user ID from the parameter
      gifts: [],
    );

    await _repository.insertEvent(newEvent);
    widget.onEventAdded(newEvent); // Notify the parent about the new event

    Navigator.pop(context); // Go back to the previous screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Event'),
        backgroundColor: Colors.amber[300],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Event Name'),
              ),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(labelText: 'Date'),
              ),
              const SizedBox(height: 10),
              DropdownButton<String>(
                value: status,
                onChanged: (String? newValue) {
                  setState(() {
                    status = newValue!;
                  });
                },
                items: <String>['Upcoming', 'Current', 'Past'].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addEvent,
                child: const Text('Add Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
