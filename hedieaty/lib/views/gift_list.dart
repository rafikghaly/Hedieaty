import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/gift.dart';
import '../models/event.dart';
import '../models/pledged_gift.dart';
import '../models/user.dart';
import 'package:hedieaty/controllers/repository.dart';
import 'add_gift_page.dart';
import 'edit_gift_page.dart';
import 'gift_details_page.dart';

class GiftListPage extends StatefulWidget {
  final int eventId;
  final int userId;
  final bool showPledgedGifts;
  final bool isOwner;
  final String eventName;
  final String eventStatus;

  const GiftListPage({
    super.key,
    required this.eventId,
    required this.userId,
    this.showPledgedGifts = false,
    required this.isOwner,
    required this.eventName,
    required this.eventStatus,
  });

  @override
  _GiftListPageState createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  late List<Gift> _gifts = [];
  late final Map<int, String> _pledgedUserNames = {};
  Event? _event;
  User? _user;
  late final String _eventName;
  late String _userName;
  late String _email;
  int? _userId;

  final Repository _repository = Repository();
  StreamSubscription<QuerySnapshot>? _subscription;

  Map<int, int> pledgedGiftsMap = {};

  final TextEditingController _searchController = TextEditingController();
  List<Gift> _filteredGifts = [];
  String _selectedCategory = 'All';
  String _selectedEventStatus = 'All';

  @override
  void initState() {
    super.initState();
    _fetchEventUserAndGifts();
    _setupRealTimeListener();
    _loadUserData();
    _eventName = widget.eventName;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _setupRealTimeListener() {
    _subscription = FirebaseFirestore.instance
        .collection('gifts')
        .where('eventId', isEqualTo: widget.eventId)
        .snapshots()
        .listen((querySnapshot) {
      if (mounted) {
        setState(() {
          _gifts =
              querySnapshot.docs.map((doc) => Gift.fromFirestore(doc)).toList();
          _filterGifts(_searchController.text);
        });
      }
    }, onError: (error) {
      //print("Error while fetching data: $error");
    });
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _userId = prefs.getInt('userId');
        _userName = prefs.getString('userName') ?? '';
        _email = prefs.getString('email') ?? '';
      });
    }
  }

  Future<void> _fetchEventUserAndGifts() async {
    // print('Fetching event and user data...');
    _event = await _repository.getEventById(widget.eventId);
    _user = await _repository.getUserById(widget.userId);
    // print('Fetched event: $_event');
    // print('Fetched user: $_user');

    // Fetch pledged gifts data
    final pledgedGiftsList =
        await _repository.getPledgedGiftsForEvent(widget.eventId);
    pledgedGiftsMap = {
      for (var pledgedGift in pledgedGiftsList)
        pledgedGift.giftId: pledgedGift.userId
    };
    // print('Pledged gifts map: $pledgedGiftsMap');

    // Get the gifts associated with the event
    if (widget.showPledgedGifts) {
      final pledgedGifts =
          await _repository.getPledgedGiftsForUser(widget.userId);
      // print('Pledged gifts: $pledgedGifts');
      _gifts = [];
      for (var pledgedGift in pledgedGifts) {
        // print('Fetching gift details for gift ID ${pledgedGift.giftId}');
        final gift =
            await _repository.getGiftById(pledgedGift.giftId as String);
        // print('Gift details for pledged gift ${pledgedGift.giftId}: $gift');
        if (gift != null) {
          _gifts.add(gift);
        }
      }
      // print('Fetched pledged gifts: $pledgedGifts');
    } else {
      _gifts = await _repository.getGifts(widget.eventId);
      // print('Fetched event gifts: $_gifts');
    }

    // Get names of users who pledged each gift
    for (var gift in _gifts) {
      if (gift.isPledged) {
        final pledgedGifts =
            await _repository.getPledgedGiftsForEvent(widget.eventId);
        final pledgedGift =
            pledgedGifts.firstWhere((pg) => pg.giftId == gift.id);
        final pledgedUser = await _repository.getUserById(pledgedGift.userId);
        if (pledgedUser != null) {
          _pledgedUserNames[gift.id!] = pledgedUser.name;
          // print('Pledged user for gift ${gift.id}: ${pledgedUser.name}');
        }
      }
    }

    if (mounted) {
      setState(() {
        _filterGifts(_searchController.text);
      });
    }
  }

  void _filterGifts(String query) {
    final filteredGifts = _gifts.where((gift) {
      final nameMatches = gift.name.toLowerCase().contains(query.toLowerCase());
      final categoryMatches =
          _selectedCategory == 'All' || gift.category == _selectedCategory;

      final eventStatusMatches =
          _selectedEventStatus == 'All' || gift.status == _selectedEventStatus;

      return nameMatches && categoryMatches && eventStatusMatches;
    }).toList();

    setState(() {
      _filteredGifts = filteredGifts;
    });
  }

  Future<void> _markGiftAsPurchased(Gift gift) async {
    try {
      await _repository.markGiftAsPurchased(gift.docId);
      if (mounted) {
        setState(() {
          gift.isPurchased = true;
          gift.status = 'purchased';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'You can\'t mark the gift as purchased while offline. Please check your internet connection.'),
        ),
      );
    }
  }

  Future<void> _pledgeGift(Gift gift) async {
    try {
      final wasPledged = gift.isPledged;

      final pledgedGift = PledgedGift(
        eventId: widget.eventId,
        userId: _userId!,
        giftId: gift.id!,
        friendName: _user?.name ?? 'Unknown',
        dueDate: _event?.date ?? 'Unknown',
        docId: '',
      );

      if (!wasPledged) {
        await _repository.insertPledgedGift(pledgedGift);
      } else {
        final pledgedGifts =
            await _repository.getPledgedGiftsForUser(widget.userId);
        final giftToDelete =
            pledgedGifts.firstWhere((pg) => pg.giftId == gift.id);
        await _repository.deletePledgedGift(giftToDelete.docId ?? '');
      }

      gift.isPledged = !wasPledged;
      gift.status = gift.isPledged ? 'pledged' : 'available';
      await _repository.updateGift(gift);
      await _refreshGifts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  Future<void> _deleteGift(Gift gift) async {
    await _repository.deleteGift(gift.docId!);
    if (mounted) {
      setState(() {
        _gifts.remove(gift);
      });
    }
    await _refreshGifts();
  }

  Future<void> _refreshGifts() async {
    await _fetchEventUserAndGifts();
    if (mounted) {
      setState(() {});
    }
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: 'Search...',
          hintStyle: TextStyle(color: Colors.white70),
          border: InputBorder.none,
        ),
        onChanged: _filterGifts,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              //Event Name
              Expanded(
                flex: 6,
                child: Text(
                  _eventName,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const Spacer(),

              // Search Bar
              Flexible(
                flex: 5,
                child: _buildSearchField(),
              ),

              const SizedBox(width: 8),

              // Category Filter Dropdown
              Flexible(
                  flex: 4,
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value ?? 'All';
                        _filterGifts(_searchController.text);
                      });
                    },
                    isExpanded: true,
                    items: <String>[
                      'All',
                      'Electronics',
                      'Clothing',
                      'Toys',
                      'Books',
                      'Home Decor',
                      'Beauty & Personal Care',
                      'Food & Beverages',
                      'Sports & Outdoors',
                      'Gift Cards',
                      'Music & Movies',
                      'Other'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Container(
                          constraints: const BoxConstraints(
                              maxWidth: 120),
                          child: Text(
                            value,
                            overflow: TextOverflow
                                .ellipsis,
                            softWrap:
                                true,
                          ),
                        ),
                      );
                    }).toList(),
                  )),

              const SizedBox(width: 8),

              // Event Status Filter Dropdown
              Flexible(
                flex: 3,
                child: DropdownButton<String>(
                  value: _selectedEventStatus,
                  onChanged: (value) {
                    setState(() {
                      _selectedEventStatus = value ?? 'All';
                      _filterGifts(_searchController.text);
                    });
                  },
                  isExpanded: true,
                  items: <String>['All', 'available', 'pledged', 'purchased']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          overflow: TextOverflow
                              .ellipsis,
                          softWrap: true,
                        )
                        );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshGifts,
        child: _filteredGifts.isEmpty
            ? const Center(child: Text('No gifts found.'))
            : ListView.builder(
                itemCount: _filteredGifts.length,
                itemBuilder: (context, index) {
                  final gift = _filteredGifts[index];
                  final pledgedUserName = _pledgedUserNames[gift.id] ?? '';

                  Color cardColor;
                  if (gift.isPurchased) {
                    cardColor = Colors.red[200]!;
                  } else if (gift.isPledged) {
                    cardColor = Colors.lightGreen[200]!;
                  } else {
                    cardColor = Colors.white;
                  }

                  return Card(
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 12.0),
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0)),
                    color: cardColor,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16.0),
                      leading: gift.imageUrl != null
                          ? Image.memory(base64Decode(gift.imageUrl!),
                              fit: BoxFit.cover, width: 50, height: 50)
                          : gift.isPurchased
                              ? const Icon(Icons.card_giftcard, size: 40.0)
                              : Icon(Icons.card_giftcard,
                                  size: 40.0, color: Colors.amber[800]),
                      title: Text(gift.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18.0)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Category: ${gift.category}'),
                          Text('Status: ${gift.status}'),
                          Text('Description: ${gift.description}'),
                          Text('Price: \$${gift.price.toStringAsFixed(2)}'),
                          if (gift.isPledged)
                            Text('Pledged by: $pledgedUserName'),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  GiftDetailsPage(gift: gift)),
                        );
                      },
                      trailing: _buildGiftActions(gift),
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
                    builder: (context) => AddGiftPage(
                      eventId: widget.eventId,
                      userId: widget.userId,
                      isPrivate: false,
                    ),
                  ),
                ).then((_) => _refreshGifts());
              },
              backgroundColor: Colors.amber[800],
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildGiftActions(Gift gift) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!widget.isOwner && !gift.isPledged && widget.eventStatus != "Past")
          ElevatedButton(
            onPressed: () => _pledgeGift(gift),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[800]),
            child: const Text('Pledge', style: TextStyle(color: Colors.white)),
          ),
        const SizedBox(width: 8.0),
        if (widget.isOwner && !gift.isPledged && widget.eventStatus != "Past")
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditGiftPage(
                    gift: gift,
                    onGiftEdited: (editedGift) => _refreshGifts(),
                  ),
                ),
              ).then((_) => _refreshGifts());
            },
          ),
        if (widget.isOwner && !gift.isPledged)
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteGift(gift),
          ),
        if (gift.isPledged &&
            !gift.isPurchased &&
            pledgedGiftsMap[gift.id] == _userId)
          ElevatedButton(
            onPressed: () async {
              await _markGiftAsPurchased(gift);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[400]),
            child:
                const Text('Purchased', style: TextStyle(color: Colors.white)),
          ),
      ],
    );
  }
}
