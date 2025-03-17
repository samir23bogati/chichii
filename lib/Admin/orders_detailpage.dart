import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderDetailsPage extends StatelessWidget {
  final QueryDocumentSnapshot order;
  OrderDetailsPage(this.order);

  @override
  Widget build(BuildContext context) {
    final List<dynamic> items = order['items'];

    return Scaffold(
      appBar: AppBar(title: const Text("Order Details")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Order ID: ${order.id}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text("Address: ${order['address']}", style: TextStyle(fontSize: 16)),
            Text("Payment: ${order['paymentMethod']}", style: TextStyle(fontSize: 16)),
            Text("Status: ${order['status']}", style: TextStyle(fontSize: 16, color: Colors.red)),
            SizedBox(height: 20),

            Text("Ordered Items:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Card(
                    child: ListTile(
                      leading: Image.network(item['imageUrl'], width: 50, height: 50, fit: BoxFit.cover),
                      title: Text(item['title']),
                      subtitle: Text("Qty: ${item['quantity']} | Price: NRS ${item['price']}"),
                    ),
                  );
                },
              ),
            ),
            
            Divider(),
            Text("Total Price: NRS ${order['totalPrice']}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
