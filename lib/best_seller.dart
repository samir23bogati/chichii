import 'package:flutter/material.dart';
import 'package:padshala/best_sellerdetail.dart';

class BestSellerPage extends StatelessWidget {
  final List<Map<String, String>> bestSellers = [
    {
      'title': 'Buff MoMo',
      'image': 'assets/images/sdhekochick.jpg',
      'price': '  450'
    },
    {
      'title': 'Chicken Biryani',
      'image': 'assets/images/sdhekochick.jpg',
      'price': ' 850'
    },
    {
      'title': 'Chicken Lollipop',
      'image': 'assets/images/sdhekochick.jpg',
      'price': ' 555'
    },
    {
      'title': 'Khukuri Rum',
      'image': 'assets/images/sdhekochick.jpg',
      'price': ' 850'
    },
    {
      'title': 'Mustang Aloo',
      'image': 'assets/images/sdhekochick.jpg',
      'price': ' 458'
    },
    {
      'title': 'Jumbo Pork Sekuwa',
      'image': 'assets/images/sdhekochick.jpg',
      'price': ' 598'
    },
  ];

  @override
  Widget build(BuildContext context) {
    PageController _controller = PageController(
      viewportFraction: 0.4, 
    );

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
            height: 280,
            child: PageView.builder(
              controller: _controller,
              itemCount: null, 
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final item = bestSellers[index % bestSellers.length]; // Looping over the items

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
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
                                  height: 216,
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
                          top: 0,
                          left: 0,
                          child: RibbonWidget(),
                        ),
                      ],
                    ),
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

class RibbonWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(
          painter: RibbonPainter(),
          size: Size(34, 52), // Adjust size as needed
        ),
        Positioned(
          top: 10,
          left: 6.5,
          child: Icon(
            Icons.star,
            color: Colors.amber,
            size: 24,
          ),
        ),
      ],
    );
  }
}

class RibbonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Color(0xFF372706) // Dark brown color
      ..style = PaintingStyle.fill;

    final Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height - 10); // Cut edge
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}