import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import '../controllers/permissions.dart';
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
  late String? _imageBase64;
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

  @override
  void initState() {
    super.initState();
    _name = widget.gift.name;
    _description = widget.gift.description;
    _category = widget.gift.category;
    _price = widget.gift.price;
    _imageBase64 = widget.gift.imageUrl;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      setState(() {
        _isLoading = true;
      });

      final updatedGift = Gift(
        id: widget.gift.id,
        eventId: widget.gift.eventId,
        name: _name,
        description: _description,
        category: _category,
        status: widget.gift.status, // Keep existing status
        isPledged: widget.gift.isPledged, // Keep existing pledge status
        imageUrl: _imageBase64,
        price: _price,
        docId: widget.gift.docId,
      );

      try {
        if (updatedGift.docId == null) {
          // Local gift, update in local database
          await _repository.updateLocalGiftTable(updatedGift);
        } else {
          // Non-local gift, update in Firestore
          await _repository.updateGift(updatedGift);
        }

        widget.onGiftEdited(updatedGift);
        Navigator.pop(context, true);
      } catch (e) {
        //print('Error editing gift: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    setState(() {
      _isLoading = true;
    });

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

          setState(() {
            _imageBase64 = base64String;
            _isLoading = false;
          });
        } else {
          //print('Failed to decode image');
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
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
        title: const Text('Edit Gift', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.amber[800],
        elevation: 10.0,
        shadowColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _submitForm,
            tooltip: 'Save Changes',
            color: Colors.white,
          ),
        ],
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Gift Details',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.amber[800]),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  initialValue: _name,
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
                  initialValue: _description,
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
                // Category Dropdown
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
                  initialValue: _price.toString(),
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
                      onPressed: _submitForm,
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
      ),
    );
  }
}
