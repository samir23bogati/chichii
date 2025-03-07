import 'package:flutter/material.dart';
import 'package:padshala/best_sellerdetail.dart';

class BestSellerPage extends StatelessWidget {
  final List<Map<String, String>> bestSellers = [
    {'title': 'Buff MoMo', 'image': 'assets/images/sdhekochick.jpg','price': ' NRS 450'},
    {'title': 'Chicken Biryani', 'image': 'assets/images/sdhekochick.jpg','price': 'NRS 850'},
    {'title': 'Chicken Lollipop', 'image': 'assets/images/sdhekochick.jpg','price': 'NRS 555'},
    {'title': 'Khukuri Rum', 'image': 'assets/images/sdhekochick.jpg','price': 'NRS 850'},
    {'title': 'Mustang Aloo', 'image': 'assets/images/sdhekochick.jpg','price': 'NRS 458'},
    {'title': 'Jumbo Pork Sekuwa', 'image': 'assets/images/sdhekochick.jpg','price': 'NRS 598'},
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
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          SizedBox(
            height: 425, 
            child: GridView.builder(

              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.55,
              ),
              itemCount: bestSellers.length,
              physics:NeverScrollableScrollPhysics(), 
              itemBuilder: (context, index) {
                final item = bestSellers[index];
            
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BestSellerDetailPage(
                           title: item['title']!,
                          image: item['image']!,
                          price: item['price']!,
                          bestSellers: bestSellers,
                        ),
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
                                height: 140,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                   Text(
                                  item['title']!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                             SizedBox(height: 4),
                              Text(
                               'NRS ${item['price']}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                                  ),
                                ],
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
                          height: 65, 
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
                                  fontSize: 12, 
                                ),
                              ),
                               Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 30, 
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
