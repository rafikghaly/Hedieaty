import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'views/sign_in_page.dart';
import 'views/home_page.dart';
import 'views/profile_page.dart';
import 'views/event_list.dart';
import 'models/friend.dart';
import 'models/event.dart';
import 'init_database.dart';
import 'controllers/repository.dart'; // Import the repository

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await DatabaseInitializer().database;
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
  int? _firebaseId;
  String? _userName;
  String? _email;

  final Repository _repository = Repository();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');
    int? firebaseId = prefs.getInt('firebaseId');
    String? userName = prefs.getString('userName');
    String? email = prefs.getString('email');

    if (userId != null) {
      setState(() {
        _userId = userId;
        _userName = userName;
        _email = email;
        _friends = _repository.getFriends(firebaseId!);
        _events = _repository.getEvents(userId: firebaseId);
        _firebaseId = firebaseId;
      });
    } else {
      setState(() {
        _userId = -1; // Set to -1 to indicate no user is logged in
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
              : _userId == -1
              ? SignInPage()
              : FutureBuilder<List<Friend>>(
            future: _friends,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                List<Friend> friends = snapshot.data!;
                return HomePage(friends: friends, userId: _userId!, firebaseId: _firebaseId!,);
              } else {
                return const Center(child: Text('No friends available.'));
              }
            },
          ),
          _userId == null
              ? const Center(child: CircularProgressIndicator())
              : _userId == -1
              ? SignInPage()
              : FutureBuilder<List<Event>>(
            future: _events,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                List<Event> events = snapshot.data!;
                return EventListPage(
                  events: events,
                  userId: _userId!,
                  isOwner: true, firebaseId: _firebaseId!,
                );
              } else {
                return const Center(child: Text('No events available.'));
              }
            },
          ),
          ProfilePage(
            userName: _userName ?? '',
            email: _email ?? '',
            userEvents: const [],
            pledgedGifts: const [],
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
            label: 'My Events',
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
