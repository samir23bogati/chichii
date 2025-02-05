import 'package:equatable/equatable.dart';
import 'package:padshala/model/cart_item.dart';

abstract class CartEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class AddToCartEvent extends CartEvent {
  final CartItem cartItem;

  AddToCartEvent(this.cartItem, );

  @override
  List<Object> get props => [cartItem];
}

class RemoveFromCartEvent extends CartEvent {
  final CartItem cartItem;

  RemoveFromCartEvent(this.cartItem);

  @override
  List<Object> get props => [cartItem];
}

class UpdateQuantityEvent extends CartEvent {
  final CartItem cartItem;
  final int quantity;

  UpdateQuantityEvent(this.cartItem, this.quantity);

  @override
  List<Object> get props => [cartItem, quantity];
}
