import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:padshala/blocs/foodpromo1/cart_bloc.dart';
import 'package:padshala/blocs/foodpromo1/cart_event.dart';
import 'package:padshala/blocs/foodpromo1/cart_state.dart';
import 'package:padshala/model/cartpage_track.dart';

class BottomNavBar extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  BottomNavBar({required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.amber,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Builder(builder: (context) {
            return IconButton(
              icon: Icon(Icons.menu),
              color: Colors.black,
              onPressed: () {
                scaffoldKey.currentState!.openDrawer(); // Open the drawer
              },
            );
          }),
          IconButton(
            icon: Icon(Icons.home),
            color: Colors.black,
            onPressed: () {
              // Handle Home button tap (you can navigate if needed)
            },
          ),
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              int cartItemCount = 0;
              if (state is CartUpdatedState) {
                cartItemCount = state.cartItems.length;
              }
              return IconButton(
                icon: Stack(
                  children: [
                    Icon(Icons.shopping_cart),
                    if (cartItemCount > 0)
                      Positioned(
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 12,
                            minHeight: 12,
                          ),
                          child: Text(
                            cartItemCount.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () {
                  // Navigate to CartPage and pass the updated cart items
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CartPage(
                        cartItems: (state is CartUpdatedState) ? state.cartItems : [],
                        onRemoveItem: (item) {
                          context.read<CartBloc>().add(RemoveFromCartEvent(cartItem: item));
                        },
                        onUpdateQuantity: (item, change) {
                          context.read<CartBloc>().add(UpdateQuantityEvent(cartItem: item, quantity: change, isIncrement: change > 0));
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
