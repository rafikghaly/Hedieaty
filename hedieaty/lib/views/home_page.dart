import 'package:flutter/material.dart';
import '../models/friend.dart';
import '../models/event.dart';
import '../models/gift.dart';
import 'event_list.dart';
import 'sign_in_page.dart';
import 'add_event_page.dart'; // Import AddEventPage
import '../controllers/friend_controller.dart';
import '../controllers/event_controller.dart';

class HomePage extends StatefulWidget {
  final List<Friend> friends;
  final int userId;

  const HomePage({super.key, required this.friends, required this.userId});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Friend> filteredFriends = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredFriends = widget.friends;
  }

  void _filterFriends(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredFriends = widget.friends;
      } else {
        filteredFriends = widget.friends
            .where((friend) => friend.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _onEventAdded(Event event) {
    setState(() {
      // Optionally, refresh the friend list or just add the new event to the list for immediate feedback
    });
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
      body: Column(
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
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddEventPage(
                        userId: widget.userId,
                        onEventAdded: _onEventAdded,
                      )),
                    ).then((_) {
                      setState(() {});  // Refresh the page to show the new event
                    });
                  },
                  child: Text(
                    'Create Your Own Event/List',
                    style: TextStyle(color: Colors.brown[400]),
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
                return FriendFrame(friend: filteredFriends[index], userId: widget.userId);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO Add friend manually
        },
        backgroundColor: Colors.amber[300],
        icon: const Icon(Icons.person_add),
        label: const Text('New Friend'),
      ),
    );
  }
}

class FriendFrame extends StatelessWidget {
  final Friend friend;
  final int userId; // Add userId to be passed to EventListPage
  const FriendFrame({super.key, required this.friend, required this.userId});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: AssetImage(friend.picture),
      ),
      title: Text(
        friend.name,
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
        List<Event> friendEvents = await EventController().events(userId: friend.userId);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventListPage(events: friendEvents, userId: userId),
          ),
        );
      },
    );
  }
}
