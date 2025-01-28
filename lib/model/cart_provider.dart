import 'package:flutter/material.dart';
import 'package:padshala/model/cart_item.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => _cartItems;

    // Set initial items for cart
  void setCartItems(List<CartItem> initialItems, BuildContext context) {
    _cartItems = List.from(initialItems);
  
   // Delay notifyListeners to avoid triggering rebuild during build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // Calculate total price
  double calculateTotalPrice() {
    double total = 0;
    for (var item in _cartItems) {
      total += item.price * item.quantity;
    }
    return total;
  }

  // Update the quantity of an item
  void updateQuantity(CartItem item, int change) {
    final index = _cartItems.indexOf(item);
    if (index != -1) {
      final newQuantity = _cartItems[index].quantity + change;
      if (newQuantity > 0) {
        _cartItems[index] = _cartItems[index].copyWith(quantity: newQuantity);
      } else {
        _cartItems.removeAt(index); // Remove the item if quantity becomes zero
      }
       // Delay notifyListeners to avoid triggering rebuild during build phase
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  // Remove an item from the cart
  void removeItem(CartItem item) {
    _cartItems.remove(item);
    
    // Delay notifyListeners to avoid triggering rebuild during build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
}