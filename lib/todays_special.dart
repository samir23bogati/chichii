
import 'package:flutter/material.dart';

class TodaySpecialPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            // Handle menu action
          },
        ),
        title: Center(
          child: Image.asset(
          'assets/images/logo.webp',  
        ),
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.shopping_cart),
                Positioned(
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: Text(
                      '0',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {
              // Handle shopping cart action
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductCard(imagePath: 'assets/images/lays.png', name: "Lay's Classic"),
            ProductCard(imagePath: 'assets/images/cocacola.png', name: "Coca-Cola"),
            ProductCard(imagePath: 'assets/images/fanta.png', name: "Fanta"),
            ProductCard(imagePath: 'assets/images/cheeseball.png', name: "CurrenT Cheese Balls"),
            ProductCard(imagePath: 'assets/images/spicynoodles.png', name: "2 pm Instant Noodles"),
            ProductCard(imagePath: 'assets/images/maggi.png', name: "Maggi Noodles"),
          ],
        ),
      ),
    );
    
  }
}

class ProductCard extends StatelessWidget {
  final String imagePath;
  final String name;

  const ProductCard({required this.imagePath, required this.name});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        leading: Image.asset(imagePath, width: 50, height: 50),
        title: Text(name),
      ),
    );
  }
}
