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
  return _cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
}

  // Update the quantity of an item
void updateQuantity(CartItem item, int change) {
  final index = _cartItems.indexWhere((cartItem) => cartItem.id == item.id);
  if (index != -1) {
    final newQuantity = _cartItems[index].quantity + change;
    if (newQuantity > 0) {
      _cartItems[index] = _cartItems[index].copyWith(quantity: newQuantity);
    } else {
      _cartItems.removeAt(index);
    }
    notifyListeners(); // Notify UI to update
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