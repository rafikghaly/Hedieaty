import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hedieaty/controllers/gift_controller.dart'; // Import the controller
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
  String? _imageBase64;

  final Repository _repository = Repository();
  final GiftController _giftController = GiftController(); // Instantiate the controller

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
        imageUrl: _imageBase64, // Use _imageBase64 instead of URL
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

  Future<void> _pickAndUploadImage() async {
    final imageBase64 = await _repository.pickAndConvertImageToBase64();
    if (imageBase64 != null) {
      setState(() {
        _imageBase64 = imageBase64;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Gift', style: TextStyle(color: Colors.white)),
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
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add a New Gift !',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.amber[800]),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                  ),
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
                const SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                  ),
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
                const SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                  ),
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
                const SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Price',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                  ),
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
                const SizedBox(height: 10),
                TextButton(
                  onPressed: _pickAndUploadImage,
                  child: Text(_imageBase64 == null ? 'Upload Image' : 'Change Image'),
                ),
                if (_imageBase64 != null)
                  Image.memory(base64Decode(_imageBase64!)),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[800],
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                    ),
                    child: const Text(
                      'Add Gift',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
