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
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "TOP DEALS 💰",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10), 
          SizedBox(
            height: 160, 
            child: PageView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _topDeals.length,
              controller: PageController(viewportFraction: 0.72), 
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
                      width: 321, 
                    height: 112,
                    padding: EdgeInsets.all(10),
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
                            height: 120,
                            width: 75,
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
                                style: TextStyle(fontSize:14 ,fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis, 
                                maxLines: 1,  
                              ),
                              SizedBox(height: 6), 
                              Text(
                                "NRS ${deal['price']}",
                                style: TextStyle(fontSize:14 ,fontWeight: FontWeight.bold,color: Colors.green),
                              ),
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Icon(Icons.arrow_forward_ios, size: 20),
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