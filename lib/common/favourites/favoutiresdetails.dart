import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:padshala/common/bottom_navbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavouritesDetails extends StatefulWidget {
  @override
  _FavouritesDetailsState createState() => _FavouritesDetailsState();
}

class _FavouritesDetailsState extends State<FavouritesDetails> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, String>> favoriteItems = [];
   @override
  void initState() {
    super.initState();
    loadFavorites();
  }
  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? storedItems = prefs.getStringList('favorites');
    if (storedItems != null && mounted) {
    setState(() {
      favoriteItems = storedItems
          .map((item) => Map<String, String>.from(jsonDecode(item)))
          .toList();
    });
  }
}
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  loadFavorites();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(title: Text('Favorites')),
      body: favoriteItems.isEmpty
          ? Center(child: Text("No favorites yet"))
          : ListView.builder(
              itemCount: favoriteItems.length,
              itemBuilder: (context, index) {
                final item = favoriteItems[index];
                return ListTile(
                  leading: Image.asset(
                    item['image'] ?? 'assets/images/rum.jpg',
                    width: 50, height: 50,
                    fit: BoxFit.cover,
                    ),
                   title: Text(item['title'] ?? 'Unknown'),
                  subtitle: Text("NRS ${item['price'] ?? '0.00'}"),
                );
              },
            ),
       bottomNavigationBar: BottomNavBar(scaffoldKey: _scaffoldKey),
    );
  }
}
