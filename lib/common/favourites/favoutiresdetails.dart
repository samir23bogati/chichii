import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:padshala/common/bottom_navbar.dart';
import 'package:padshala/common/favourites/fav_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavouritesDetails extends StatefulWidget {
  @override
  _FavouritesDetailsState createState() => _FavouritesDetailsState();
}

class _FavouritesDetailsState extends State<FavouritesDetails> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
 
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Favorites')),
      body: BlocBuilder<FavoritesBloc, FavoritesState>(
        builder: (context, state) {
          // Cast state to FavoritesUpdatedState to access favorites
          if (state is FavoritesUpdatedState) {
            if (state.favorites.isEmpty) {
              return Center(child: Text("No favorites yet"));
            }
            return ListView.builder(
              itemCount: state.favorites.length,
              itemBuilder: (context, index) {
                final item = state.favorites[index];
                return ListTile(
                  leading: Image.asset(
                    item['image'] ?? 'assets/images/rum.jpg',
                    width: 50, height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(item['title'] ?? 'Unknown'),
                  subtitle: Text("NRS ${item['price'] ?? '0.00'}"),
                  trailing: IconButton(
                    icon: Icon(Icons.favorite, color: Colors.red),
                    onPressed: () {
                      BlocProvider.of<FavoritesBloc>(context).add(ToggleFavorite(item));
                    },
                  ),
                );
              },
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      bottomNavigationBar: BottomNavBar(scaffoldKey: _scaffoldKey),
    );
  }
}