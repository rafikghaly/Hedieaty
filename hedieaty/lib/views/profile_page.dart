import 'package:flutter/material.dart';
import '../models/event.dart';
import '../models/gift.dart';
import 'my_pledged_gifts_page.dart';
import 'gift_list.dart';

class ProfilePage extends StatelessWidget {
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
            Text(userName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(email, style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to edit personal information form page
              },
              icon: const Icon(Icons.edit),
              label: const Text('Edit Personal Information'),
            ),
            const SizedBox(height: 20),
            const Text('My Events', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: userEvents.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(userEvents[index].name),
                    subtitle: Text('${userEvents[index].category} - ${userEvents[index].status}'),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GiftListPage(gifts: userEvents[index].gifts),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyPledgedGiftsPage(pledgedGifts: pledgedGifts),
                  ),
                );
              },
              child: const Text('My Pledged Gifts'),
            ),
          ],
        ),
      ),
    );
  }
}
