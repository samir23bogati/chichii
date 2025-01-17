import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BeveragePromoPage extends StatefulWidget {
  const BeveragePromoPage({super.key});

  @override
  State<BeveragePromoPage> createState() => _BeveragePromoPageState();
}

class _BeveragePromoPageState extends State<BeveragePromoPage> {
  late PageController _pageController;
  List<Map<String, dynamic>> promoItems = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.5,
      initialPage: 0,
    );
    _loaddrinkPromoItems();
  }
Future<void> _loaddrinkPromoItems()async{
  final String response =await rootBundle.loadString('assets/json/drinkspromo_items.json');
  final List<dynamic> data = json.decode(response);
  setState(() {
    promoItems = data.map((item) => item as Map<String,dynamic>).toList();
  });

}
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    int nextPage = (_pageController.page?.toInt() ?? 0) + 1;

    if (nextPage >= promoItems.length) {
      nextPage = 0; 
    }
    _pageController.animateToPage(
      nextPage,
      duration: Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _previousPage() {
    int previousPage = _pageController.page!.toInt() - 1;
    if (previousPage < 0) {
      previousPage = promoItems.length - 1; // Loop back to the last item
    }
    _pageController.animateToPage(
      previousPage,
      duration: Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      color: Colors.grey[200],
      child: BeveragePromoContent(
        pageController: _pageController,
        promoItems: promoItems,
        nextPage: _nextPage,
        previousPage: _previousPage,
      ),
    );
  }
}

class BeveragePromoContent extends StatelessWidget {
  final PageController pageController;
  final List<Map<String, dynamic>> promoItems;
  final VoidCallback nextPage;
  final VoidCallback previousPage;

  const BeveragePromoContent({
    required this.pageController,
    required this.promoItems,
    required this.nextPage,
    required this.previousPage,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Drink Up, Cool Down!',
            style:  TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Colors.black),
                onPressed: previousPage,
              ),
              Expanded(
                child: SizedBox(
                  height: 395, // Increase the height of the PageView
                  width: double.infinity,
                  child: PageView.builder(
                    controller: pageController,
                    itemCount: promoItems.length,
                    itemBuilder: (context, index) {
                      final item = promoItems[index];
                      return PromoItem(
                        title: item['title'] ?? 'No Title',
                        description: 'Alcoholic Beverage',
                        price: item['price'] ?? 'N/A',
                        imageUrl: item['imageUrl'] ?? 'assets/images/default.webp',
                      );
                    },
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward_ios, color: Colors.black),
                onPressed: nextPage,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PromoItem extends StatelessWidget {
  final String title;
  final String description;
  final String price;
  final String imageUrl;

  PromoItem({
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height:380,// Increase the height of the PromoItem
      child: Card(
        margin: EdgeInsets.all(10.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 5, // Add elevation for shadow effect
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 196, // Increase the height of the image
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(12.0),
                ),
                child: Image.asset(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.image, size: 50);
                  },
                ),
              ),
            ),
           Expanded(
             child: Padding(
               padding: const EdgeInsets.all(8.0),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text(
                     title,
                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                     maxLines: 2,
                     overflow: TextOverflow.ellipsis,
                   ),
                   SizedBox(height: 4),
                   Text(
                     description,
                     style: TextStyle(fontSize: 16, 
                     fontWeight: FontWeight.bold,
                     color: Colors.grey[700]),
                     maxLines: 2,
                     overflow: TextOverflow.ellipsis,
                   ),
                   SizedBox(height: 4),
                   Text(price, style: TextStyle(color: Colors.green,
                   fontSize: 16,
                   fontWeight: FontWeight.bold),
                   ),
                   Spacer(),
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
             ),
           ),
          ],
        ),
      ),
    );
  }
}