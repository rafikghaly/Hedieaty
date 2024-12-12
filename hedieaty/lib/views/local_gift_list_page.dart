import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/gift.dart';
import 'package:hedieaty/controllers/repository.dart';
import 'add_gift_page.dart';
import 'edit_gift_page.dart';
import 'gift_details_page.dart';

class LocalGiftListPage extends StatefulWidget {
  final int eventId;
  final int userId;
  final bool isPrivate;
  final String eventName;

  const LocalGiftListPage({
    super.key,
    required this.eventId,
    required this.userId,
    required this.isPrivate,
    required this.eventName,
  });

  @override
  _LocalGiftListPageState createState() => _LocalGiftListPageState();
}

class _LocalGiftListPageState extends State<LocalGiftListPage> {
  List<Gift> _localGifts = [];
  String _selectedSortOption = 'Name';
  final Repository _repository = Repository();

  @override
  void initState() {
    super.initState();
    _fetchLocalGifts();
  }

  void _sortGifts(String sortOption) {
    setState(() {
      _selectedSortOption = sortOption;
      if (sortOption == 'Name') {
        _localGifts.sort((a, b) => a.name.compareTo(b.name));
      } else if (sortOption == 'Category') {
        _localGifts.sort((a, b) => a.category.compareTo(b.category));
      } else if (sortOption == 'Price') {
        _localGifts.sort((a, b) => a.price.compareTo(b.price));
      }
    });
  }

  Future<void> _fetchLocalGifts() async {
    try {
      List<Gift> localGifts = await _repository.getLocalGifts(widget.eventId);
      setState(() {
        _localGifts = localGifts;
      });
    } catch (e) {
      //print('Error fetching local gifts: $e');
    }
  }

  void _addNewGift() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddGiftPage(
          eventId: widget.eventId,
          userId: widget.userId,
          isPrivate: widget.isPrivate,
        ),
      ),
    ).then((_) {
      _fetchLocalGifts();
    });
  }

  void _editLocalGift(Gift gift) async {
    bool? edited = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditGiftPage(
          gift: gift,
          onGiftEdited: (editedGift) async {
            await _repository.updateLocalGiftTable(editedGift);
            _fetchLocalGifts();
          },
        ),
      ),
    );

    if (edited == true) {
      _fetchLocalGifts();
    }
  }

  Future<void> _deleteLocalGift(Gift gift) async {
    await _repository.deleteLocalGiftTable(gift.id!);
    setState(() {
      _localGifts.remove(gift);
    });
    _fetchLocalGifts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(widget.eventName, style: const TextStyle(color: Colors.white)),
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
        onRefresh: _fetchLocalGifts,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Text('Sort by:'),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: _selectedSortOption,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        _sortGifts(newValue);
                      }
                    },
                    items: <String>['Name', 'Category', 'Price']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _localGifts.isEmpty
                  ? const Center(child: Text('No local gifts available.'))
                  : ListView.builder(
                itemCount: _localGifts.length,
                itemBuilder: (context, index) {
                  final gift = _localGifts[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 12.0,
                    ),
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
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
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                          color: Colors.amber[800],
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Description: ${gift.description}'),
                          Text('Category: ${gift.category}'),
                          Text('Price: \$${gift.price.toStringAsFixed(2)}'),
                          Text('Status: ${gift.status}'),
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
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              _editLocalGift(gift);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              _deleteLocalGift(gift);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: _addNewGift,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[800],
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'Add New Gift',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
