import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:padshala/blocs/foodpromo1/cart_bloc.dart';
import 'package:padshala/blocs/foodpromo1/cart_event.dart';
import 'package:padshala/blocs/foodpromo1/cart_state.dart';
import 'package:padshala/model/cart_item.dart';
import 'package:padshala/common/bottom_navbar.dart';

class WhatsnewFoodlist extends StatelessWidget {
  final String comboName;
  final double price;
  final List<Map<String, dynamic>> foodItems;
  final List<String> imageUrl;

  WhatsnewFoodlist({
    required this.comboName,
    required this.price,
    required this.foodItems,
    required this.imageUrl,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(comboName)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.zero,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset(
                imageUrl.first,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 215,
              ),
            ),
             // Price Card
              Card(
                color: Colors.green[50],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      SizedBox(width: 6),
                      Text(
                        "NRS ${price.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.green[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                "INCLUDED IN  $comboName:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            ...foodItems.map((item) => ListTile(
                  title: Text(item["name"] ?? "Unnamed"),
                  leading: item["image"] != null && item["image"] != ""
                      ? Image.asset(item["image"]!, width: 75, height: 75)
                      : Icon(Icons.fastfood),
                )),
            BlocBuilder<CartBloc, CartState>(
              builder: (context, state) {
                bool isAddedToCart = false;
                CartItem? existingCartItem;
                if (state is CartUpdatedState) {
                  existingCartItem = state.cartItems.firstWhere(
                    (item) => item.id == comboName,
                    orElse: () => CartItem(
                      id: comboName,
                      title: comboName,
                      imageUrl: imageUrl.first,
                      price: price,
                      quantity: 1,
                    ),
                  );
                  isAddedToCart =
                      state.cartItems.any((item) => item.id == comboName);
                }
                return Center(
                  child: ElevatedButton(
                    onPressed: () {
                      final cartItem = CartItem(
                        id: comboName,
                        title: comboName,
                        imageUrl: imageUrl.first,
                        price: price,
                        quantity: 1,
                      );
                      if (!isAddedToCart) {
                        context.read<CartBloc>().add(AddToCartEvent(
                            cartItem: cartItem)); 
                      } else {
                        context.read<CartBloc>().add(RemoveFromCartEvent(
                            cartItem: cartItem)); 
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isAddedToCart
                          ? Colors.green
                          : Theme.of(context).primaryColor,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isAddedToCart
                              ? Icons.check_circle
                              : Icons.shopping_cart,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8), 
                        Text(
                          isAddedToCart ? "ADDED IN CART" : "Add to Cart",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar:
          BottomNavBar(scaffoldKey: GlobalKey<ScaffoldState>()),
    );
  }
}
