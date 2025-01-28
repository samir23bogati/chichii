import 'package:bloc/bloc.dart';
import 'package:padshala/model/cart_item.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(CartInitialState()) {
    // Registering event handlers
    on<AddToCartEvent>(_onAddToCart);
    on<UpdateQuantityEvent>(_onUpdateQuantity);
    on<RemoveFromCartEvent>(_onRemoveFromCart); // Handler for RemoveFromCartEvent
    // You can add handlers for other events here, such as RemoveFromCartEvent and UpdateQuantityEvent.
  }

  // Handler for AddToCartEvent
  void _onAddToCart(AddToCartEvent event, Emitter<CartState> emit) {
    List<CartItem> updatedCartItems = [];

    // Check if the current state is CartUpdatedState
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

    // Emit the updated cart state
    emit(CartUpdatedState(cartItems: updatedCartItems));
  }

  //Handler for UpdateQuantityEvent

  void _onUpdateQuantity(UpdateQuantityEvent event, Emitter<CartState> emit){
    List<CartItem> updatedCartItems = [];

    // Check if the current state is CartUpdatedState
    if (state is CartUpdatedState) {
      updatedCartItems = List<CartItem>.from((state as CartUpdatedState).cartItems);
    }

    // Find the item in the cart and update its quantity
    final existingItemIndex = updatedCartItems.indexWhere((item) => item.title == event.cartItem.title);

    if (existingItemIndex != -1) {
      updatedCartItems[existingItemIndex].quantity = event.quantity; // Update the quantity
    }

    // Emit the updated cart state
    emit(CartUpdatedState(cartItems: updatedCartItems));

  }

  //Handler for RemoveFromCartEvent

  void _onRemoveFromCart(RemoveFromCartEvent event,Emitter<CartState> emit){
    List<CartItem> updatedCartItems = [];

     // Check if the current state is CartUpdatedState
    if (state is CartUpdatedState) {
      updatedCartItems = List<CartItem>.from((state as CartUpdatedState).cartItems);
    }

    // Remove the item from the cart
    updatedCartItems.removeWhere((item) => item.title == event.cartItem.title);

    // Emit the updated cart state (after removal)
    emit(CartUpdatedState(cartItems: updatedCartItems));
  }
}
