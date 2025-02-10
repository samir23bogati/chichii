import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:padshala/model/cart_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(CartInitialState()) {
    on<AddToCartEvent>(_onAddToCart);
    on<UpdateQuantityEvent>(_onUpdateQuantity);
    on<RemoveFromCartEvent>(_onRemoveFromCart);
    on<LoadCartEvent>(_onLoadCart);
  }

  // Handler for AddToCartEvent (Adds item to cart or increases quantity)
void _onAddToCart(AddToCartEvent event, Emitter<CartState> emit) async {
  final currentState = state;
  List<CartItem> updatedCartItems = (currentState is CartUpdatedState)
      ? List<CartItem>.from(currentState.cartItems)
      : [];

  // Check if item already exists in the cart
  int existingIndex = updatedCartItems.indexWhere((item) => item.id == event.cartItem.id);

  if (existingIndex != -1) {
    // Increase quantity if item exists
    updatedCartItems[existingIndex] = updatedCartItems[existingIndex].copyWith(
      quantity: updatedCartItems[existingIndex].quantity + 1,
    );
  } else {
    // Add new item if not found
    updatedCartItems.add(event.cartItem);
  }

  emit(CartUpdatedState(cartItems: updatedCartItems));

  // Save updated cart to SharedPreferences
  await _saveCartToPrefs(updatedCartItems);
}

  // Handler for UpdateQuantityEvent (Increases or decreases item quantity)
  void _onUpdateQuantity(UpdateQuantityEvent event, Emitter<CartState> emit) async {
    final currentState = state;
    if (currentState is! CartUpdatedState) return;

    List<CartItem> updatedCartItems = List<CartItem>.from(currentState.cartItems);

    final existingIndex = updatedCartItems.indexWhere((item) => item.id == event.cartItem.id);

    if (existingIndex != -1) {
      if (event.isIncrement) {
        // Increase quantity
        updatedCartItems[existingIndex] = updatedCartItems[existingIndex].copyWith(
          quantity: updatedCartItems[existingIndex].quantity + 1,
        );
      } else {
        // Decrease quantity or remove item if quantity becomes 0
        if (updatedCartItems[existingIndex].quantity > 1) {
          updatedCartItems[existingIndex] = updatedCartItems[existingIndex].copyWith(
            quantity: updatedCartItems[existingIndex].quantity - 1,
          );
        } else {
          updatedCartItems.removeAt(existingIndex);
        }
      }
    }

    emit(CartUpdatedState(cartItems: updatedCartItems));

    // Save updated cart to SharedPreferences
    await _saveCartToPrefs(updatedCartItems);
  }

  // Handler for RemoveFromCartEvent (Deletes the item completely)
  void _onRemoveFromCart(RemoveFromCartEvent event, Emitter<CartState> emit) async {
    final currentState = state;
    if (currentState is! CartUpdatedState) return;

    List<CartItem> updatedCartItems = List<CartItem>.from(currentState.cartItems);
    
    updatedCartItems.removeWhere((item) => item.id == event.cartItem.id);

    emit(CartUpdatedState(cartItems: updatedCartItems));

    // Save updated cart to SharedPreferences
    await _saveCartToPrefs(updatedCartItems);
  }

  // Handler for LoadCartEvent (Loads cart data from SharedPreferences)
  void _onLoadCart(LoadCartEvent event, Emitter<CartState> emit) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cartJson = prefs.getStringList('cart_items') ?? [];
    
    List<CartItem> cartItems = cartJson
        .map((item) => CartItem.fromJson(jsonDecode(item)))
        .toList();

    emit(CartUpdatedState(cartItems: cartItems));
  }

  // Helper function to save cart data to SharedPreferences
  Future<void> _saveCartToPrefs(List<CartItem> cartItems) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cartJson = cartItems.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList('cart_items', cartJson);
  }
}
