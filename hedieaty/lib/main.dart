import 'package:flutter/material.dart';
import 'event_list.dart';
import 'event.dart';

void main() {
  runApp(const MyApp());
}

class Friend {
  final String name;
  final String picture;
  final int upcomingEvents;
  final List<Event> events;

  Friend({
    required this.name,
    required this.picture,
    required this.upcomingEvents,
    required this.events,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Friend> myfriends = [
    Friend(
      name: 'Rafik Ghaly',
      picture: 'assets/images/Rafik.jpg',
      upcomingEvents: 1,
      events: [Event(name: 'Birthday Party', category: 'Birthday', status: 'Upcoming')],
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
        backgroundColor: Colors.transparent,
        shadowColor: Colors.black45,
        elevation: 20,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(45),
          ),
        ),
        title: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/Logo.png',
                height: 40,
              ),
              SizedBox(width: 10),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  onChanged: _filterFriends,
                  decoration: InputDecoration(
                    labelText: 'Search Friends',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.search),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to create event/list page
                  },
                  child: const Text('Create Your Own Event/List'),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add friend manually
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class FriendFrame extends StatelessWidget {
  final Friend friend;

  FriendFrame({required this.friend});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: AssetImage(friend.picture),
      ),
      title: Text(
        friend.name,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        friend.upcomingEvents > 0
            ? 'Upcoming Events: ${friend.upcomingEvents}'
            : 'No Upcoming Events',
      ),
      trailing: friend.upcomingEvents > 0
          ? Text(
        friend.upcomingEvents.toString(),
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
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
