import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:padshala/Billing/distance_cost.dart';
import 'package:padshala/model/cart_item.dart';

class BillingConfirmationPage extends StatefulWidget {
  final String address;
  final double userLat;
  final double userLng;
  final List<CartItem> cartItems;
  final double totalPrice;

  BillingConfirmationPage({
    required this.address,
    required this.userLat,
    required this.userLng,
    required this.cartItems,
    required this.totalPrice,
    Key? key,
  }) : super(key: key);

  @override
  State<BillingConfirmationPage> createState() => _BillingConfirmationPageState();
}

class _BillingConfirmationPageState extends State<BillingConfirmationPage> {
  double? deliveryCost;
  bool isLoading = true;
  String userPhoneNumber = "Not Available";
  @override
  void initState() {
    super.initState();
    _fetchDeliveryCost();

    // Get user phone number in initState
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      userPhoneNumber = user?.phoneNumber ?? "Not Available";
    });
  }
  

Future<void> _fetchDeliveryCost() async {
  try {
    var result = await calculateDistance(widget.userLat, widget.userLng);
    
    // Ensure result is of type double
   if (result is Map<String, dynamic>) {
      double cost = result['cost'] as double; // Safe casting to double
      setState(() {
        deliveryCost = cost;
        isLoading = false;
      });
    } else {
      throw Exception("Invalid result format.");
    }
  } catch (e) {
    setState(() {
      deliveryCost = 0;
      isLoading = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
     double finalPrice = widget.totalPrice + (deliveryCost ?? 0);
    return Scaffold(
      appBar: AppBar(title: const Text("Billing Confirmation")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Delivery Address
            Text("Delivery Address:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(widget.address, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
            const SizedBox(height: 10),

            // Order Summary
            Text("Order Summary:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            // List of Items
            Expanded(
              child: ListView.builder(
                itemCount: widget.cartItems.length,
                itemBuilder: (context, index) {
                  final item = widget.cartItems[index];
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

      Divider(),
            Text("Subtotal: NRS ${widget.totalPrice}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

            isLoading
                ? CircularProgressIndicator()
                : Text("Delivery Cost: NRS ${deliveryCost?.toStringAsFixed(2) ?? "0"}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

            Divider(),
            Text("Total Price: NRS ${finalPrice.toStringAsFixed(2)}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed:isLoading ? null: () {
                    _placeOrder(context, "COD", finalPrice);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text("Cash on Delivery"),
                ),
                ElevatedButton(
                  onPressed: () {
                    _placeOrder(context, "Khalti", finalPrice);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                  child: const Text("Pay with Khalti"),//192.168.1.254
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

 void _placeOrder(BuildContext context, String paymentMethod, double finalPrice) async {
  print("Placing order with payment method: $paymentMethod");
  try {
    final orderRef = FirebaseFirestore.instance.collection('orders').doc();
     print("Order ID: ${orderRef.id}");
    final orderData = {
      "orderId": orderRef.id,
      "address": widget.address,
      "phoneNumber": userPhoneNumber,
      "items": widget.cartItems.map((item) => {
            "title": item.title,
            "quantity": item.quantity,
            "price": item.price,
            "imageUrl": item.imageUrl,
          }).toList(),
      "totalPrice": finalPrice,
      "deliveryCost": deliveryCost,
      "paymentMethod": paymentMethod,
      "status": "Pending",
      "timestamp": Timestamp.now(),
    };

    await orderRef.set(orderData);
     print("Order placed successfully!");
    await _sendAdminNotification(orderRef.id,orderData);
      print("Admin notification sent!");
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Order placed successfully!")));

    Navigator.pop(context);
  } catch (e) {
    print("Failed to place order: $e");
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to place order: $e")));
  }
}

Future<void> _sendAdminNotification(String orderId, Map<String, dynamic> orderData) async {
  try {
    await FirebaseFirestore.instance.collection('admin_notifications').add({
      "orderId": orderId,
      "message": "New order placed with ID: $orderId",
      "address": orderData["address"],
      "phoneNumber": orderData["phoneNumber"],  // Including phone number
      "cartItems": orderData["items"],  // Full cart details
      "totalPrice": orderData["totalPrice"],
      "deliveryCost": orderData["deliveryCost"],
      "paymentMethod": orderData["paymentMethod"],
      "timestamp": Timestamp.now(),
    });
  } catch (e) {
    print("Failed to send notification: $e");
  }
}
}