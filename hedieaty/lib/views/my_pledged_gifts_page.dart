import 'package:flutter/material.dart';
import '../models/gift.dart';
import 'package:hedieaty/controllers/repository.dart';

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

  final Repository _repository = Repository();

  @override
  void initState() {
    super.initState();
    _fetchPledgedGifts();
  }

  Future<void> _fetchPledgedGifts() async {
    final pledgedGifts = await _repository.getPledgedGiftsForUser(widget.userId);
    // print('Pledged gifts for user ${widget.userId}: $pledgedGifts');

    _pledgedGiftsWithDetails = [];
    for (var pledgedGift in pledgedGifts) {
      // print('Fetching gift details for gift docId ${pledgedGift.docId}');
      final gift = await _repository.getGiftById_For_pledged_Firestore(pledgedGift.giftId);
      // print('Gift details for gift docId ${pledgedGift.docId}: $gift');
      // print(pledgedGift.userId);
      // print(widget.userId);

      if (gift != null && pledgedGift.userId == widget.userId) {
        _pledgedGiftsWithDetails.add({
          'gift': gift,
          'friendName': pledgedGift.friendName,
          'dueDate': pledgedGift.dueDate,
          'docId': pledgedGift.docId,  // Include the docId
        });
        // print('Added gift: ${gift.name}');
      } else {
        // print('Gift is null or does not belong to the user');
      }
    }

    // print('Pledged gifts with details: $_pledgedGiftsWithDetails');
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
            final docId = _pledgedGiftsWithDetails[index]['docId'] as String;

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
