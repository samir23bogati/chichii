import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:padshala/best_sellerdetail.dart';

class BestSellerPage extends StatefulWidget {
  @override
  State<BestSellerPage> createState() => _BestSellerPageState();
}

class _BestSellerPageState extends State<BestSellerPage> {
  List<Map<String, String>> bestSellers = [];

  @override
  void initState() {
    super.initState();
    _loadBestSellers();
  }

  // Function to load JSON data from assets
  Future<void> _loadBestSellers() async {
    final String response =
        await rootBundle.loadString('assets/json/bestseller.json');
    final List<dynamic> data = json.decode(response);
    setState(() {
      bestSellers = data.map((item) => Map<String, String>.from(item)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    PageController _controller = PageController(
      viewportFraction: 0.44,
      initialPage: 0,
    );
    if (bestSellers.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "BEST SELLERS 🌟",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          SizedBox(
            height: 258,
            child: ClipRect(
              child: PageView.builder(
                controller: _controller,
                itemCount: bestSellers.length,
                scrollDirection: Axis.horizontal,
                padEnds: false, 
                itemBuilder: (context, index) {
                  final item = bestSellers[index];
              
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
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
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Stack(
                                children: [
                                  // Full height image
                                  Positioned.fill(
                                    child: Image.asset(
                                      item['image']!,
                                      fit: BoxFit.cover, // Cover full box
                                    ),
                                  ),
                                  // Title overlapping the image
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      padding: EdgeInsets.all(5),
                                      color: Colors.black.withOpacity(0.001),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item['title']!,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13, 
                                                color: Colors.white,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            "→",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 30, 
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
              
                                  // SizedBox(height: 4),
                                  // Text(
                                  //   'NRS ${item['price']}',
                                  //   style: TextStyle(
                                  //     fontSize: 12,
                                  //     fontWeight: FontWeight.bold,
                                  //     color: Colors.green[700],
                                  //   ),
                                  // ),
              
                                  Positioned(
                                    top: 0,
                                    left: 7,
                                    child: RibbonWidget(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
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
