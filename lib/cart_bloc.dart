import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:padshala/blocs/foodpromo1/cart_event.dart';
import 'package:padshala/blocs/foodpromo1/cart_state.dart';
import 'package:padshala/model/cart_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(CartInitialState()) {
    on<AddToCartEvent>(_onAddToCart);
    on<UpdateQuantityEvent>(_onUpdateQuantity);  
    on<RemoveFromCartEvent>(_onRemoveFromCart);
    on<LoadCartEvent>(_onLoadCart); 
     on<ClearCart>(_onClearCart);
  }
void _onClearCart(ClearCart event, Emitter<CartState> emit) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('cart_items'); 
  emit(CartUpdatedState(cartItems: [])); // ✅ clear in-memory cart too
}


 void _onAddToCart(AddToCartEvent event, Emitter<CartState> emit) async {
  List<CartItem> updatedCartItems = (state is CartUpdatedState)
      ? List<CartItem>.from((state as CartUpdatedState).cartItems)
      : [];

  // Check if the item already exists in the cart
  int existingIndex = updatedCartItems.indexWhere((item) => item.id == event.cartItem.id);

  if (existingIndex != -1) {
    // Update the existing item's quantity
    updatedCartItems[existingIndex] = updatedCartItems[existingIndex].copyWith(
      quantity: updatedCartItems[existingIndex].quantity + event.cartItem.quantity,
    );
  } else {
    
    updatedCartItems.add(event.cartItem);
  }

  emit(CartUpdatedState(cartItems: updatedCartItems));
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> cartJson = updatedCartItems.map((item) => jsonEncode(item.toJson())).toList();
  await prefs.setStringList('cart_items', cartJson);
}

  
  void _onUpdateQuantity(UpdateQuantityEvent event, Emitter<CartState> emit) {
    List<CartItem> updatedCartItems = (state is CartUpdatedState)
        ? List<CartItem>.from((state as CartUpdatedState).cartItems)
        : [];
    final existingItemIndex = updatedCartItems.indexWhere((item) => item.title == event.cartItem.title);

    if (existingItemIndex != -1) {
      if (event.quantity <= 0) {
        updatedCartItems.removeAt(existingItemIndex);
      } else {
        updatedCartItems[existingItemIndex].quantity = event.quantity;
      }
    }

    emit(CartUpdatedState(cartItems: updatedCartItems));
  }

 
  void _onRemoveFromCart(RemoveFromCartEvent event, Emitter<CartState> emit) {
    List<CartItem> updatedCartItems = (state is CartUpdatedState)
        ? List<CartItem>.from((state as CartUpdatedState).cartItems)
        : [];

    updatedCartItems.removeWhere((item) => item.title == event.cartItem.title);

    emit(CartUpdatedState(cartItems: updatedCartItems));
  }


  void _onLoadCart(LoadCartEvent event, Emitter<CartState> emit) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? cartJson = prefs.getStringList('cart_items');

    if (cartJson == null) {
      emit(CartUpdatedState(cartItems: []));
      return;
    }

    List<CartItem> loadedCart = cartJson.map((item) => CartItem.fromJson(jsonDecode(item))).toList();

    emit(CartUpdatedState(cartItems: loadedCart));
  }

  List<CartItem> _getCurrentCartItems() {
    if (state is CartUpdatedState) {
      return List<CartItem>.from((state as CartUpdatedState).cartItems);
    }
    return [ ];
  }
}
