import 'package:flutter/material.dart';
import '../models/event.dart';
import 'package:hedieaty/controllers/repository.dart';
import 'package:intl/intl.dart';

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
  late TextEditingController _timeController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;
  late String _selectedStatus;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final Repository _repository = Repository();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.event.name);
    _categoryController = TextEditingController(text: widget.event.category);
    _selectedStatus = widget.event.status;
    _dateController = TextEditingController(text: widget.event.date.split(' ')[0]);
    _timeController = TextEditingController(text: widget.event.date.split(' ').skip(1).join(' '));
    _locationController = TextEditingController(text: widget.event.location);
    _descriptionController = TextEditingController(text: widget.event.description);

    _selectedDate = DateFormat('yyyy-MM-dd').parse(widget.event.date.split(' ')[0]);
    _selectedTime = TimeOfDay(
      hour: int.parse(widget.event.date.split(' ')[1].split(':')[0]),
      minute: int.parse(widget.event.date.split(' ')[1].split(':')[1]),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
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
        _timeController.text = picked.format(context);
      });
    }
  }

  void _editEvent() async {
    final String name = _nameController.text;
    final String category = _categoryController.text;
    final String location = _locationController.text;
    final String description = _descriptionController.text;
    final String date = _dateController.text;
    final String time = _timeController.text;

    if (name.isEmpty || category.isEmpty || location.isEmpty || description.isEmpty || _selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    if (name == widget.event.name &&
        category == widget.event.category &&
        location == widget.event.location &&
        description == widget.event.description &&
        date == widget.event.date.split(' ')[0] &&
        time == widget.event.date.split(' ').skip(1).join(' ') &&
        _selectedStatus == widget.event.status) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No changes made.')),
      );
      Navigator.pop(context);
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

    if (selectedDateTime.isBefore(now)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The event date cannot be in the past. Please select a future date.')),
      );
      return;
    }

    final isSameDay = now.year == _selectedDate!.year &&
        now.month == _selectedDate!.month &&
        now.day == _selectedDate!.day;

    if (isSameDay) {
      _selectedStatus = 'Current';
    } else {
      _selectedStatus = 'Upcoming';
    }

    Event updatedEvent = Event(
      id: widget.event.id,
      docId: widget.event.docId,
      name: name,
      category: category,
      status: _selectedStatus,
      date: '$date $time',
      location: location,
      description: description,
      userId: widget.event.userId,
      gifts: widget.event.gifts,
    );

    await _repository.updateEvent(updatedEvent);
    widget.onEventEdited(updatedEvent);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Event',style: TextStyle(color: Colors.white )),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Event Details',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.amber[800]),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Event Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _categoryController,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _dateController,
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration: InputDecoration(
                  labelText: 'Date',
                  suffixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _timeController,
                readOnly: true,
                onTap: () => _selectTime(context),
                decoration: InputDecoration(
                  labelText: 'Time',
                  suffixIcon: const Icon(Icons.access_time),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                ),
              ),
              const SizedBox(height: 10),

              const SizedBox(height: 10),
              TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _editEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[800],
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    'Save Changes',
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
