import 'package:flutter/material.dart';
import '../models/user.dart';
import 'package:hedieaty/controllers/repository.dart';
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
  final Repository _repository = Repository();
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
        bool emailExists = await _userController.emailExists(_email ?? '', widget.user.firebaseUid.hashCode);

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
        firebaseUid: widget.user.firebaseUid,
        name: _userName ?? widget.user.name,
        email: _email ?? widget.user.email,
        preferences: _preferences ?? widget.user.preferences,
        password: _password ?? widget.user.password,
      );

      await _repository.updateUser(updatedUser);

      Navigator.pop(context, updatedUser);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit User Information'),
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
              ),
              const SizedBox(height: 10),
              TextFormField(
                initialValue: _email,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                ),
                onSaved: (value) {
                  _email = value!.isEmpty ? null : value;
                },
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
    );
  }
}
