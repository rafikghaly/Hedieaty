import 'package:flutter/material.dart';
import '../../models/gift.dart';

class MyPledgedGiftsPage extends StatelessWidget {
  final List<Gift> pledgedGifts;

  const MyPledgedGiftsPage({super.key, required this.pledgedGifts});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pledged Gifts'),
      ),
      body: ListView.builder(
        itemCount: pledgedGifts.length,
        itemBuilder: (context, index) {
          final gift = pledgedGifts[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(gift.imageUrl ?? 'assets/images/DefaultGift.png'),
            ),
            title: Text(gift.name),
            subtitle: Text(gift.category),
            trailing: Text(gift.status),
            onTap: () {
              // Go to detailed view of pledged gift
            },
          );
        },
      ),
    );
  }
}
