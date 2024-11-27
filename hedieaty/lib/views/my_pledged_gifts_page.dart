import 'package:flutter/material.dart';
import '../models/gift.dart';
import '../controllers/pledged_gift_controller.dart';
import '../controllers/gift_controller.dart';

class MyPledgedGiftsPage extends StatefulWidget {
  final int userId;

  const MyPledgedGiftsPage({
    super.key,
    required this.userId,
  });

  @override
  _MyPledgedGiftsPageState createState() => _MyPledgedGiftsPageState();
}

class _MyPledgedGiftsPageState extends State<MyPledgedGiftsPage> {
  late List<Map<String, dynamic>> _pledgedGiftsWithDetails = [];

  @override
  void initState() {
    super.initState();
    _fetchPledgedGifts();
  }

  Future<void> _fetchPledgedGifts() async {
    final pledgedGifts = await PledgedGiftController().getPledgedGiftsForUser(widget.userId);
    _pledgedGiftsWithDetails = [];

    for (var pledgedGift in pledgedGifts) {
      final gift = await GiftController().getGiftById(pledgedGift.giftId);
      if (gift != null && pledgedGift.userId == widget.userId) {
        // Ensure the gift is not the user's own gift
        _pledgedGiftsWithDetails.add({
          'gift': gift,
          'friendName': pledgedGift.friendName,
          'dueDate': pledgedGift.dueDate,
        });
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pledged Gifts'),
        backgroundColor: Colors.amber[300],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchPledgedGifts,
        child: _pledgedGiftsWithDetails.isEmpty
            ? const Center(child: Text('No pledged gifts available.'))
            : ListView.builder(
          itemCount: _pledgedGiftsWithDetails.length,
          itemBuilder: (context, index) {
            final gift = _pledgedGiftsWithDetails[index]['gift'] as Gift;
            final friendName = _pledgedGiftsWithDetails[index]['friendName'] as String;
            final dueDate = _pledgedGiftsWithDetails[index]['dueDate'] as String;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              color: Colors.lightGreen[100],
              child: ListTile(
                contentPadding: const EdgeInsets.all(16.0),
                leading: Icon(
                  Icons.card_giftcard,
                  size: 40.0,
                  color: Colors.amber[500],
                ),
                title: Text(
                  gift.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Category: ${gift.category}'),
                    Text('Status: ${gift.status}'),
                    Text('Description: ${gift.description}'),
                    Text('Price: \$${gift.price.toStringAsFixed(2)}'),
                    Text('Friend: $friendName'),
                    Text('Due Date: $dueDate'),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
