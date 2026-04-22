// lib/screens/detailpage/detailpage.dart

import 'package:flutter/material.dart';
// Import your data type so the page knows what an 'item' is
import 'package:re_use/types/data_seeding.dart';

class DetailPage extends StatelessWidget {
  // 1. Declare the variable to hold the passed data
  final dynamic item;

  // 2. Add it to the constructor
  const DetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.title),
        backgroundColor: const Color(0xFF6F9476),
      ),
      body: Column(
        children: [
          Image.network(item.imageUrl),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              item.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Text("Owner: ${item.ownerName}"),
          // ... add the rest of your UI here
        ],
      ),
    );
  }
}
