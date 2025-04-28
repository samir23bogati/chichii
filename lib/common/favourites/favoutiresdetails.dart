
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:padshala/common/bottom_navbar.dart';
import 'package:padshala/common/favourites/fav_bloc.dart';
import 'package:padshala/common/favourites/fav_event.dart';
import 'package:padshala/common/favourites/fav_state.dart';

class FavouritesDetails extends StatefulWidget {
  @override
  _FavouritesDetailsState createState() => _FavouritesDetailsState();
}

class _FavouritesDetailsState extends State<FavouritesDetails> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
   @override
  void initState() {
    super.initState();
    context.read<FavoriteBloc>().add(LoadFavorites());
  }
 
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Favorites')),
      body: BlocBuilder<FavoriteBloc, FavoriteState>(
        builder: (context, state) {
          if (state is FavoriteUpdatedState) {
            if (state.favorites.isEmpty) {  
             return Center(
      child: Image.asset(
        'assets/images/nofav.jpg', 
        width: 200,
        height: 200,
        fit: BoxFit.contain,
      ),
    );
  }
  return ListView.builder(
              itemCount: state.favorites.length,
              itemBuilder: (context, index) {
                final item = state.favorites[index];
                return ListTile(
                  leading: Image.asset(
                    item['image'] ?? 'assets/images/rum.jpg',
                    width: 50, 
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(item['title'] ?? 'Unknown'), 
                  subtitle: Text("NRS ${item['price'] ?? '0.00'}"),
                  trailing: IconButton(
                    icon: Icon(Icons.favorite, color: Colors.red),
                    onPressed: () {
                      context.read<FavoriteBloc>().add(ToggleFavorite(item));
                    },
                  ),
                );
              },
            );
          } else if (state is FavoriteInitialState) {
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