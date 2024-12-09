import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/gift.dart';

class GiftDetailsPage extends StatelessWidget {
  final Gift gift;

  const GiftDetailsPage({super.key, required this.gift});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gift Details', style: TextStyle(color: Colors.white)),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (gift.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Image.memory(base64Decode(gift.imageUrl!)),
              ),
            const SizedBox(height: 20),
            Text(
              gift.name,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.amber[800],
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            Divider(color: Colors.amber[200]),
            const SizedBox(height: 10),
            const Text(
              'Category:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              gift.category,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            const Text(
              'Description:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              gift.description,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            const Text(
              'Price:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              '\$${gift.price.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            const Text(
              'Status:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              gift.status,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            if (gift.isPledged)
              const Text(
                'This gift is pledged.',
                style: TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}
