import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
                  final formattedDate =
                      DateFormat('d MMMM yyyy, h:mm a').format(timestamp); 
                  final phoneNumber = data.containsKey('phoneNumber')
                      ? data['phoneNumber']
                      : 'Unknown';
                  final orderId =
                      data.containsKey('orderId') ? data['orderId'] : 'N/A';
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: const Icon(Icons.shopping_bag,
                          color: Colors.deepPurple),
                      title: Text(
                        "📞 $phoneNumber",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text("🆔 Order ID: $orderId"),
                          Text("🕒 $formattedDate"),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
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
                            final formattedDateDetail =
                                DateFormat('d MMMM yyyy, h:mm a')
                                    .format(timestamp);

                            return AlertDialog(
                              title: const Text("🧾 Order Details"),
                              content: SingleChildScrollView(
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("🕒 Ordered on: $formattedDateDetail"),
                                      const SizedBox(height: 6),
                                      Text("🆔 Order ID: ${data['orderId']}"),
                                      Text("📞 Phone: ${data['phoneNumber']}"),
                                      Text("🏠 Address: ${data['address']}"),
                                      Text(
                                          "💳 Payment: ${data['paymentMethod']}"),
                                      Text(
                                          "🚚 Delivery Cost: NRS ${data['deliveryCost']}"),
                                      Text(
                                          "💰 Total Price: NRS ${data['totalPrice']}"),
                                      const Divider(height: 20),
                                      const Text("🛒 Cart Items:",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 8),
                                      ...cartItems.map((item) {
                                        return Card(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 4),
                                          child: ListTile(
                                            leading: Image.network(
                                              item['imageUrl'],
                                              width: 40,
                                              height: 40,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  const Icon(
                                                      Icons.broken_image),
                                            ),
                                            title: Text(item['title']),
                                            subtitle: Text(
                                                "Price: NRS ${item['price']} × ${item['quantity']}"),
                                          ),
                                        );
                                      }).toList(),
                                    ],
                                  ),
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
                    ),
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
