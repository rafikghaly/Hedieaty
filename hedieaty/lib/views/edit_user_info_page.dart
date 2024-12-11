import 'package:flutter/material.dart';
import '../models/user.dart';
import 'package:hedieaty/controllers/repository.dart';

class EditUserInfoPage extends StatefulWidget {
  final User user;

  const EditUserInfoPage({super.key, required this.user});

  @override
  _EditUserInfoPageState createState() => _EditUserInfoPageState();
}

class _EditUserInfoPageState extends State<EditUserInfoPage> {
  final _formKey = GlobalKey<FormState>();
  late String? _userName;
  late String? _preferences;
  late String? _phoneNumber;
  late String? _password;
  final Repository _repository = Repository();

  @override
  void initState() {
    super.initState();
    _userName = widget.user.name;
    _preferences = widget.user.preferences;
    _phoneNumber = widget.user.phoneNumber;
    _password = null;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      if (_userName == widget.user.name && _phoneNumber == widget.user.phoneNumber) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('No Changes'),
              content: const Text('No changes were made. Please update your information if you want to make changes.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
        return;
      }

      User? existingUser =
          await _repository.getUserByPhoneNumber(_phoneNumber ?? '');
      if (existingUser != null && existingUser.id != widget.user.id) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Phone Number Exists'),
              content: const Text(
                  'The phone number you entered is already in use. Please use a different phone number.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
        return;
      }

      final updatedUser = User(
        id: widget.user.id,
        firebaseUid: widget.user.firebaseUid,
        name: _userName ?? widget.user.name,
        email: widget.user.email,
        phoneNumber: _phoneNumber ?? widget.user.phoneNumber,
        preferences: _preferences ?? widget.user.preferences,
        password: _password ?? widget.user.password,
      );

      await _repository.updateUser(updatedUser);

      Navigator.pop(context, updatedUser);
    }
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    final regex = RegExp(r'^[0-9]{11}$');
    if (!regex.hasMatch(value)) {
      return 'Please enter a valid phone number (e.g., 01234567890)';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Edit User Information',style: TextStyle(color: Colors.white)),
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Update Your Information',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.amber[800]),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  initialValue: _userName,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                  ),
                  onSaved: (value) {
                    _userName = value!.isEmpty ? null : value;
                  },
                  validator: _validateName,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  initialValue: _phoneNumber,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                  ),
                  onSaved: (value) {
                    _phoneNumber = value!.isEmpty ? null : value;
                  },
                  validator: _validatePhoneNumber,
                ),
                const SizedBox(height: 20),
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
