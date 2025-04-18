import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
  State<BillingConfirmationPage> createState() =>
      _BillingConfirmationPageState();
}

class _BillingConfirmationPageState extends State<BillingConfirmationPage> {
  double? deliveryCost;
  bool isLoading = true;
  String userPhoneNumber = "Not Available";
  String userEmail = "Not Available";
  @override
  void initState() {
    super.initState();
    _fetchDeliveryCost();

   // Get user phone number or email
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
    userPhoneNumber = user?.phoneNumber ?? "Not Available";
    userEmail = user?.email ?? "Not Available";
  });
}

  Future<void> _fetchDeliveryCost() async {
    try {
      var result = await calculateDistance(widget.userLat, widget.userLng);

      if (result is Map<String, dynamic> && result.containsKey('cost')) {
        setState(() {
          deliveryCost = result['cost'] as double;
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

  Future<bool> checkIfUserIsAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    debugPrint("🔥 Current User PhoneNumber: ${user?.phoneNumber}");
    if (user == null) return false;

    
    final doc = await FirebaseFirestore.instance
        .collection('admins')
        .doc(user.phoneNumber)
        .get();

        print('Admin Doc Data: ${doc.data()}'); 

    
    return doc.exists && doc.data()?['isAdmin'] == true;
  }

  Future<void> saveAdminFcmToken() async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && fcmToken != null) {
      await FirebaseFirestore.instance
          .collection("admin_tokens")
          .doc(user.phoneNumber) // or user.uid
          .set({"token": fcmToken});
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
            Text("We'll Deliver Your Order Here:",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.green), 
                SizedBox(width: 8), 
                Expanded(
                  child: Text(widget.address,
                      style: TextStyle(fontSize: 15, color: Colors.grey[700])),
                ),
              ],
            ),
            const SizedBox(height: 10),

            //Order Summary
            Text("Order Summary:",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
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
                            child: isLocalAsset
                                ? Image.asset(
                                    item.imageUrl,
                                    fit: BoxFit.cover,
                                  )
                                : Image.network(
                                    item.imageUrl,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, _) => Icon(
                                            Icons.broken_image,
                                            size: 50,
                                            color: Colors.grey),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Item Details Section
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.title,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              Text("Quantity: ${item.quantity}",
                                  style: TextStyle(color: Colors.grey[600])),
                              Text("Price: NRS ${item.price}",
                                  style: TextStyle(color: Colors.grey[600])),
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
            Text("Subtotal: NRS ${widget.totalPrice}",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

            isLoading
                ? CircularProgressIndicator()
                : Text(
                    "Delivery Cost: NRS ${deliveryCost?.toStringAsFixed(2) ?? "0"}",
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),

            Divider(),
            Text("Total Price: NRS ${finalPrice.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          print("Cash on Delivery button pressed!");
                          _placeOrder(context, "COD", finalPrice);
                        },
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text("Cash on Delivery"),
                ),
                ElevatedButton( 
                  onPressed: () {
                    _placeOrder(context, "Khalti", finalPrice);
                  },
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                  child: const Text("Pay with Khalti"), //192.168.1.254
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _placeOrder(
      BuildContext context, String paymentMethod, double finalPrice) async {
    if (isLoading) return;

    try {
      final orderRef = FirebaseFirestore.instance.collection('orders').doc();
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        print("❌ No user is logged in. Cannot place order.");
        return;
      }

      Map<String, dynamic> orderData = {
        "orderId": orderRef.id,
        "userId": user.uid,
        "address": widget.address,
        "email": userEmail,
        "phoneNumber": userPhoneNumber,
        "items": widget.cartItems
            .map((item) => {
                  "title": item.title,
                  "quantity": item.quantity,
                  "price": item.price,
                  "imageUrl": item.imageUrl,
                })
            .toList(),
        "totalPrice": finalPrice,
        "deliveryCost": deliveryCost,
        "paymentMethod": paymentMethod,
        "status": "Pending",
        "timestamp": Timestamp.now(),
      };

      await saveOrder(orderRef.id, orderData);
      await _sendAdminNotification(orderRef.id, orderData);

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), // Rounded corners
            ),
            title: Column(
              children: [
                Icon(Icons.check_circle,
                    color: Colors.green, size: 60), // Success Icon
                SizedBox(height: 10),
                Text(
                  "Order Placed!",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ],
            ),
            content: Text(
              "Your order has been successfully sent to Chichionline.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber, // Custom button color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Rounded button
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.popUntil(context,
                        (route) => route.isFirst); // Navigate back to home
                  },
                  child: Text(
                    "OK",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print("Error placing order: $e");
    }
  }

  Future<void> saveOrder(String orderId, Map<String, dynamic> orderData) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .set(orderData);
    } catch (e) {
      print("Error saving order: $e");
    }
  }

  Future<void> _sendAdminNotification(
      String orderId, Map<String, dynamic> orderData) async {
    try {
      await FirebaseFirestore.instance.collection('admin_notifications').add({
        "orderId": orderId,
        "message": "New order placed with ID: $orderId",
        "address": orderData["address"],
        "phoneNumber": orderData["phoneNumber"],
        "cartItems": orderData["items"],
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
