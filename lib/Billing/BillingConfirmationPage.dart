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
            // Delivery Address
            Text("Delivery Address:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(address, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
            const SizedBox(height: 10),

            // Order Summary
            Text("Order Summary:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            // List of Items
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  bool isLocalAsset = !item.imageUrl.startsWith('http');
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        // Image Section
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child:isLocalAsset
                                  ? Image.asset(
                                    item.imageUrl,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  )
                                  :Image.network(
                                    item.imageUrl,
                                    width: 60,
                                    height: 60,
                                    fit:BoxFit.cover,
                                    errorBuilder: (context,error,StackTrace) => Icon(Icons.broken_image,size: 50,color: Colors.grey),
                                  ),
                                  ),
                                ),
                        const SizedBox(width: 12),

                        // Item Details Section
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              Text("Quantity: ${item.quantity}", style: TextStyle(color: Colors.grey[600])),
                              Text("Price: NRS ${item.price}", style: TextStyle(color: Colors.grey[600])),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Total Price
            Divider(),
            Text("Total Price: NRS $totalPrice",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // Payment Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _placeOrder(context, "COD");
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text("Cash on Delivery"),
                ),
                ElevatedButton(
                  onPressed: () {
                    _placeOrder(context, "Khalti");
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                  child: const Text("Pay with Khalti"),
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
    final orderData = {
      "address": address,
      "items": cartItems.map((item) => {
            "title": item.title,
            "quantity": item.quantity,
            "price": item.price,
            "imageUrl": item.imageUrl,
          }).toList(),
      "totalPrice": totalPrice,
      "paymentMethod": paymentMethod,
      "status": "Pending",
      "timestamp": Timestamp.now(),
    };

    DocumentReference orderRef = await FirebaseFirestore.instance.collection('orders').add(orderData);
    await _sendAdminNotification(orderRef.id, orderData);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Order placed successfully!")),
    );

    Navigator.pop(context);
  }

  // Function to send admin notification
  Future<void> _sendAdminNotification(String orderId, Map<String, dynamic> orderData) async {
    await FirebaseFirestore.instance.collection('admin_notifications').add({
      "orderId": orderId,
      "message": "New order placed with ID: $orderId",
      "timestamp": Timestamp.now(),
    });
  }
}
