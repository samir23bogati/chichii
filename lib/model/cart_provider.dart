import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:padshala/model/cart_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => _cartItems; // public getter for cart items

 
  // Load cart items from shared preferences
  Future<void> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartData = prefs.getString('cartItems');
    if (cartData != null) {
      List<dynamic> decodedData = jsonDecode(cartData);
      _cartItems = decodedData.map((item) => CartItem.fromJson(item)).toList();
    }
    notifyListeners();
  }
   // Save cart items to shared preferences
  Future<void> saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartData = jsonEncode(_cartItems.map((item) => item.toJson()).toList());
    await prefs.setString('cartItems', cartData);
  }

  // Add an item to the cart
  void addItemToCart(CartItem item) {
    _cartItems.add(item);
    saveCart(); // Save cart to shared preferences
    notifyListeners();
  }

  // Remove an item from the cart
  void removeItemFromCart(CartItem item) {
    _cartItems.remove(item);
    saveCart(); // Save updated cart to shared preferences
    notifyListeners();
  }

  // Update item quantity
  void updateQuantity(CartItem item, int quantityChange) {
    final index = _cartItems.indexOf(item);
    if (index != -1) {
      _cartItems[index].quantity += quantityChange;
      if (_cartItems[index].quantity <= 0) {
        removeItemFromCart(item); // If quantity is zero or less, remove item
      } else {
        saveCart(); // Save updated cart to shared preferences
      }
      notifyListeners();
    }
  }


  // Calculate total price
  double calculateTotalPrice() {
    double total = 0.0;
    for (var item in _cartItems) {
      total += item.price * item.quantity;
    }
    return total;
  }

   // Add items from initial data
  void addItemsToCart(List<CartItem> items) {
    _cartItems.addAll(items);
    saveCart(); // Save updated cart to shared preferences
    notifyListeners();
  }
}