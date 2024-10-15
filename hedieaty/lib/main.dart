import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class Friend {
  final String name;
  final String picture;
  final int upcomingEvents;
  Friend({required this.name, required this.picture, required this.upcomingEvents});
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Friend> myfriends = [
    Friend(name: 'Rafik Ghaly', picture: 'assets/images/Rafik.jpg', upcomingEvents: 5),
    Friend(name: 'Youssef Ghaly', picture: 'assets/images/Youssef.jpg', upcomingEvents: 0),

  ];
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
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
            mainAxisSize: MainAxisSize.min, // Adjusts row size to its children
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
           child: ElevatedButton(
             onPressed:(){
              // I will navigate to Event List Page----------------->
             },
             child: const Text('Create Your Own Event/List'),
          ),
         ),
         Expanded(
             child: ListView.builder(
                 itemCount: myfriends.length,
                 itemBuilder: (context,index) {
                   return FriendFrame(friend:myfriends[index]);
                 },
             ),
         ),
       ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
        // I will Add Friends------------------------->
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
      title: Text(friend.name, style: TextStyle(fontWeight: FontWeight.bold),),
      subtitle: Text(
        friend.upcomingEvents > 0
            ? 'Upcoming Events: ${friend.upcomingEvents}'
            : 'No Upcoming Events',
      ),
      trailing: friend.upcomingEvents > 0
          ? Text(friend.upcomingEvents.toString(),
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
          : null,
      onTap: () {
        // I will Navigate to friend's gift lists------------------------>
      },
    );
  }
}
