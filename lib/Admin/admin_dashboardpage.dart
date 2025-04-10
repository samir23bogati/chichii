import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatefulWidget {
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final List<String> adminUIDs = [
    '8UkfWjkg9rN4XwmjbMKpRYtcBHx2',// User UID from Firestore firebase for 9813629126
  ];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: FirebaseAuth.instance.authStateChanges().first,
      builder: (context, snapshot) {
       if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text("User not logged in")),
          );
        }

        final user = snapshot.data!;
        final isAdmin = adminUIDs.contains(user.uid);

        if (!isAdmin) {
          return const Scaffold(
            body: Center(child: Text("Access Denied. Admins Only!")),
          );
        }


    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
      ),
      body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('orders')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text("Something went wrong."));
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final orders = snapshot.data!.docs;

              if (orders.isEmpty) {
                return const Center(child: Text("No orders available."));
              }

              return ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final timestamp = (order['timestamp'] as Timestamp).toDate();
                  return ListTile(
                    title: Text("New Order Received From :${order['phoneNumber']} ,Order ID:${order['orderId']}"),
                    subtitle: Text( "Order Time: ${timestamp.toString()}"   ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                           final cartItems = List<Map<String, dynamic>>.from(order['items']);
                           final timestamp = (order['timestamp'] as Timestamp).toDate();
                        
                          return AlertDialog(
                            title: const Text("Order Details"),
                            content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("🕒 Ordered on: ${timestamp.toString()}"),
              Text("🆔 Order ID: ${order['orderId']}"),
              Text("📞 Phone: ${order['phoneNumber']}"),
              Text("🏠 Delivery Address: ${order['address']}"),
              Text("💳 Payment: ${order['paymentMethod']}"),
              Text("🚚 Delivery Cost: NRS ${order['deliveryCost']}"),
              Text("🧾 Total Price: NRS ${order['totalPrice']}"),
              const SizedBox(height: 10),
              const Text("🛒 Cart Items:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...cartItems.map((item) {
                return ListTile(
                  leading: Image.network(item['imageUrl'], width: 40, height: 40, fit: BoxFit.cover,
                  errorBuilder: (context,error,stackTrace){
                    return Icon(Icons.broken_image,size:40,color: Colors.grey);
                  },
                  ),
                  title: Text(item['title']),
                  subtitle: Text("Price: NRS ${item['price']} × ${item['quantity']}"),
                );
              }).toList(),
            ],
          ),
        ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text("Close"),
                              ),
                            ],
                            );
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}