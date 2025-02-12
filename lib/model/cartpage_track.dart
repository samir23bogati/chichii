import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:padshala/Billing/BillingConfirmationPage.dart';
import 'package:padshala/blocs/foodpromo1/cart_bloc.dart';
import 'package:padshala/blocs/foodpromo1/cart_event.dart';
import 'package:padshala/blocs/foodpromo1/cart_state.dart';
import 'package:padshala/login/auth_provider.dart';
import 'package:padshala/login/login_page.dart';
import 'package:padshala/model/cart_item.dart';
import 'package:provider/provider.dart';

import '../login/map/address_selection_page.dart';

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
    // Trigger cart load when the page is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("triggering loadcartevent");
      context.read<CartBloc>().add(LoadCartEvent()); // Dispatch LoadCartEvent
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Cart"),
      ),
      body: BlocBuilder<CartBloc, CartState>( // Listen to CartBloc changes
        builder: (context, state) { 

          if (state is CartLoadingState) {
            print("cart is loading");
            return const Center(child: CircularProgressIndicator());
          } else if (state is CartUpdatedState) {
            final cartItems = state.cartItems;
            return cartItems.isNotEmpty
                ? ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      print("Displaying Item: ${item.title}, Quantity: ${item.quantity}");
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        child: ListTile(
                          leading: Image.asset(item.imageUrl),
                          title: Text(item.title),
                          subtitle: Text('Price: NRS ${item.price.toStringAsFixed(2)}\nQuantity: ${item.quantity}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () {
                                   print("Decreasing Quantity for: ${item.title}");
                                  if (item.quantity > 1) {
                                    // Decrease quantity by 1
                                  
                                    context.read<CartBloc>().add(
                                          UpdateQuantityEvent(
                                            cartItem: item.copyWith(quantity: item.quantity - 1),
                                            isIncrement: false,
                                             quantity: item.quantity - 1, // Decrement
                                          ),
                                        );
                                  } else {
                                       print("Removing Item: ${item.title}");
                                    context.read<CartBloc>().add(
                                          RemoveFromCartEvent(cartItem: item), // Remove if quantity is 1
                                        );
                                  }
                                },
                              ),
                              Text('${item.quantity}', style: const TextStyle(fontSize: 16)),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  print("Increasing Quantity for: ${item.title}");
                                  // Increase quantity by 1
                                  context.read<CartBloc>().add(
                                          UpdateQuantityEvent(
                                            cartItem: item.copyWith(quantity: item.quantity + 1),
                                            isIncrement: true, 
                                            quantity: item.quantity + 1, // Increment
                                          ),
                                        );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                   print("Deleting Item: ${item.title}");
                                  context.read<CartBloc>().add(
                                        RemoveFromCartEvent(cartItem: item), // Delete the item
                                      );
                                },
                              ),
                            ],
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
                style: const TextStyle(fontSize: 18, color: Colors.red),
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
                        print("Proceed to Checkout Pressed");
                        final authProvider =
                            Provider.of<AuthProvider>(context, listen: false);
                        if (authProvider.user == null) {
                          bool? loggedIn = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LoginPage(
                                 cartItems: cartItems,
                                 totalPrice: state.totalPrice,
                            ),),
                          );

                          if (loggedIn == null || !loggedIn) return;
                        }

                        // Navigate to Address Selection Page
                        print("Navigating to Address Selection Page");
                        final selectedLocation = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddressSelectionPage(
                                 cartItems: cartItems,
                                 totalPrice: state.totalPrice,
                              )),
                        );
                        if (selectedLocation != null) {
                          print("Selected Address: $selectedLocation");
                         
                         Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>BillingConfirmationPage(
                              address: selectedLocation,
                             cartItems: cartItems, totalPrice: state.totalPrice,
                             ),

                          ),
                         );
                        }
                      },
                      child: const Text("PROCEED TO CHECKOUT"),
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink(); // Hide if cart is empty
        },
      ),
    );
  }
}
