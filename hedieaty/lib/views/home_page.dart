import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/friend.dart';
import '../models/event.dart';
import '../models/user.dart';
import 'event_list.dart';
import 'sign_in_page.dart';
import '../controllers/friend_controller.dart';
import '../controllers/user_controller.dart';
import '../controllers/event_controller.dart';

// TODO Fix Search Functionality
class HomePage extends StatefulWidget {
  final List<Friend> friends;
  final int userId;

  const HomePage({super.key, required this.friends, required this.userId});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Friend> filteredFriends = [];
  List<Event> userEvents = [];
  TextEditingController searchController = TextEditingController();
  String currentUserName = ''; // Initialize with an empty string

  @override
  void initState() {
    super.initState();
    _fetchUserName(); // Load the user name
    _fetchFriends(); // Fetch all friends for the logged-in user
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
    List<Friend> friends = await FriendController().friends(widget.userId);
    setState(() {
      filteredFriends = friends;
    });
  }

  void _fetchUserEvents() async {
    List<Event> events = await EventController().events(userId: widget.userId);
    setState(() {
      userEvents = events;
    });
  }

  void _filterFriends(String query) {
    setState(() {
      if (query.isEmpty) {
        _fetchFriends(); // Refresh the friends list
      } else {
        filteredFriends = filteredFriends
            .where((friend) => friend.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> _addFriendByEmail(String email) async {
    UserController userController = UserController();
    FriendController friendController = FriendController();
    User? newUser = await userController.getUserByEmail(email);

    if (newUser != null) {
      // Check if the user is trying to add themselves as a friend
      if (newUser.id == widget.userId) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You cannot add yourself as a friend')),
        );
        return;
      }

      await friendController.addMutualFriends(widget.userId, newUser.id!, currentUserName, newUser.name);

      // Refresh the friend list
      _fetchFriends();
    } else {
      // Show a message that user does not exist
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User does not exist')),
      );
    }
  }

  void _showAddFriendDialog() {
    TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Friend'),
          content: TextField(
            controller: emailController,
            decoration: const InputDecoration(
              hintText: 'Enter friend\'s email',
            ),
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
                _addFriendByEmail(emailController.text);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignInPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber[300],
        shadowColor: Colors.black45,
        elevation: 20,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
        title: Row(
          children: [
            Image.asset(
              'assets/images/Logo.png',
              height: 40,
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchFriends, // Trigger the refresh when the list is pulled down
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
                    userId: widget.userId,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddFriendDialog,
        backgroundColor: Colors.amber[300],
        icon: const Icon(Icons.person_add),
        label: const Text('New Friend'),
      ),
    );
  }
}

class FriendFrame extends StatelessWidget {
  final Friend friend;
  final int userId;

  const FriendFrame({super.key, required this.friend, required this.userId});

  Future<String> _fetchFriendName(int friendUserId) async {
    UserController userController = UserController();
    User? friendUser = await userController.getUserById(friendUserId);
    return friendUser?.name ?? 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    int friendUserId = friend.userId1 == userId ? friend.userId2 : friend.userId1;

    return FutureBuilder<String>(
      future: _fetchFriendName(friendUserId),
      builder: (context, snapshot) {
        String friendName = 'Loading...';
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          friendName = snapshot.data!;
        }

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: AssetImage(friend.picture),
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
            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          )
              : null,
          onTap: () async {
            // Fetch friend's events using their userId
            List<Event> friendEvents = await EventController().events(userId: friendUserId);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EventListPage(events: friendEvents, userId: friendUserId,isOwner: false,),
              ),
            );
          },
        );
      },
    );
  }
}
