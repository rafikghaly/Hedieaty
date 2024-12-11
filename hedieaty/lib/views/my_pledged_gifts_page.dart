import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/gift.dart';
import 'gift_details_page.dart';
import 'package:hedieaty/controllers/repository.dart';

class MyPledgedGiftsPage extends StatefulWidget {
  final int userId;
  final String username;

  const MyPledgedGiftsPage({
    super.key,
    required this.userId, required this.username,
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
      final pledgedGifts =
          await _repository.getPledgedGiftsForUser(widget.userId);

      _pledgedGiftsWithDetails = [];
      for (var pledgedGift in pledgedGifts) {
        final gift = await _repository
            .getGiftById_For_pledged_Firestore(pledgedGift.giftId);

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

  Future<void> _markGiftAsPurchased(Gift gift) async {
    try {
      await _repository.markGiftAsPurchased(gift.docId);
      await _repository.makeNotificationPurchase(gift.eventId, widget.username, gift.name);
      setState(() {
        gift.isPurchased = true;
        gift.status = 'purchased';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'You can\'t mark the gift as purchased while offline. Please check your internet connection.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('My Pledged Gifts',
            style: TextStyle(color: Colors.white)),
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
                      final gift =
                          _pledgedGiftsWithDetails[index]['gift'] as Gift;
                      final friendName = _pledgedGiftsWithDetails[index]
                          ['friendName'] as String;
                      final dueDate =
                          _pledgedGiftsWithDetails[index]['dueDate'] as String;

                      // Determine the card color based on the gift's status
                      Color cardColor;
                      if (gift.isPurchased) {
                        cardColor = Colors.red[200]!;
                      } else {
                        cardColor = Colors.lightGreen[300]!;
                      }

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 12.0),
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        color: cardColor,
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
                              : gift.isPurchased
                                  ?  Icon(
                                      Icons.card_giftcard,
                                      size: 40.0,
                                      color: Theme.of(context).iconTheme.color,
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
                              Text(
                                'Category: ${gift.category}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                              Text(
                                'Status: ${gift.status}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                              Text(
                                'Description: ${gift.description}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                              Text(
                                'Price: \$${gift.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                              Text(
                                'Friend: $friendName',
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                              Text(
                                'Due Date: $dueDate',
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    GiftDetailsPage(gift: gift),
                              ),
                            );
                          },
                          trailing: gift.isPurchased
                              ? null
                              : ElevatedButton(
                                  onPressed: () async {
                                    await _markGiftAsPurchased(gift);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red[400],
                                  ),
                                  child: const Text(
                                    'Purchased',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
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
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            )
          : null,
    );
  }
}
