// lib/blocs/foodpromo1/cart_state.dart


import 'package:padshala/model/cart_item.dart';

abstract class CartState {}

class CartInitialState extends CartState {}

class CartUpdatedState extends CartState {
  final List<CartItem> cartItems;

  CartUpdatedState({required this.cartItems}); 

    int get cartItemCount => cartItems.length; 

    // Get the total price of the items in the cart
  double get totalPrice {
    double total = 0.0;
    for (var item in cartItems) {
      total +=  item.price * item.quantity;
    }
    return total;
  }
}

class CartEmptyState extends CartState {}

