import 'package:bloc/bloc.dart';
import 'package:padshala/model/cart_item.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(CartInitialState()) {
    // Registering event handlers
    on<AddToCartEvent>(_onAddToCart);
    on<UpdateQuantityEvent>(_onUpdateQuantity);
    on<RemoveFromCartEvent>(_onRemoveFromCart);
  }

  // Handler for AddToCartEvent
  void _onAddToCart(AddToCartEvent event, Emitter<CartState> emit) {
    List<CartItem> updatedCartItems = [];

    if (state is CartUpdatedState) {
      updatedCartItems = List<CartItem>.from((state as CartUpdatedState).cartItems);
    }

    // Check if the item already exists in the cart
    final existingItemIndex = updatedCartItems.indexWhere((item) => item.title == event.cartItem.title);

    if (existingItemIndex != -1) {
      // If the item exists, increase the quantity
      updatedCartItems[existingItemIndex].increaseQuantity();
    } else {
      // If the item doesn't exist, add a new one 
      updatedCartItems.add(event.cartItem);
    }

    emit(CartUpdatedState(cartItems: updatedCartItems));
  }

  // Handler for UpdateQuantityEvent
  void _onUpdateQuantity(UpdateQuantityEvent event, Emitter<CartState> emit) {
    List<CartItem> updatedCartItems = [];

    if (state is CartUpdatedState) {
      updatedCartItems = List<CartItem>.from((state as CartUpdatedState).cartItems);
    }

    final existingItemIndex = updatedCartItems.indexWhere((item) => item.title == event.cartItem.title);

    if (existingItemIndex != -1) {
      // Validate quantity to avoid setting a negative value
      if (event.quantity <= 0) {
        // Remove item if quantity is less than or equal to 0
        updatedCartItems.removeAt(existingItemIndex);
      } else {
        updatedCartItems[existingItemIndex].quantity = event.quantity;
      }
    }

    emit(CartUpdatedState(cartItems: updatedCartItems));
  }

  // Handler for RemoveFromCartEvent
  void _onRemoveFromCart(RemoveFromCartEvent event, Emitter<CartState> emit) {
    List<CartItem> updatedCartItems = [];

    if (state is CartUpdatedState) {
      updatedCartItems = List<CartItem>.from((state as CartUpdatedState).cartItems);
    }

    updatedCartItems.removeWhere((item) => item.title == event.cartItem.title);

    emit(CartUpdatedState(cartItems: updatedCartItems));
  }
  List<CartItem> _getCurrentCartItems() {
  if (state is CartUpdatedState) {
    return List<CartItem>.from((state as CartUpdatedState).cartItems);
  }
  return [];
}
}
