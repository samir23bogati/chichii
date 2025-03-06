import 'package:flutter/material.dart';

class BestSellerDetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Best Seller Details'),
        backgroundColor: Colors.brown,
      ),
      body: Column(
        children: [
          Image.asset('assets/images/delicious44.jpeg', height: 200, fit: BoxFit.cover),
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(Icons.fastfood, color: Colors.brown),
                  title: Text('Food Item ${index + 1}'),
                  subtitle: Text('\$${(index + 1) * 5}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
