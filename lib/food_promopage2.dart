import 'package:flutter/material.dart';
class FoodPromopage2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Grab, Pack, Feast!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          FoodItemCard(
            imagePath: 'assets/images/fastfood.jpg',
            title: 'Jumbo Jeera Stirred Jeera Rice [3 Person]',
            price: 'Rs 395.00',
          ),
          FoodItemCard(
              imagePath: 'assets/images/fastfood.jpg',
            title: 'Spicy Fried & Stirred Chicken / Murga Lollipop 6pc [1 Person]',
            price: 'Rs 380.00',
          ),
          FoodItemCard(
              imagePath: 'assets/images/fastfood.jpg',
            title: 'Umami Fried and Stirred Chicken Chili [1 Person]',
            price: 'Rs 375.00',
          ),
        ],
      ),
    );
  }
}

class FoodItemCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String price;

  const FoodItemCard({
    required this.imagePath,
    required this.title,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(10.0),
            ),
            child: Image.asset(
              imagePath,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                 SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Row(
                    //   children: List.generate(5, (index) {
                    //     return Icon(
                    //       Icons.star_border,
                    //       color: Colors.grey,
                    //     );
                    //   }),
                    // ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () {
                            // Decrease quantity functionality
                          },
                        ),
                        Text('1'),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            // Increase quantity functionality
                          },
                        ),
                      ],
                    ),
                   SizedBox(height: 4), 
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: Icon(Icons.add_shopping_cart),
                        onPressed: () {
                          // Add to cart functionality here
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
