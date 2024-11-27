import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/gift.dart';
import '../models/event.dart';
import '../models/pledged_gift.dart';
import '../models/user.dart';
import '../controllers/pledged_gift_controller.dart';
import '../controllers/gift_controller.dart';
import '../controllers/user_controller.dart';
import '../controllers/event_controller.dart';
import 'add_gift_page.dart';
import 'edit_gift_page.dart';

class GiftListPage extends StatefulWidget {
  final int eventId;
  final int userId;
  final bool showPledgedGifts;
  final bool isOwner;

  const GiftListPage({
    super.key,
    required this.eventId,
    required this.userId,
    this.showPledgedGifts = false,
    required this.isOwner,
  });

  @override
  _GiftListPageState createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  late List<Gift> _gifts = [];
  late Map<int, String> _pledgedUserNames = {};
  Event? _event;
  User? _user;
  late String _userName;
  late String _email;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _fetchEventUserAndGifts();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('userId');
      _userName = prefs.getString('userName') ?? '';
      _email = prefs.getString('email') ?? '';
    });
  }

  Future<void> _fetchEventUserAndGifts() async {
    //Get the events and User details
    _event = await EventController().getEventById(widget.eventId);
    _user = await UserController().getUserById(widget.userId);

    // Get the gifts associated with the event
    if (widget.showPledgedGifts) {
      final pledgedGifts = await PledgedGiftController().getPledgedGiftsForUser(widget.userId);
      _gifts = [];
      for (var pledgedGift in pledgedGifts) {
        final gift = await GiftController().getGiftById(pledgedGift.giftId);
        if (gift != null) {
          _gifts.add(gift);
        }
      }
    } else {
      _gifts = await GiftController().gifts(widget.eventId);
    }

    // Get names of users who pledged each gift
    for (var gift in _gifts) {
      if (gift.isPledged) {
        final pledgedGifts = await PledgedGiftController().getPledgedGiftsForEvent(widget.eventId);
        final pledgedGift = pledgedGifts.firstWhere((pg) => pg.giftId == gift.id);
        final pledgedUser = await UserController().getUserById(pledgedGift.userId);
        if (pledgedUser != null) {
          _pledgedUserNames[gift.id!] = pledgedUser.name;
        }
            }
    }

    setState(() {});
  }

  Future<void> _pledgeGift(Gift gift) async {
    setState(() {
      gift.isPledged = !gift.isPledged;
      gift.status = gift.isPledged ? 'pledged' : 'available';
    });

    final pledgedGift = PledgedGift(
      eventId: widget.eventId,
      userId: _userId!,
      giftId: gift.id!,
      friendName: _user?.name ?? 'Unknown',
      dueDate: _event?.date ?? 'Unknown',
    );

    if (gift.isPledged) {
      await PledgedGiftController().insertPledgedGift(pledgedGift);
    } else {
      final pledgedGifts = await PledgedGiftController().getPledgedGiftsForUser(widget.userId);
      final giftToDelete = pledgedGifts.firstWhere((pg) => pg.giftId == gift.id);
      await PledgedGiftController().deletePledgedGift(giftToDelete.id!);
    }

    await GiftController().updateGift(gift);
    await _refreshGifts();
  }

  Future<void> _refreshGifts() async {
    await _fetchEventUserAndGifts();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gift List'),
        backgroundColor: Colors.amber[300],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshGifts,
        child: _gifts.isEmpty
            ? const Center(child: Text('No gifts available.'))
            : ListView.builder(
          itemCount: _gifts.length,
          itemBuilder: (context, index) {
            final gift = _gifts[index];
            final pledgedUserName = _pledgedUserNames[gift.id] ?? '';

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              color: gift.isPledged ? Colors.lightGreen[100] : null,
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
                    if (gift.isPledged) Text('Pledged by: $pledgedUserName'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!widget.isOwner && !gift.isPledged)
                      ElevatedButton(
                        onPressed: () => _pledgeGift(gift),
                        child: const Text('Pledge'),
                      ),
                    const SizedBox(width: 8.0),
                    if (widget.isOwner && !gift.isPledged)
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditGiftPage(gift: gift),
                            ),
                          ).then((_) => _refreshGifts());
                        },
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: widget.isOwner
          ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddGiftPage(eventId: widget.eventId, userId: widget.userId),
            ),
          ).then((_) => _refreshGifts());
        },
        backgroundColor: Colors.amber[500],
        child: const Icon(Icons.add),
      )
          : null,
    );
  }
}
