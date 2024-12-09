import 'package:flutter/material.dart';
import '../models/gift.dart';
import 'package:hedieaty/controllers/repository.dart';

class AddGiftPage extends StatefulWidget {
  final int eventId;
  final int userId;
  final bool isPrivate;

  const AddGiftPage({super.key, required this.eventId, required this.userId, required this.isPrivate});

  @override
  _AddGiftPageState createState() => _AddGiftPageState();
}

class _AddGiftPageState extends State<AddGiftPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _description = '';
  String _category = '';
  double _price = 0.0;
  String? _imageUrl;

  final Repository _repository = Repository();

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      final newGift = Gift(
        id: null, // ID is auto-generated
        eventId: widget.eventId,
        name: _name,
        description: _description,
        category: _category,
        status: 'available', // Default status to "available"
        price: _price,
        isPledged: false,
        imageUrl: _imageUrl,
        docId: null,
      );

      if (widget.isPrivate) {
        await _repository.insertLocalGift(newGift);
      } else {
        await _repository.insertGift(newGift);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Gift'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
                onSaved: (value) {
                  _description = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a category';
                  }
                  return null;
                },
                onSaved: (value) {
                  _category = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  return null;
                },
                onSaved: (value) {
                  _price = double.parse(value!);
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Image URL'),
                onSaved: (value) {
                  _imageUrl = value;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Add Gift'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
