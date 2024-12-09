import 'package:flutter/material.dart';
import '../models/gift.dart';
import 'package:hedieaty/controllers/repository.dart';

class EditGiftPage extends StatefulWidget {
  final Gift gift;
  final Function(Gift) onGiftEdited;

  const EditGiftPage({super.key, required this.gift, required this.onGiftEdited});

  @override
  _EditGiftPageState createState() => _EditGiftPageState();
}

class _EditGiftPageState extends State<EditGiftPage> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _description;
  late String _category;
  late double _price;
  late String? _imageUrl;

  final Repository _repository = Repository();

  @override
  void initState() {
    super.initState();
    _name = widget.gift.name;
    _description = widget.gift.description;
    _category = widget.gift.category;
    _price = widget.gift.price;
    _imageUrl = widget.gift.imageUrl;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      final updatedGift = Gift(
        id: widget.gift.id,
        eventId: widget.gift.eventId,
        name: _name,
        description: _description,
        category: _category,
        status: widget.gift.status, // Keep existing status
        isPledged: widget.gift.isPledged, // Keep existing pledge status
        imageUrl: _imageUrl,
        price: _price,
        docId: widget.gift.docId,
      );

      if (updatedGift.docId == null) {
        // Local gift, update in local database
        await _repository.updateLocalGiftTable(updatedGift);
      } else {
        // Non-local gift, update in Firestore
        await _repository.updateGift(updatedGift);
      }

      widget.onGiftEdited(updatedGift);
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Gift'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _name,
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
                initialValue: _description,
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
                initialValue: _category,
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
                initialValue: _price.toString(),
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
                initialValue: _imageUrl,
                decoration: const InputDecoration(labelText: 'Image URL'),
                onSaved: (value) {
                  _imageUrl = value;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
