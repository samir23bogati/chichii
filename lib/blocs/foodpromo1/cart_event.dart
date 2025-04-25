import 'package:padshala/model/cart_item.dart';

abstract class CartEvent {}

class AddToCartEvent extends CartEvent {
  final CartItem cartItem;
  AddToCartEvent({required this.cartItem});
}

class RemoveFromCartEvent extends CartEvent {
  final CartItem cartItem;
  RemoveFromCartEvent({required this.cartItem});
}

class UpdateQuantityEvent extends CartEvent {
  final CartItem cartItem;
  final int quantity;
  final bool isIncrement;
  UpdateQuantityEvent({required this.cartItem, required this.quantity,required this.isIncrement});
}

class LoadCartEvent extends CartEvent {}

class ClearCart extends CartEvent {}

class LoadFavoritesEvent extends CartEvent {}

