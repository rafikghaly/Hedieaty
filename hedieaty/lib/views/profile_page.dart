import 'dart:io';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';
import '../models/gift.dart';
import '../models/user.dart';
import 'my_pledged_gifts_page.dart';
import 'local_events_page.dart';
import 'edit_user_info_page.dart';
import 'package:hedieaty/controllers/repository.dart';
import 'package:hedieaty/controllers/theme_notifier.dart';

class ProfilePage extends StatefulWidget {
  final String userName;
  final String email;
  final List<Event> userEvents;
  final List<Gift> pledgedGifts;

  const ProfilePage({
    super.key,
    required this.userName,
    required this.email,
    required this.userEvents,
    required this.pledgedGifts,
  });

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String _userName;
  late String _email;
  late String _phoneNumber;
  late int? _firebaseId;
  late String _firebaseUid;
  late String _profileImageBase64;

  final Repository _repository = Repository();

  @override
  void initState() {
    super.initState();
    _userName = '';
    _email = '';
    _phoneNumber = '';
    _profileImageBase64 = '';
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _firebaseId = prefs.getInt('firebaseId');
      _firebaseUid = prefs.getString('firebaseUId')!;
      _userName = prefs.getString('userName') ?? '';
      _email = prefs.getString('email') ?? '';
      _phoneNumber = prefs.getString('phoneNumber') ?? '';
      _profileImageBase64 = prefs.getString('profileImageBase64') ?? '';
    });
  }

  Future<void> _editUserInfo() async {
    final user = User(
      id: _firebaseId?.hashCode ?? 0,
      firebaseUid: _firebaseUid ?? '',
      name: _userName,
      email: _email,
      phoneNumber: _phoneNumber,
      preferences: 'Default Preferences',
      password: '******',
    );

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditUserInfoPage(user: user),
      ),
    );

    if (result != null && result is User) {
      setState(() {
        _userName = result.name;
        _email = result.email;
        _phoneNumber = result.phoneNumber!;
        // Save the updated information to SharedPreferences
        _saveUserData(result.firebaseUid, result.name, result.email, result.phoneNumber!);
      });
      // Update the user information in the repository
      await _repository.updateUser(result);
    }
  }

  Future<void> _saveUserData(String firebaseUid, String userName, String email, String phoneNumber) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('firebaseUid', firebaseUid);
    await prefs.setString('userName', userName);
    await prefs.setString('email', email);
    await prefs.setString('phoneNumber', phoneNumber);
  }

  Future<void> _pickAndSaveImage() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult[0] == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot proceed while offline. Please check your network connection.')),
      );
      return;
    }

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
          _profileImageBase64 = base64String;
        });

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('profileImageBase64', base64String);
        await _saveProfileImageToFirestore(base64String);

      } else {
        //print('Failed to decode image');
      }
    }
  }

  Future<void> _saveProfileImageToFirestore(String base64String) async {
    int userIntID = int.parse(_firebaseUid);

    var querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('id', isEqualTo: userIntID)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      var docSnapshot = querySnapshot.docs.first;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(docSnapshot.id)
          .update({'profileImageBase64': base64String});
    } else {
      //print('No user found with firebaseUid: $_firebaseUid');
    }
  }

  ImageProvider _decodeProfileImage(String base64String) {
    try {
      return MemoryImage(base64Decode(base64String));
    } catch (e) {
      //print('Error decoding base64 image data: $e');
      return const AssetImage('assets/images/profile-default.png');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title:
        const Text('Profile Page', style: TextStyle(color: Colors.white)),
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
      body: SizedBox(
        child: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
          SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              children: [
                SingleChildScrollView(
                  child: GestureDetector(
                    onTap: _pickAndSaveImage,
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          child: GestureDetector(
                            onTap: () {
                              if (_profileImageBase64.isEmpty) {
                                _pickAndSaveImage();
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (context) => Dialog(
                                    child: Stack(
                                      children: [
                                        SingleChildScrollView(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Image.memory(base64Decode(_profileImageBase64)),
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          top: 10,
                                          right: 10,
                                          child: IconButton(
                                            icon: const Icon(Icons.edit, color: Colors.white, size: 30),
                                            onPressed: () {
                                              Navigator.pop(context);
                                              _pickAndSaveImage();
                                            },
                                            padding: const EdgeInsets.all(0),
                                            constraints: const BoxConstraints(),
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                            },
                            child: CircleAvatar(
                              radius: 70,
                              backgroundImage: _profileImageBase64.isNotEmpty
                                  ? _decodeProfileImage(_profileImageBase64)
                                  : const AssetImage('assets/images/profile-default.png'),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                            onPressed: _pickAndSaveImage,
                            padding: const EdgeInsets.all(0),
                            constraints: const BoxConstraints(),
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(_userName,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
                Text(_email,
                    style: const TextStyle(fontSize: 16,fontWeight: FontWeight.w300)),
                Text(_phoneNumber,
                    style:  const TextStyle(fontSize: 16, fontWeight: FontWeight.w300 )),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _editUserInfo,
                  icon: const Icon(Icons.edit, color: Colors.white),
                  label: const Text('Edit Personal Information',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrangeAccent[100],
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    if (_firebaseId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MyPledgedGiftsPage(userId: _firebaseId!, username: _userName),
                        ),
                      );
                    } else {
                      // Handle case where firebaseUid is null
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('User ID is not available.')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrangeAccent[100],
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text('My Pledged Gifts',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    if (_firebaseId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              LocalEventsPage(userId: _firebaseId!),
                        ),
                      );
                    } else {
                      // Handle case where firebaseUid is null
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('User ID is not available.')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrangeAccent[100],
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text('My Private Events',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
                const SizedBox(height: 20),
                 // DON'T MAKE CONST!!
                 ListTile(
                  title: Text('Dark Mode'),
                  trailing: ThemeSwitch(),
                ),
              ],
            ),
          ),
          )],
        ),
      ),
    ),
    );
  }
}


