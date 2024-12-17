import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import '../controllers/permissions.dart';
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
  String _category = 'Electronics';
  double _price = 0.0;
  String? _imageBase64;
  bool _isLoading = false;

  final List<String> _categories = [
    'Electronics',
    'Clothing',
    'Toys',
    'Books',
    'Home Decor',
    'Beauty & Personal Care',
    'Food & Beverages',
    'Sports & Outdoors',
    'Gift Cards',
    'Music & Movies',
    'Other',
  ];

  final Repository _repository = Repository();

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      final newGift = Gift(
        id: null, // ID is auto-generated
        eventId: widget.eventId,
        name: _name,
        description: _description,
        category: _category,
        status: 'available', // Default status to "available"
        price: _price,
        isPledged: false,
        imageUrl: _imageBase64,
        docId: null,
      );

      try {
        if (widget.isPrivate) {
          await _repository.insertLocalGift(newGift);
        } else {
          await _repository.insertGift(newGift);
        }
        Navigator.pop(context);
      } catch (e) {
        //print('Error adding gift: $e');
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    if (await Permissions.requestPermissions(context)) {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );

      if (pickedFile != null) {
        final File file = File(pickedFile.path);
        final bytes = await file.readAsBytes();

        // Convert image to (JPEG)
        img.Image? image = img.decodeImage(bytes);
        if (image != null) {
          final jpgBytes = img.encodeJpg(image, quality: 75);
          final base64String = base64Encode(jpgBytes);

          if (mounted) {
            setState(() {
              _imageBase64 = base64String;
              _isLoading = false;
            });
          }
        } else {
          //print('Failed to decode image');
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permissions denied. Gallery access is required to upload images.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Add Gift', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.amber[800],
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
                  'Add a New Gift!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.amber[800]),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  key: const Key('GiftTitleField'), // For testing
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
                  key: const Key('GiftDescriptionField'), // For testing
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
                // Dropdown for category
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _category = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _category = value!;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  key: const Key('GiftPriceField'), // For testing
                  decoration: InputDecoration(
                    labelText: 'Price',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a price';
                    }
                    try {
                      double.parse(value);
                    } catch (e) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _price = double.parse(value!);
                  },
                ),
                const SizedBox(height: 10),
                TextButton(
                  key: const Key('GiftUploadImageButton'), // For testing
                  onPressed: _pickAndUploadImage,
                  child: Text(_imageBase64 == null ? 'Upload Image' : 'Change Image'),
                ),
                if (_imageBase64 != null)
                  Image.memory(base64Decode(_imageBase64!)),
                const SizedBox(height: 20),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
                if (!_isLoading)
                  Center(
                    child: ElevatedButton(
                      key: const Key('SaveGiftButton'), // For testing
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
