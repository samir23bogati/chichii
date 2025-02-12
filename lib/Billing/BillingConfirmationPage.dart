import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:padshala/model/cart_item.dart';

class BillingConfirmationPage extends StatelessWidget {
  final String address;
  final List<CartItem> cartItems;
  final double totalPrice;

  BillingConfirmationPage({
    required this.address,
    required this.cartItems,
    required this.totalPrice,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Billing Confirmation")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          
          children: [
            Text("Delivery Address: $address", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),

            Text("Order Summary:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  return ListTile(
                   leading: item.imageUrl.isNotEmpty
                        ? Image.network(
                            item.imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : Icon(Icons.image, size: 50),
                    title: Text(item.title), // Display item title
                    subtitle: Text("Quantity: ${item.quantity} - Price: NRS ${item.price}"),
                  );
                },
              ),
            ),
            
            // Display total price
            Text("Total Price: NRS $totalPrice", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // Payment buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _placeOrder(context, "COD");
                  },
                  child: const Text("Cash on Delivery"),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Placeholder for Khalti payment integration, can be implemented later
                    _placeOrder(context, "Khalti (Placeholder)");
                  },
                  child: const Text("Pay with Khalti (Later)"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Function to place an order
  void _placeOrder(BuildContext context, String paymentMethod) async {
    // Prepare order data to store in Firestore
    final orderData = {
      "address": address, // Add the address
      "items": cartItems.map((item) => {
            "title": item.title, // Item title
            "quantity": item.quantity, // Item quantity
            "price": item.price, // Item price
             "imageUrl": item.imageUrl, // Item image URL
          }).toList(),
      "totalPrice": totalPrice, // Total price of all items
      "paymentMethod": paymentMethod, // Chosen payment method
      "status": "Pending", // Default status for new orders
      "timestamp": Timestamp.now(), // Current timestamp for the order
    };

    // Call the service to save the order data in Firestore
    await OrderService().placeOrder(orderData);

    // Show a success message after placing the order
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Order placed successfully!")),
    );

    // Go back to the previous page
    Navigator.pop(context);
  }
}

// OrderService class to interact with Firebase Firestore
class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to add order data to Firestore
  Future<void> placeOrder(Map<String, dynamic> orderData) async {
    try {
      // Add the order data to the 'orders' collection in Firestore
      await _firestore.collection('orders').add(orderData);
    } catch (e) {
      // Handle errors if any
      print("Error placing order: $e");
    }
  }
}
