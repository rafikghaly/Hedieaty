import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'views/sign_in_page.dart';
import 'views/home_page.dart';
import 'views/profile_page.dart';
import 'views/event_list.dart';
import 'controllers/friend_controller.dart';
import 'controllers/event_controller.dart';
import 'models/friend.dart';
import 'models/event.dart';
import 'init_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseInitializer().database; // Ensure the database is initialized
  runApp(const MyApp());
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
      home: SignInPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  Future<List<Friend>>? _friends;
  Future<List<Event>>? _events;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  void _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');
    if (userId != null) {
      setState(() {
        _userId = userId;
        _friends = FriendController().friends();
        _events = EventController().events(userId: userId);
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _userId == null
              ? const Center(child: CircularProgressIndicator())
              : FutureBuilder<List<Friend>>(
            future: _friends,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                List<Friend> friends = snapshot.data!;
                return HomePage(friends: friends, userId: _userId!);
              } else {
                return const Center(child: Text('No friends available.'));
              }
            },
          ),
          _userId == null
              ? const Center(child: CircularProgressIndicator())
              : FutureBuilder<List<Event>>(
            future: _events,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                List<Event> events = snapshot.data!;
                return EventListPage(events: events, userId: _userId!);
              } else {
                return const Center(child: Text('No events available.'));
              }
            },
          ),
          const ProfilePage(
            userName: 'Rafik Ghaly',
            email: 'rafikghaly2002@gmail.com',
            userEvents: [],
            pledgedGifts: [],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
