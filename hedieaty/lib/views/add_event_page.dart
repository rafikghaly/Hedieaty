import 'package:flutter/material.dart';
import '../models/event.dart';
import 'package:hedieaty/controllers/repository.dart';
import 'package:intl/intl.dart';

class AddEventPage extends StatefulWidget {
  final int userId;
  final int firebaseId;
  final Function(Event) onEventAdded;

  const AddEventPage(
      {super.key,
      required this.userId,
      required this.onEventAdded,
      required this.firebaseId});

  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  String status = "Upcoming";
  bool isPrivate = true; // Default to private event
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  final Repository _repository = Repository();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        timeController.text = picked.format(context);
      });
    }
  }

  Future<void> _addEvent() async {
    final String name = nameController.text;
    final String category = categoryController.text;
    final String location = locationController.text;
    final String description = descriptionController.text;
    final String date = dateController.text;
    final String time = timeController.text;

    if (name.isEmpty || category.isEmpty || location.isEmpty || description.isEmpty || _selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    final now = DateTime.now();
    final selectedDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final isSameDay = now.year == _selectedDate!.year &&
        now.month == _selectedDate!.month &&
        now.day == _selectedDate!.day;

    if (selectedDateTime.isBefore(now) && !isSameDay) {
      status = 'Past';
    } else if (isSameDay) {
      status = 'Current';
    } else {
      status = 'Upcoming';
    }

    Event newEvent = Event(
      id: null, // ID is auto-generated in the database
      name: name,
      category: category,
      status: status,
      date: '$date $time',
      location: location,
      description: description,
      userId: widget.firebaseId, // Use the actual user ID from the parameter
      gifts: [],
      docId: null,
    );

    if (isPrivate) {
      await _repository.insertLocalEventTable(newEvent);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event saved locally.')),
      );
    } else {
      await _repository.insertEvent(newEvent);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event published.')),
      );
    }
    widget.onEventAdded(newEvent); // Notify the parent about the new event

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Event', style: TextStyle(color: Colors.white)),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create a New Event',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.amber[800]),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Event Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: categoryController,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: dateController,
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration: InputDecoration(
                  labelText: 'Date',
                  suffixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: timeController,
                readOnly: true,
                onTap: () => _selectTime(context),
                decoration: InputDecoration(
                  labelText: 'Time',
                  suffixIcon: Icon(Icons.access_time),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                ),
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                title: const Text('Make event private'),
                value: isPrivate,
                onChanged: (bool value) {
                  setState(() {
                    isPrivate = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _addEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[800],
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0)),
                  ),
                  child: const Text(
                    'Add Event',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
