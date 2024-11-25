import 'package:flutter/material.dart';
import '../models/user.dart';
import '../controllers/user_controller.dart';

class EditUserInfoPage extends StatefulWidget {
  final User user;

  const EditUserInfoPage({super.key, required this.user});

  @override
  _EditUserInfoPageState createState() => _EditUserInfoPageState();
}

class _EditUserInfoPageState extends State<EditUserInfoPage> {
  final _formKey = GlobalKey<FormState>();
  late String? _userName;
  late String? _email;
  late String? _preferences;
  late String? _password;

  @override
  void initState() {
    super.initState();
    _userName = widget.user.name;
    _email = widget.user.email;
    _preferences = widget.user.preferences;
    _password = null; // Initialize as null
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      final updatedUser = User(
        id: widget.user.id,
        name: _userName ?? widget.user.name,
        email: _email ?? widget.user.email,
        preferences: _preferences ?? widget.user.preferences,
        password: _password ?? widget.user.password, // Use existing password if none entered
      );

      await UserController().updateUser(updatedUser);

      Navigator.pop(context, updatedUser);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit User Information'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _userName,
                decoration: const InputDecoration(labelText: 'Name (optional)'),
                onSaved: (value) {
                  _userName = value!.isEmpty ? null : value;
                },
              ),
              TextFormField(
                initialValue: _email,
                decoration: const InputDecoration(labelText: 'Email (optional)'),
                onSaved: (value) {
                  _email = value!.isEmpty ? null : value;
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
