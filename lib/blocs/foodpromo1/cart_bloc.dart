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

 
void _onAddToCart(AddToCartEvent event, Emitter<CartState> emit) async {
  final currentState = state;
  List<CartItem> updatedCartItems = (currentState is CartUpdatedState)
      ? List<CartItem>.from(currentState.cartItems)
      : [];

 
  int existingIndex = updatedCartItems.indexWhere((item) => item.id == event.cartItem.id);

  if (existingIndex != -1) {
    
    updatedCartItems[existingIndex] = updatedCartItems[existingIndex].copyWith(
      quantity: updatedCartItems[existingIndex].quantity + 1,
    );
  } else {
    
    updatedCartItems.add(event.cartItem);
  }

  emit(CartUpdatedState(cartItems: updatedCartItems));

  // Save updated cart to SharedPreferences
  await _saveCartToPrefs(updatedCartItems);
}

 
  void _onUpdateQuantity(UpdateQuantityEvent event, Emitter<CartState> emit) async {
    final currentState = state;
    if (currentState is! CartUpdatedState) return;

    List<CartItem> updatedCartItems = List<CartItem>.from(currentState.cartItems);

    final existingIndex = updatedCartItems.indexWhere((item) => item.id == event.cartItem.id);

    if (existingIndex != -1) {
      if (event.isIncrement) {
      
        updatedCartItems[existingIndex] = updatedCartItems[existingIndex].copyWith(
          quantity: updatedCartItems[existingIndex].quantity + 1,
        );
      } else {
     
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

   
    await _saveCartToPrefs(updatedCartItems);
  }

 
  void _onRemoveFromCart(RemoveFromCartEvent event, Emitter<CartState> emit) async {
    final currentState = state;
    if (currentState is! CartUpdatedState) return;

    List<CartItem> updatedCartItems = List<CartItem>.from(currentState.cartItems);
    
    updatedCartItems.removeWhere((item) => item.id == event.cartItem.id);

    emit(CartUpdatedState(cartItems: updatedCartItems));

    
    await _saveCartToPrefs(updatedCartItems);
  }

 
  void _onLoadCart(LoadCartEvent event, Emitter<CartState> emit) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cartJson = prefs.getStringList('cart_items') ?? [];
    
    List<CartItem> cartItems = cartJson
        .map((item) => CartItem.fromJson(jsonDecode(item)))
        .toList();

    emit(CartUpdatedState(cartItems: cartItems));
  }

  
  Future<void> _saveCartToPrefs(List<CartItem> cartItems) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cartJson = cartItems.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList('cart_items', cartJson);
  }
}
