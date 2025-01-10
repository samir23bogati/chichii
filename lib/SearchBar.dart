import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  const SearchBar({super.key});

  @override
 Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search  for products...',
          hintStyle: TextStyle(color: Colors.grey),
          prefixIcon: Icon(Icons.search_rounded),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
             borderRadius: BorderRadius.zero,
             borderSide: BorderSide(color: Colors.amber),
          ),
        ),
      ),
    );
  }
}
