import 'package:flutter/material.dart';
import 'package:padshala/best_sellerdetail.dart';

class BestSellerPage extends StatelessWidget {
  final List<Map<String, String>> bestSellers = [
    {'title': 'Item 1', 'image': 'assets/images/sdhekochick.jpg'},
    {'title': 'Item 2', 'image': 'assets/images/sdhekochick.jpg'},
    {'title': 'Item 3', 'image': 'assets/images/sdhekochick.jpg'},
    {'title': 'Item 4', 'image': 'assets/images/sdhekochick.jpg'},
    {'title': 'Item 5', 'image': 'assets/images/sdhekochick.jpg'},
    {'title': 'Item 6', 'image': 'assets/images/sdhekochick.jpg'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "BEST SELLER",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          SizedBox(
            height: 400, // Set an appropriate height based on your layout needs
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.6,
              ),
              itemCount: bestSellers.length,
              physics:
                  NeverScrollableScrollPhysics(), // Prevents nested scrolling issues
              itemBuilder: (context, index) {
                final item = bestSellers[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BestSellerDetailPage(),
                      ),
                    );
                  },
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                item['image']!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 155,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                item['title']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 4,
                        left: 4,
                        child: Container(
                           width: 47, 
                          height: 61, 
                          padding: EdgeInsets.symmetric(
                            horizontal: 2,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                           color: Color.fromRGBO(55, 39, 6, 1),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(3),
                              bottomRight: Radius.circular(3),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center, 
                            children: [
                              Text(
                                'BEST SELLER',
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11, // Adjust size as needed
                                ),
                              ),
                               Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 29, // Size of the star icon
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
