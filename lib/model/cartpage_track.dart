import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:padshala/Billing/BillingConfirmationPage.dart';
import 'package:padshala/blocs/foodpromo1/cart_bloc.dart';
import 'package:padshala/blocs/foodpromo1/cart_event.dart';
import 'package:padshala/blocs/foodpromo1/cart_state.dart';
import 'package:padshala/login/auth/auth_bloc.dart';
import 'package:padshala/login/auth/auth_state.dart';
import 'package:padshala/login/map/address_selection_page.dart'
    as address_selection_page;
import 'package:padshala/login/login_page.dart';
import 'package:padshala/model/cart_item.dart';

class CartPage extends StatelessWidget {
  final List<CartItem> cartItems; // Cart items passed as argument
  final Function(CartItem) onRemoveItem;
  final Function(CartItem, int) onUpdateQuantity;

  CartPage({
    required this.cartItems,
    required this.onRemoveItem,
    required this.onUpdateQuantity,
  });

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartBloc>().add(LoadCartEvent());
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Cart"),
        backgroundColor: Colors.amber,
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is CartLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CartUpdatedState) {
            final cartItems = state.cartItems;
            return cartItems.isNotEmpty
                ? ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Card(
                        elevation: 2.5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            leading: SizedBox(
                              width: 60,
                              height: 90,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  item.imageUrl,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            title: Text(
                              item.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            subtitle: Text(
                              'Price: NRS ${item.price.toStringAsFixed(2)}\nQuantity: ${item.quantity}',
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black38),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () {
                                    if (item.quantity > 1) {
                                      // Decrease quantity by 1

                                      context.read<CartBloc>().add(
                                            UpdateQuantityEvent(
                                              cartItem: item.copyWith(
                                                  quantity: item.quantity - 1),
                                              isIncrement: false,
                                              quantity: item.quantity -
                                                  1, // Decrement
                                            ),
                                          );
                                    } else {
                                      context.read<CartBloc>().add(
                                            RemoveFromCartEvent(
                                                cartItem:
                                                    item), // Remove if quantity is 1
                                          );
                                    }
                                  },
                                ),
                                Text('${item.quantity}',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    // Increase quantity by 1
                                    context.read<CartBloc>().add(
                                          UpdateQuantityEvent(
                                            cartItem: item.copyWith(
                                                quantity: item.quantity + 1),
                                            isIncrement: true,
                                            quantity:
                                                item.quantity + 1, // Increment
                                          ),
                                        );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    context.read<CartBloc>().add(
                                          RemoveFromCartEvent(
                                              cartItem:
                                                  item), // Delete the item
                                        );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : const Center(
                    child: Text(
                      'Your cart is empty.',
                      style: TextStyle(fontSize: 18),
                    ),
                  );
          } else if (state is CartErrorState) {
            return Center(
              child: Text(
                state.errorMessage,
                style: const TextStyle(fontSize: 18),
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      bottomNavigationBar: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is CartUpdatedState && state.cartItems.isNotEmpty) {
            return BottomAppBar(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: NRS ${state.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final authState = context.read<AuthBloc>().state;
                        print('Current auth state: $authState');

                        if (authState is! Authenticated) {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginPage(
                                cartItems: state.cartItems,
                                totalPrice: state.totalPrice,
                              ),
                            ),
                          );
                        }
                        final updatedAuthState = context.read<AuthBloc>().state;
                        if (updatedAuthState is Authenticated) {
                          final selectedLocation = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  address_selection_page.AddressSelectionPage(
                                cartItems: state.cartItems,
                                totalPrice: state.totalPrice,
                              ),
                            ),
                          );

                          if (selectedLocation != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BillingConfirmationPage(
                                  address: selectedLocation,
                                  cartItems: state.cartItems,
                                  totalPrice: state.totalPrice,
                                  userLat: selectedLocation.latitude,
                                  userLng: selectedLocation.longitude,
                                  onClearCart: () {
                                    context.read<CartBloc>().add(ClearCart());
                                  },
                                ),
                              ),
                            );
                          }
                        }
                      },
                      child: const Text("PLACE ORDER"),
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
