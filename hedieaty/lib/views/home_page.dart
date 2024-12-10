import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/sync_controller.dart';
import '../models/friend.dart';
import '../models/event.dart';
import '../models/user.dart';
import 'event_list.dart';
import 'sign_in_page.dart';
import 'package:hedieaty/controllers/repository.dart';

class HomePage extends StatefulWidget {
  final List<Friend> friends;
  final int userId;
  final int firebaseId;

  const HomePage({super.key, required this.friends, required this.userId, required this.firebaseId});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Friend> filteredFriends = [];
  List<Event> userEvents = [];
  TextEditingController searchController = TextEditingController();
  String currentUserName = ''; // Initialize with an empty string (for late errors)

  final Repository _repository = Repository();

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _fetchFriends();
    _fetchUserEvents();
  }

  void _fetchUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userName = prefs.getString('userName');
    if (userName != null) {
      setState(() {
        currentUserName = userName;
      });
    }
  }

  Future<void> _fetchFriends() async {
    List<Friend> friends = await _repository.getFriends(widget.firebaseId);
    setState(() {
      filteredFriends = friends;
    });
  }

  void _fetchUserEvents() async {
    List<Event> events = await _repository.getEvents(userId: widget.firebaseId);
    setState(() {
      userEvents = events;
    });
  }

  void _filterFriends(String query) async {
    if (query.isEmpty) {
      await _fetchFriends();
    } else {
      List<Friend> friends = await _repository.getFriends(widget.firebaseId);
      List<User> users = await _repository.getUsers();
      setState(() {
        filteredFriends = friends.where((friend) {
          User? friendUser = users.firstWhere(
                (user) => user.id == (friend.userId1 == widget.firebaseId ? friend.userId2 : friend.userId1),
          );
          String emailWithoutDomain = friendUser.email.split('@')[0];
          return (friendUser.name.toLowerCase().contains(query.toLowerCase()) ||
              emailWithoutDomain.toLowerCase().contains(query.toLowerCase()) ||
              friendUser.phoneNumber?.contains(query) == true);
        }).toList();
      });
    }
  }

  Future<void> _addFriendByEmail(String email) async {
    User? newUser = await _repository.getUserByEmail(email);

    if (newUser != null) {
      // Check if the user is trying to add themselves as a friend
      if (newUser.id == widget.firebaseId) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You cannot add yourself as a friend')),
        );
        return;
      }

      await _repository.addMutualFriends(widget.firebaseId, newUser.id!, currentUserName, newUser.name);

      // Refresh the friend list
      _fetchFriends();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User does not exist')),
      );
    }
  }

  void _showAddFriendDialog() {
    TextEditingController contactController = TextEditingController();
    bool isPhoneNumber = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Add New Friend'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: contactController,
                    decoration: InputDecoration(
                      hintText: isPhoneNumber ? 'Enter friend\'s phone number' : 'Enter friend\'s email',
                    ),
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: isPhoneNumber,
                        onChanged: (bool? value) {
                          setState(() {
                            isPhoneNumber = value ?? false;
                            contactController.clear();
                          });
                        },
                      ),
                      const Text('Add by phone number'),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (isPhoneNumber) {
                      _addFriendByPhoneNumber(contactController.text);
                    } else {
                      _addFriendByEmail(contactController.text);
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }


  Future<void> _addFriendByPhoneNumber(String phoneNumber) async {
    User? newUser = await _repository.getUserByPhoneNumber(phoneNumber);

    // Check if the user is trying to add themselves as a friend
    if (newUser?.id == widget.firebaseId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You cannot add yourself as a friend')),
      );
      return;
    }

    await _repository.addMutualFriends(widget.firebaseId, newUser!.id!, currentUserName, newUser.name);

    // Refresh the friend list
    _fetchFriends();
    }

  Future<void> _logout(BuildContext context) async {
    //TODO SYNC WHEN MAKING LOCAL EVENT
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult[0] != ConnectivityResult.none) {
      SyncController syncController = SyncController();
      await syncController.syncUserData(widget.firebaseId);
      // print('User data synchronized successfully.');
    } else {
      // print('No network connection. Skipping synchronization.');
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignInPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.amber[300],
        shadowColor: Colors.black45,
        elevation: 20,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            color: Colors.white,
          ),
        ],
        title: Row(
          children: [
            Image.asset(
              'assets/images/Logo-White.png',
              height: 40,
            ),
          ],
        ),
        centerTitle: true,
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

      body: RefreshIndicator(
        onRefresh: _fetchFriends,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TextField(
                    controller: searchController,
                    onChanged: (query) => _filterFriends(query),
                    decoration: const InputDecoration(
                      labelText: 'Search Friends',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.search),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: filteredFriends.isEmpty
                  ? const Center(child: Text('No friends available.'))
                  : ListView.builder(
                itemCount: filteredFriends.length,
                itemBuilder: (context, index) {
                  return FriendFrame(
                    friend: filteredFriends[index],
                    userId: widget.firebaseId,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddFriendDialog,
        backgroundColor: Colors.amber[800],
        icon: const Icon(Icons.person_add,color: Colors.white,),
        label: const Text('New Friend',style: TextStyle(color: Colors.white),),
      ),
    );
  }
}

class FriendFrame extends StatelessWidget {
  final Friend friend;
  final int userId;

  FriendFrame({super.key, required this.friend, required this.userId});

  final Repository _repository = Repository();

  Future<String> _fetchFriendName(int friendUserId) async {
    User? friendUser = await _repository.getUserById(friendUserId);
    if (friendUser?.name ==null)
      {
        return await _repository.getFriendNameByIdLocal(friendUserId)?? "Unknown";
      }
    return friendUser?.name ?? 'Unknown';
  }

  Future<String?> _fetchFriendProfileImage(int friendUserId) async {
    return await _repository.getUserProfileImage(friendUserId);
  }

  @override
  Widget build(BuildContext context) {
    int friendUserId = friend.userId1 == userId ? friend.userId2 : friend.userId1;

    return FutureBuilder<Map<String, dynamic>>(
      future: Future.wait([
        _fetchFriendName(friendUserId),
        _fetchFriendProfileImage(friendUserId)
      ]).then((results) {
        return {
          'friendName': results[0] as String,
          'friendProfileImage': results[1]
        };
      }),
      builder: (context, snapshot) {
        String friendName = 'Loading...';
        String? friendProfileImage;

        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          friendName = snapshot.data!['friendName'];
          friendProfileImage = snapshot.data!['friendProfileImage'];
        }

        return ListTile(
          leading: GestureDetector(
            onTap: () {
              if (friendProfileImage != null) {
                showDialog(
                  context: context,
                  builder: (context) => Dialog(
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20.0),
                                child: Image.memory(base64Decode(friendProfileImage!)),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white, size: 30),
                            onPressed: () {
                              Navigator.pop(context);
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
              backgroundImage: friendProfileImage != null
                  ? MemoryImage(base64Decode(friendProfileImage))
                  : const AssetImage('assets/images/profile-default.png'),
            ),
          ),
          title: Text(
            friendName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            friend.upcomingEvents > 0
                ? 'Upcoming Events: ${friend.upcomingEvents}'
                : 'No Upcoming Events',
          ),
          trailing: friend.upcomingEvents > 0
              ? Text(
            friend.upcomingEvents.toString(),
            style: TextStyle(color: Colors.amber[800], fontWeight: FontWeight.bold),
          )
              : null,
          onTap: () async {
            // Fetch friend's events using their userId
            List<Event> friendEvents = await _repository.getEvents(userId: friendUserId);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EventListPage(events: friendEvents, userId: friendUserId, isOwner: false, firebaseId:friendUserId,),
              ),
            );
          },
        );
      },
    );
  }
}
