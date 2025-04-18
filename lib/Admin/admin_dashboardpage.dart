import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatefulWidget {
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final List<String> adminPhoneNumbers = ['+9779813629126'];

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
        final isAdmin = adminPhoneNumbers.contains(user.phoneNumber);

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
                  final data = order.data() as Map<String, dynamic>;
                  final timestamp =
                      (data['timestamp'] as Timestamp?)?.toDate() ??
                          DateTime.now();
                  final phoneNumber = data.containsKey('phoneNumber')
                      ? data['phoneNumber']
                      : 'Unknown';
                  final orderId =
                      data.containsKey('orderId') ? data['orderId'] : 'N/A';
                  return ListTile(
                    title: Text(
                        "New Order Received From :$phoneNumber ,Order ID:$orderId"),
                    subtitle: Text("Order Time: ${timestamp.toString()}"),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          final data = order.data() as Map<String, dynamic>;
                          if (data == null ||
                              data['phoneNumber'] == null ||
                              data['orderId'] == null ||
                              data['address'] == null ||
                              data['paymentMethod'] == null ||
                              data['deliveryCost'] == null ||
                              data['totalPrice'] == null) {
                            return const Center(
                                child: Text(
                                    "Incomplete order data. Please try again."));
                          }
                          final cartItems = List<Map<String, dynamic>>.from(
                              data['items'] ?? []);
                          final timestamp =
                              (data['timestamp'] as Timestamp?)?.toDate() ??
                                  DateTime.now();

                          return AlertDialog(
                            title: const Text("Order Details"),
                            content: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      "🕒 Ordered on: ${timestamp.toString()}"),
                                  Text(
                                      "🆔 Order ID: ${data['orderId']}"),
                                  Text(
                                      "📞 Phone: ${data['phoneNumber']}"),
                                  Text(
                                      "🏠 Delivery Address: ${data['address']}"),
                                  Text(
                                      "💳 Payment: ${data['paymentMethod']}"),
                                  Text(
                                      "🚚 Delivery Cost: NRS ${data['deliveryCost']}"),
                                  Text(
                                      "🧾 Total Price: NRS ${data['totalPrice']}"),
                                  const SizedBox(height: 10),
                                  const Text("🛒 Cart Items:",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  ...cartItems.map((item) {
                                    return ListTile(
                                      leading: Image.network(
                                        item['imageUrl'],
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Icon(Icons.broken_image,
                                              size: 40, color: Colors.grey);
                                        },
                                      ),
                                      title: Text(item['title']),
                                      subtitle: Text(
                                          "Price: NRS ${item['price']} × ${item['quantity']}"),
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
