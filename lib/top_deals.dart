import 'package:flutter/material.dart';
import 'package:padshala/topdeal_detailpage.dart';

class TopDeals extends StatelessWidget {
  static final List<Map<String, String>> _topDeals = [
    {'title': 'Buff Steam Mo:Mo', 'image': 'assets/images/cookedfood.png', 'price': '100'},
    {'title': 'Chicken Choila', 'image': 'assets/images/cookedfood.png', 'price': '250'},
    {'title': 'Sukuti Sadeko', 'image': 'assets/images/cookedfood.png', 'price': '300'},
    {'title': 'Fried Mo:Mo', 'image': 'assets/images/cookedfood.png', 'price': '150'},
  ];

  const TopDeals({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "TOP DEALS",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10), 
          SizedBox(
            height: 180, 
            child: PageView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _topDeals.length,
              controller: PageController(viewportFraction: 0.5), 
              itemBuilder: (context, index) {
                final deal = _topDeals[index % _topDeals.length]; 
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TopDealDetailPage(
                          title: deal['title']!,
                          image: deal['image']!,
                          price: deal['price']!,
                          topDeals: _topDeals,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 8),
                      width: 321.4, 
                    height: 112.83,
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                     borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            deal['image']!,
                            height: 80,
                            width: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 10), 
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                deal['title']!,
                                style: TextStyle(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis, 
                                maxLines: 1,  
                              ),
                              SizedBox(height: 4), 
                              Text(
                                "NRS ${deal['price']}",
                                style: TextStyle(color: Colors.green),
                              ),
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Icon(Icons.arrow_forward_ios, size: 16),
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