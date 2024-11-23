import 'package:flutter/material.dart';
import '../models/friend.dart';
import '../models/event.dart';
import '../models/gift.dart';
import 'event_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Friend> myfriends = [
    Friend(
      name: 'Rafik Ghaly',
      picture: 'assets/images/Rafik.jpg',
      upcomingEvents: 1,
      events: [
        Event(
          name: 'Birthday Party',
          category: 'Birthday',
          status: 'Upcoming',
          gifts: [
            Gift(
                name: 'Toy Car',
                category: 'Toys',
                status: 'available',
                isPledged: false,
                description: 'Awesome car'),
            Gift(
                name: 'Harry Potter Paperback Box Set',
                category: 'Books',
                status: 'available',
                isPledged: true,
                description: 'All 7 books of Harry Potter'),
          ],
        ),
      ],
    ),
    Friend(
      name: 'Youssef Ghaly',
      picture: 'assets/images/Youssef.jpg',
      upcomingEvents: 0,
      events: [],
    ),
  ];

  List<Friend> filteredFriends = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredFriends = myfriends;
  }

  void _filterFriends(String query) {
    List<Friend> results = [];
    if (query.isEmpty) {
      results = myfriends;
    } else {
      results = myfriends.where((friend) => friend.name.toLowerCase().contains(query.toLowerCase())).toList();
    }
    setState(() {
      filteredFriends = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber[300],
        shadowColor: Colors.black45,
        elevation: 20,
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
                    // TODO Navigate to create event/list page
                  },
                  child: Text('Create Your Own Event/List',
                      style: TextStyle(color: Colors.brown[400])),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredFriends.length,
              itemBuilder: (context, index) {
                return FriendFrame(friend: filteredFriends[index]);
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
  const FriendFrame({super.key, required this.friend});

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
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventListPage(events: friend.events),
          ),
        );
      },
    );
  }
}
