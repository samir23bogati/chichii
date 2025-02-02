import 'package:flutter/material.dart';
import 'package:padshala/model/cart_item.dart';
import 'package:padshala/model/cart_provider.dart';
import 'package:provider/provider.dart';

class CartPage extends StatelessWidget {


  final List<CartItem> initialCartItems;

  final Function(CartItem) onRemoveItem;
  final Function(CartItem, int) onUpdateQuantity;

   const CartPage({Key? key, required this.initialCartItems,
   
    required this.onRemoveItem,
    required this.onUpdateQuantity,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
      // Get the CartProvider instance without listening to changes
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    // Ensure initial cart items are set
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (cartProvider.cartItems.isEmpty && initialCartItems.isNotEmpty) {
        cartProvider.setCartItems(initialCartItems, context);
      }
    });

   
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Cart"),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, _) {
          final cartItems = cartProvider.cartItems;
return cartItems.isNotEmpty
              ? ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      child: ListTile(
                        leading: Image.asset(
                          item.imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                        title: Text(item.title),
                        subtitle: Text(
                          'Price: NRS ${item.price.toStringAsFixed(2)}\nQuantity: ${item.quantity}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                cartProvider.updateQuantity(item, -1);
                              },
                            ),
                            Text(
                              '${item.quantity}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                cartProvider.updateQuantity(item, 1);
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
        },
      ),
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, cartProvider, _) {
          return cartProvider.cartItems.isNotEmpty
              ? BottomAppBar(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total: NRS ${cartProvider.calculateTotalPrice().toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Proceeding to checkout...")),
                            );
                          },
                          child: const Text("Checkout"),
                        ),
                      ],
                    ),
                  ),
                )
              :  const SizedBox.shrink();// return empty widget instead of null
        },
      ),
    );
  }
}
