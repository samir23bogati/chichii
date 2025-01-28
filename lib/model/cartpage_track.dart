import 'package:flutter/material.dart';
import 'package:padshala/model/cart_item.dart';

class CartPage extends StatefulWidget {
  final List<CartItem> initialCartItems;

  final Function(CartItem) onRemoveItem;
  final Function(CartItem, int) onUpdateQuantity;

  CartPage({required this.initialCartItems,
  
    required this.onRemoveItem,
    required this.onUpdateQuantity,});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late List<CartItem> cartItems;

  @override
  void initState() {
    super.initState();
    cartItems = List.from(widget.initialCartItems); // Initialize with initial cart items
  }

  // Calculate the total price of all items in the cart
  double calculateTotalPrice() {
    double total = 0;
    for (var item in cartItems) {
      total += item.price * item.quantity;
    }
    return total;
  }

  // Update the quantity of an item
  void updateQuantity(CartItem item, int change) {
    setState(() {
      final index = cartItems.indexOf(item);
      if (index != -1) {
        final newQuantity = cartItems[index].quantity + change;
        if (newQuantity > 0) {
          cartItems[index] = cartItems[index].copyWith(quantity: newQuantity);
        } else {
          cartItems.removeAt(index); // Remove the item if quantity becomes zero
        }
      }
    });
  }

  // Remove an item from the cart
  void removeItem(CartItem item) {
    setState(() {
      cartItems.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Cart"),
      ),
      body: cartItems.isNotEmpty
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
                            updateQuantity(item, -1); // Decrease quantity
                          },
                        ),
                        Text(
                          '${item.quantity}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            updateQuantity(item, 1); // Increase quantity
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
            ),
      bottomNavigationBar: cartItems.isNotEmpty
          ? BottomAppBar(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: NRS ${calculateTotalPrice().toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Handle checkout action
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
          : null,
    );
  }
}
