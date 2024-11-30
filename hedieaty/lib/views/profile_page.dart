import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event.dart';
import '../models/gift.dart';
import '../models/user.dart';
import 'my_pledged_gifts_page.dart';
import 'gift_list.dart';
import 'edit_user_info_page.dart';
import 'package:hedieaty/controllers/repository.dart';

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
  String? _firebaseUid;

  final Repository _repository = Repository();

  @override
  void initState() {
    super.initState();
    _userName = '';
    _email = '';
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _firebaseUid = prefs.getString('firebaseUid');
      _userName = prefs.getString('userName') ?? '';
      _email = prefs.getString('email') ?? '';
    });
  }

  Future<void> _editUserInfo() async {
    final user = User(
      id: _firebaseUid!.hashCode,
      firebaseUid: _firebaseUid!,
      name: _userName,
      email: _email,
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
        // Save the updated information to SharedPreferences
        _saveUserData(result.firebaseUid, result.name, result.email);
      });
      // Update the user information in the repository
      await _repository.updateUser(result);
    }
  }

  Future<void> _saveUserData(String firebaseUid, String userName, String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('firebaseUid', firebaseUid);
    await prefs.setString('userName', userName);
    await prefs.setString('email', email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Page'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/Rafik.jpg'),
            ),
            const SizedBox(height: 20),
            Text(_userName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(_email, style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _editUserInfo,
              icon: const Icon(Icons.edit),
              label: const Text('Edit Personal Information'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyPledgedGiftsPage(userId: _firebaseUid!.hashCode),
                  ),
                );
              },
              child: const Text('My Pledged Gifts'),
            ),
            const SizedBox(height: 20),
            const Text('My Events', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.userEvents.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(widget.userEvents[index].name),
                    subtitle: Text('${widget.userEvents[index].category} - ${widget.userEvents[index].status}'),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GiftListPage(
                            eventId: widget.userEvents[index].id!,
                            userId: widget.userEvents[index].userId,
                            isOwner: true,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
