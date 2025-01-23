import 'package:flutter/material.dart';
import 'package:padshala/model/cart_item.dart';

class CartPage extends StatefulWidget {
  final List<CartItem> cartItems;
  final Function(CartItem) onRemoveItem;
  final Function(CartItem, int) onUpdateQuantity; // New callback for quantity

  CartPage({
    required this.cartItems,
    required this.onRemoveItem,
    required this.onUpdateQuantity,
  });

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Cart"),
      ),
      body: ListView.builder(
        itemCount: widget.cartItems.length,
        itemBuilder: (context, index) {
          final item = widget.cartItems[index];
          return ListTile(
            leading: Image.asset(item.imageUrl, width: 50, height: 50),
            title: Text(item.title),
            subtitle: Text('Price: ${item.price}\nQuantity: ${item.quantity}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () {
                    if (item.quantity > 1) {
                      widget.onUpdateQuantity(item, -1); // Decrease quantity by 1
                    } else {
                      widget.onRemoveItem(item); // Remove item if quantity is 1
                    }
                  },
                ),
               Text('${item.quantity}'),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      widget.onUpdateQuantity(item, 1); // Increase quantity by 1
                    });
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}