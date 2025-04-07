import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
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
        debugPrint("🛡 Admin UIDs: $adminUIDs");
        debugPrint("🔍 isAdmin: $isAdmin");

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
                  return ListTile(
                    title: Text("Order #${order['orderId']}"),
                    subtitle: Text(
                      "NRS ${order['totalPrice']} - ${order['phoneNumber']}",
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Order Details"),
                            content: SingleChildScrollView(
                              child: ListBody(
                                children: [
                                  Text("Order ID: ${order['orderId']}"),
                                  Text("Total Price: NRS ${order['totalPrice']}"),
                                  Text("Customer Phone: ${order['phoneNumber']}"),
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