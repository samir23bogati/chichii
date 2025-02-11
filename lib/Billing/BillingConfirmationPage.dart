import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:padshala/model/cart_item.dart';

class BillingConfirmationPage extends StatelessWidget {
  final String address;
  final List<CartItem> cartItems;
  final double totalPrice;

  const BillingConfirmationPage({
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
                    title: Text(item.title),
                    subtitle: Text("Quantity: ${item.quantity} - Price: NRS ${item.price}"),
                  );
                },
              ),
            ),
            Text("Total Price: NRS $totalPrice", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
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

  void _placeOrder(BuildContext context, String paymentMethod) async {
    final orderData = {
      "address": address,
      "items": cartItems.map((item) => {
            "title": item.title,
            "quantity": item.quantity,
            "price": item.price,
          }).toList(),
      "totalPrice": totalPrice,
      "paymentMethod": paymentMethod,
      "status": "Pending",
      "timestamp": Timestamp.now(),
    };

    // Place the order in Firebase Firestore
    await OrderService().placeOrder(orderData);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Order placed successfully!")),
    );

    Navigator.pop(context); // Go back to previous page
  }
}

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> placeOrder(Map<String, dynamic> orderData) async {
    try {
      await _firestore.collection('orders').add(orderData); // Add order data to Firestore collection
    } catch (e) {
      print("Error placing order: $e");
    }
  }
}
