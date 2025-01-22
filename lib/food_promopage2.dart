import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FoodPromopage2 extends StatefulWidget {
  @override
  _FoodPromopage2State createState() => _FoodPromopage2State();
}

class _FoodPromopage2State extends State<FoodPromopage2> {
  late PageController _pageController;
  List<Map<String, String>> foodpromoItems = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 1,
      initialPage: 0,
    );
    _loadFeastPromoItems();
  }

  Future<void> _loadFeastPromoItems() async {
    String jsonString = await rootBundle.loadString('assets/json/feastpromo_items.json');
    List<dynamic> jsonData = json.decode(jsonString);
    setState(() {
      foodpromoItems = jsonData.map<Map<String, String>>((item) {
        return {
          'title': item['title'] ?? 'No Title',
          'price': item['price'] ?? 'N/A',
          'imageUrl': item['imageUrl'] ?? 'assets/images/default.webp',
        };
      }).toList();
    });
  }



  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
      int nextPage = (_pageController.page?.toInt()?? 0) + 1;
    if (foodpromoItems.isNotEmpty && nextPage >= foodpromoItems.length) {
      nextPage = 0; // Loop back to the first item
       }
        _pageController.animateToPage(
         nextPage,
          duration: Duration(milliseconds: 300),
           curve: Curves.easeInOut,
            );
             }

  void _previousPage(){
      int previousPage = _pageController.page!.toInt() - 1;
      if (previousPage < 0) { 
        previousPage = foodpromoItems.length - 1; // Loop back to the last item 
        }
        _pageController.animateToPage( 
          previousPage,
           duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
             );
    }
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
            Container(
                  height: 450,
                  color: Colors.amber,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios),
                        onPressed: _previousPage,
                      ),
                       Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: foodpromoItems.length,
                          itemBuilder: (context, index) {
                            return FoodItemCard(
                              imagePath: foodpromoItems[index]['imageUrl'] ?? 'assets/images/default.webp',
                              title: foodpromoItems[index]['title'] ?? 'No Title',
                              price: foodpromoItems[index]['price'] ?? 'N/A',
                            );
                          },
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_forward_ios),
                        onPressed: _nextPage,
                      ),
                    ],
                  ),
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
      child: Stack(
        children:[
          Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(10.0),
            ),
            child: Image.asset(
              imagePath,
              height: 250,
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
                  ],
                ),
              ),
            ],
          ),
                 
           Positioned(
            bottom: 10,
            left: 10,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () {
                    // Decrease quantity functionality
                  },
                ),
                Text(
                  '1',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    // Increase quantity functionality
                  },
                ),
              ],
            ),
          ),
      Positioned(
         bottom: 10,
          left: 10,
          child: IconButton(
           icon: Icon(Icons.remove),
       color: Colors.black,
        onPressed: () { 
        // Decrease quantity functionality
        },
         ),
          ),
      Positioned(
            bottom: 10,
            right: 10,
            child: IconButton(
              icon: Icon(Icons.add_shopping_cart),
              color: Colors.black,
              onPressed: () {
                // Add to cart functionality here
              },
            ),
          ),
        ],
      ),
    );
  }
}