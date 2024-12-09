import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/gift.dart';
import 'gift_details_page.dart';
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
  String _errorMessage = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPledgedGifts();
  }

  Future<void> _fetchPledgedGifts() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final pledgedGifts = await _repository.getPledgedGiftsForUser(widget.userId);

      _pledgedGiftsWithDetails = [];
      for (var pledgedGift in pledgedGifts) {
        final gift = await _repository.getGiftById_For_pledged_Firestore(pledgedGift.giftId);

        if (gift != null && pledgedGift.userId == widget.userId) {
          _pledgedGiftsWithDetails.add({
            'gift': gift,
            'friendName': pledgedGift.friendName,
            'dueDate': pledgedGift.dueDate,
            'docId': pledgedGift.docId,
          });
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pledged Gifts', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.amber[700],
        elevation: 10.0,
        shadowColor: Colors.black,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[Color(0xFFFE6B8B), Color(0xFFFF8E53)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchPledgedGifts,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _pledgedGiftsWithDetails.isEmpty
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
                leading: gift.imageUrl != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.memory(
                    base64Decode(gift.imageUrl!),
                    fit: BoxFit.cover,
                    width: 50,
                    height: 50,
                  ),
                )
                    : Icon(
                  Icons.card_giftcard,
                  size: 40.0,
                  color: Colors.amber[800],
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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GiftDetailsPage(gift: gift),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: _errorMessage.isNotEmpty
          ? Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          _errorMessage,
          style: TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      )
          : null,
    );
  }
}
