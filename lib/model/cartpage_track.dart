import 'package:flutter/material.dart';
import 'package:padshala/model/cart_item.dart';

class CartPage extends StatelessWidget {
  final List<CartItem> cartItems;
  final Function(CartItem) onRemoveItem;
  final Function(CartItem, int) onUpdateQuantity;

  CartPage({
    required this.cartItems,
    required this.onRemoveItem,
    required this.onUpdateQuantity,
  });

 double calculateTotalPrice() {
  double total = 0;
  for (var item in cartItems) {
   total +=  item.price * item.quantity;
  }
  return total;
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Cart"),
      ),
      body: ListView.builder(
        itemCount: cartItems.length,
        itemBuilder: (context, index) {
          final item = cartItems[index];
          return ListTile(
            leading: Image.asset(item.imageUrl, width: 50, height: 50),
            title: Text(item.title),
            subtitle: Text('Price: \NRS ${item.price}\nQuantity: ${item.quantity}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () {
                    if (item.quantity > 1) {
                      onUpdateQuantity(item, -1); // Decrease quantity by 1
                    } else {
                      onRemoveItem(item); // Remove item if quantity is 1
                    }
                  },
                ),
                Text('${item.quantity}'),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    onUpdateQuantity(item, 1); // Increase quantity by 1
                  },
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: \NRS ${calculateTotalPrice().toStringAsFixed(2)}', // Display total price
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Handle checkout or other action here
                },
                child: Text("Checkout"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
