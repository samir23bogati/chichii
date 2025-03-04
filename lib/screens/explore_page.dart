import 'package:flutter/material.dart';
import 'package:padshala/screens/exploretab_page.dart';

class ExplorePage extends StatelessWidget {
  final List<Map<String, String>> categories = [
    {'title': 'Exclusive Deals', 'image': 'assets/images/exclusive_deals.jpg'},
    {'title': 'Cooked Food', 'image': 'assets/images/cookedfood.png'},
    {'title': 'Sides', 'image': 'assets/images/sides.jpg'},
    {'title': 'Chicken Meals', 'image': 'assets/images/chicken_buckets.jpg'},
    {'title': 'Veg Items', 'image': 'assets/images/chicken_buckets.jpg'},
    {'title': 'Beverages', 'image': 'assets/images/beverages2.jpg'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      color: Colors.white, // Background color to match UI
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("EXPLORE MENU", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ExploretabPage(initialIndex: 0)));
                  },
                  child: Text("View All", style: TextStyle(color: Colors.blue, fontSize: 16)),
                ),
              ],
            ),
            SizedBox(
             height: (categories.length / 3).ceil() * 120,
            child: GridView.builder(
              physics: NeverScrollableScrollPhysics(),
          
              itemCount: categories.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ExploretabPage(initialIndex: index)),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                      boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black12)],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(categories[index]['image']!, height: 60),
                        SizedBox(height: 10),
                        Text(categories[index]['title']!, style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              },
            ),
            ),
          ],
        ),
      ),
    );
  }
}
