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
  final UserController _userController = UserController();

  @override
  void initState() {
    super.initState();
    _userName = widget.user.name;
    _email = widget.user.email;
    _preferences = widget.user.preferences;
    _password = null;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      if (_userName == widget.user.name && _email == widget.user.email) {
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

      if (_email != widget.user.email) {
        bool emailExists = await _userController.emailExists(_email ?? '', widget.user.id!);

        if (emailExists) {
          // Alert if the email already exists
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Email Exists'),
                content: const Text('The email you entered is already in use. Please use a different email.'),
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
      }

      // Update user information if the name or email is different
      final updatedUser = User(
        id: widget.user.id,
        name: _userName ?? widget.user.name,
        email: _email ?? widget.user.email,
        preferences: _preferences ?? widget.user.preferences,
        password: _password ?? widget.user.password,
      );

      await _userController.updateUser(updatedUser);

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
                decoration: const InputDecoration(labelText: 'Name'),
                onSaved: (value) {
                  _userName = value!.isEmpty ? null : value;
                },
              ),
              TextFormField(
                initialValue: _email,
                decoration: const InputDecoration(labelText: 'Email'),
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
