import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({Key? key}) : super(key: key);

  Future<String?> _getCurrentUserPhoneNumber() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.phoneNumber;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: FutureBuilder<String?>(
        future: _getCurrentUserPhoneNumber(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('User not logged in.'));
          }

          String phoneNumber = snapshot.data!;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('orders')
                .where('phoneNumber', isEqualTo: phoneNumber)
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, orderSnapshot) {
              if (orderSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!orderSnapshot.hasData || orderSnapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No orders found.'));
              }

              final orders = orderSnapshot.data!.docs;

              return ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final items = List<Map<String, dynamic>>.from(order['items']);
                  final timestamp = order['timestamp'] as Timestamp;
                  final formattedDate =
                      DateFormat('dd MMM yyyy, hh:mm a').format(timestamp.toDate());

                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Order ID: ${order['orderId']}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          SizedBox(height: 4),
                          Text('Order Time: $formattedDate'),
                          Text('Status: ${order['status'] ?? 'Pending'}'),
                          Text('Total: NRS ${order['totalPrice']}'),
                          Text('Delivery Cost: NRS ${order['deliveryCost']}'),
                          Text('Payment: ${order['paymentMethod']}'),
                          const SizedBox(height: 8),
                          Text('Items:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          ...items.map((item) => Text(
                              "- ${item['title']} x${item['quantity']}")),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
