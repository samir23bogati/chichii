import 'package:flutter/material.dart';

class ExpandableCategory extends StatelessWidget {
  final String title;
  final List<String> items;

  ExpandableCategory({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(title),
      children: items.map((item) {
        return ListTile(title: Text(item));
      }).toList(),
    );
  }
}
