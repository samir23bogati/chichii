import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:padshala/blocs/foodpromo1/cart_event.dart';
import 'package:padshala/blocs/foodpromo1/cart_state.dart';
import 'package:padshala/model/cart_item.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  List<CartItem> _cartItems = [];

  CartBloc() : super(CartInitialState());

  @override
  Stream<CartState> mapEventToState(CartEvent event) async* {
      print('Received event: $event'); 
    if (event is AddToCartEvent) {
      _cartItems.add(event.cartItem);
      // Yielding a new CartUpdatedState with a new copy of the list
      yield CartUpdatedState(cartItems: List.from(_cartItems));
    } else if (event is RemoveFromCartEvent) {
      _cartItems.remove(event.cartItem);
      // Yielding a new CartUpdatedState with a new copy of the list
      yield CartUpdatedState(cartItems: List.from(_cartItems));
    } else if (event is UpdateQuantityEvent) {
      final index = _cartItems.indexOf(event.cartItem);
      if (index != -1) {
        _cartItems[index].quantity += event.quantity;

      print('Updated quantity: ${_cartItems[index].quantity}');

    print('Updated quantity: ${_cartItems[index].quantity}'); // Check the updated quantity
        if (_cartItems[index].quantity <= 0) {
          _cartItems.removeAt(index); // Remove item if quantity is 0 or less
        }
      }
      // Yielding a new CartUpdatedState with a new copy of the list
      yield CartUpdatedState(cartItems: List.from(_cartItems));
    }
  }
}
