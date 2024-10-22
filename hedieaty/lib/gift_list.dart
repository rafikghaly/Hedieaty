import 'package:flutter/material.dart';
import '../models/gift.dart';
import 'gift_details_page.dart';

class GiftListPage extends StatefulWidget {
  final List<Gift> gifts;

  const GiftListPage({super.key, required this.gifts});

  @override
  _GiftListPageState createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  List<Gift> filteredGifts = [];
  String _selectedSortOption = 'Name';
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredGifts = widget.gifts;
  }

  void _filterGifts(String query) {
    List<Gift> results = [];
    if (query.isEmpty) {
      results = widget.gifts;
    } else {
      results = widget.gifts
          .where(
              (gift) => gift.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    setState(() {
      filteredGifts = results;
    });
  }

  void _sortGifts(String sortOption) {
    setState(() {
      _selectedSortOption = sortOption;
      if (sortOption == 'Name') {
        filteredGifts.sort((a, b) => a.name.compareTo(b.name));
      } else if (sortOption == 'Category') {
        filteredGifts.sort((a, b) => a.category.compareTo(b.category));
      } else if (sortOption == 'Status') {
        filteredGifts.sort((a, b) => a.status.compareTo(b.status));
      }
    });
  }

  void _navigateToGiftDetailsPage(Gift? gift) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GiftDetailsPage(gift: gift),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gift List'),
        backgroundColor: Colors.amber[300],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: _filterGifts,
                    decoration: const InputDecoration(
                      labelText: 'Search Gifts',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: _selectedSortOption,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      _sortGifts(newValue);
                    }
                  },
                  items: <String>['Name', 'Category', 'Status']
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
            child: ListView.builder(
              itemCount: filteredGifts.length,
              itemBuilder: (context, index) {
                final gift = filteredGifts[index];
                return ListTile(
                  title: Text(gift.name),
                  subtitle: Text(gift.category),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _navigateToGiftDetailsPage(filteredGifts[index]);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          // Delete gift logic
                        },
                      ),
                    ],
                  ),
                  tileColor: gift.isPledged ? Colors.amber[100] : null,
                  onTap: () {
                    // Detail view or other logic
                  },
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _navigateToGiftDetailsPage(null); // Add new gift logic
            },
            child: const Text('Add New Gift'),
          ),
        ],
      ),
    );
  }
}
