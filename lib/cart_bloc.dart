import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:padshala/blocs/foodpromo1/cart_event.dart';
import 'package:padshala/blocs/foodpromo1/cart_state.dart';
import 'package:padshala/model/cart_item.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  List<CartItem> _cartItems = [];

  CartBloc() : super(CartInitialState());

  @override
  Stream<CartState> mapEventToState(CartEvent event) async* {
    if (event is AddToCartEvent) {
      _cartItems.add(event.cartItem);
       yield CartUpdatedState(cartItems: _cartItems);
    } else if (event is RemoveFromCartEvent) {
      _cartItems.remove(event.cartItem);
       yield CartUpdatedState(cartItems: _cartItems);
    } else if (event is UpdateQuantityEvent) {
      final index = _cartItems.indexOf(event.cartItem);
      if (index != -1) {
        _cartItems[index].quantity += event.quantity;
        if (_cartItems[index].quantity <= 0) {
          _cartItems.removeAt(index); // Remove item if quantity is 0 or less
        }
         yield CartUpdatedState(cartItems: _cartItems);
      }
    }
  }
}
