
import 'package:padshala/model/cart_item.dart';

abstract class CartState {}

class CartInitialState extends CartState {}

class CartLoadingState extends CartState {}

class CartUpdatedState extends CartState {
  final List<CartItem> cartItems;

  CartUpdatedState({required this.cartItems}); 

    int get cartItemCount => cartItems.length; 

    // Get the total price of the items in the cart
  double get totalPrice {
     return cartItems.fold(0.0, (total, item) => total + (item.price * item.quantity));
  }
}

class CartEmptyState extends CartState {}

class CartErrorState extends CartState {
  final String errorMessage;

  CartErrorState({required this.errorMessage});
}
