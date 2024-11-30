import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'views/sign_in_page.dart';
import 'views/home_page.dart';
import 'views/profile_page.dart';
import 'views/event_list.dart';
import 'models/friend.dart';
import 'models/event.dart';
import 'init_database.dart';
import 'controllers/repository.dart';
import 'controllers/sync_controller.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Perform your sync task here
    final SyncController syncController = SyncController();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Get the user ID from SharedPreferences
    int? userId = prefs.getInt('userId');

    // Ensure to pass the userId
    if (userId != null) {
      await syncController.syncUserData(userId);
    } else {
      // print('User ID not found in SharedPreferences.');
    }

    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await DatabaseInitializer().database;

  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final SyncController _syncController = SyncController();
  int? _userId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');

    if (userId != null) {
      setState(() {
        _userId = userId;
      });

      // Register periodic sync task with WorkManager
      Workmanager().registerPeriodicTask(
        '1',
        'simplePeriodicTask',
        frequency: const Duration(minutes: 10), // Sync every hour
        inputData: {'userId': userId},
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      if (_userId != null) {
        _syncController.syncUserData(_userId!);
      }
    }
  }

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
