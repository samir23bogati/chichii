
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:padshala/common/bottom_navbar.dart';
import 'package:padshala/common/favourites/fav_bloc.dart';

class FavouritesDetails extends StatefulWidget {
  @override
  _FavouritesDetailsState createState() => _FavouritesDetailsState();
}

class _FavouritesDetailsState extends State<FavouritesDetails> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
   @override
  void initState() {
    super.initState();
    context.read<FavoritesBloc>().add(LoadFavorites());
  }
 
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Favorites')),
      body: BlocBuilder<FavoritesBloc, FavoritesState>(
        builder: (context, state) {
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
                      context.read<FavoritesBloc>().add(ToggleFavorite(item));
                    },
                  ),
                );
              },
            );
         } else if (state is FavoritesInitialState) {
            return Center(child: CircularProgressIndicator());
          } else {
            return Center(child: Text("Something went wrong"));
          }
        },
      ),
      bottomNavigationBar: BottomNavBar(scaffoldKey: _scaffoldKey),
    );
  }
}