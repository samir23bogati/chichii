import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:padshala/blocs/foodpromo1/cart_bloc.dart';
import 'package:padshala/blocs/foodpromo1/cart_event.dart';
import 'package:padshala/common/bottom_navbar.dart';
import 'package:padshala/common/favourites/fav_bloc.dart';
import 'package:padshala/common/favourites/fav_event.dart';
import 'package:padshala/common/favourites/fav_state.dart';
import 'package:padshala/model/cart_item.dart';
import 'package:padshala/screens/exploretab_page.dart';

import '../../blocs/foodpromo1/cart_state.dart';

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
      key: _scaffoldKey,
      appBar: AppBar(title: Text('Favorites')),
      body: BlocBuilder<FavoriteBloc, FavoriteState>(
        builder: (context, state) {
          if (state is FavoriteUpdatedState) {
            if (state.favorites.isEmpty) {
              return Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ExploretabPage(initialIndex: 0)),
                    );
                  },
                  child: Image.asset(
                    'assets/images/nofav.jpg',
                    width: 350,
                    height: 400,
                    fit: BoxFit.contain,
                  ),
                ),
              );
            }

            return BlocBuilder<CartBloc, CartState>(
              builder: (context, cartState) {
                final cartItems = cartState is CartUpdatedState ? cartState.cartItems : [];

                return ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  itemCount: state.favorites.length,
                  itemBuilder: (context, index) {
                    final item = state.favorites[index];
                    final isAdded = cartItems.any((c) => c.id == (item['id'] ?? item['title']));

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 14),
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () => _showItemDialog(context, item),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  item['image'] ?? 'assets/images/rum.jpg',
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['title'] ?? 'Unknown',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "NRS ${item['price'] ?? '0.00'}",
                                    style: TextStyle(fontSize: 14, color: Colors.green[700]),
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.favorite, color: Colors.red),
                                        onPressed: () {
                                          context.read<FavoriteBloc>().add(ToggleFavorite(item));
                                        },
                                      ),
                                      AnimatedSwitcher(
                                        duration: Duration(milliseconds: 300),
                                        child: isAdded
                                            ? Icon(Icons.check_circle,
                                                color: Colors.green,
                                                key: ValueKey("added_${item['title']}"))
                                            : ElevatedButton(
                                                key: ValueKey("button_${item['title']}"),
                                                style: ElevatedButton.styleFrom(
                                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                  textStyle: TextStyle(fontSize: 13),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  final cartItem = CartItem(
                                                    id: item['id'] ?? item['title'],
                                                    title: item['title'],
                                                    price: double.tryParse(item['price'].toString()) ?? 0.0,
                                                    imageUrl: item['image'] ?? '',
                                                    quantity: 1,
                                                  );
                                                  context.read<CartBloc>().add(AddToCartEvent(cartItem: cartItem));
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text("${item['title']} added to cart")),
                                                  );
                                                },
                                                child: Text("Add to Cart"),
                                              ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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

  void _showItemDialog(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) {
        return BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
            final cartItems = state is CartUpdatedState ? state.cartItems : [];
            final isAdded = cartItems.any((c) => c.id == (item['id'] ?? item['title']));

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              contentPadding: EdgeInsets.all(16),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      item['image'] ?? 'assets/images/rum.jpg',
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    item['title'],
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Rs. ${item["price"]}",
                    style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  SizedBox(height: 18),
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    child: isAdded
                        ? Icon(Icons.check_circle, color: Colors.green, size: 40, key: ValueKey("added_dialog_${item['title']}"))
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () {
                                final cartItem = CartItem(
                                  id: item['id'] ?? item['title'],
                                  title: item['title'],
                                  price: double.tryParse(item['price'].toString()) ?? 0.0,
                                  imageUrl: item['image'] ?? '',
                                  quantity: 1,
                                );
                                context.read<CartBloc>().add(AddToCartEvent(cartItem: cartItem));
                                Future.delayed(Duration(milliseconds: 200), () {
                                  if (Navigator.canPop(context)) Navigator.pop(context);
                                });
                              },
                              child: Text("Add to Cart"),
                            ),
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
