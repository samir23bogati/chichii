import 'package:flutter/material.dart';

class FoodPromopage1 extends StatefulWidget {
  const FoodPromopage1({super.key});

  @override
  State<FoodPromopage1> createState() => _FoodPromopage1State();
}

class _FoodPromopage1State extends State<FoodPromopage1> {
  late PageController _pageController;
  final List<Map<String, String>> promoItems = [
    {
      'title': 'Brazilian Chicken Drum[1 Person]',
      'description': 'Delicious grilled chicken drumsticks',
      'price': 'NRS 1525.00',
      'imageUrl': 'assets/images/chickendrum.jpg',
    },
    {
      'title': 'Jumbo Sour Marinated Chicken Sadeko[3 Person]',
      'description': 'Perfectly spiced chicken for sharing',
      'price': 'NRS 965.00',
      'imageUrl': 'assets/images/sdhekochick.jpg',
    },
     {
      'title': 'Brazilian Chicken Drum[1 Person]',
      'description': 'Delicious grilled chicken drumsticks',
      'price': 'NRS 1525.00',
      'imageUrl': 'assets/images/chickendrum.jpg',
    },
     {
      'title': 'Jumbo Sour Marinated Chicken Sadeko[3 Person]',
      'description': 'Perfectly spiced chicken for sharing',
      'price': 'NRS 965.00',
      'imageUrl': 'assets/images/sdhekochick.jpg',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.48,
      initialPage: promoItems.length*100,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      color:Colors.grey[200],
      child: FoodPromoContent(pageController: _pageController,promoItems: promoItems),
    );
  }
}

class FoodPromoContent extends StatelessWidget {
  final PageController pageController;
  final List<Map<String, String>> promoItems;
  FoodPromoContent({required this.pageController,required this.promoItems});

  @override
  Widget build(BuildContext context) {
    return  Column(
      crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Cooked Food,Great Taste',
             style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
          ),
          SizedBox(height: 10),
          Stack(
            children: [
              SizedBox(
                height: 375,

                child:PageView.builder(
                  controller: pageController,
                  scrollDirection: Axis.horizontal,
                  itemCount: null,
                  itemBuilder : (context,index){
                    int currentIndex = index % promoItems.length;
                    return PromoItem(
                    title: promoItems[currentIndex]['title']!,
                    description: promoItems[currentIndex]['description']!,
                    price: promoItems[currentIndex]['price']!,
                    imageUrl: promoItems[currentIndex]['imageUrl']!,
                  );
                  
                  },
                ),
              ),
                
             Positioned(
              top: 130,
              left: 0,
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Colors.black),
                onPressed: () {
                  pageController.previousPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ),
            // Right Arrow Button
            Positioned(
              top: 130,
              right: 0,
              child: IconButton(
                icon: Icon(Icons.arrow_forward_ios, color: Colors.black),
                onPressed: () {
                  pageController.nextPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ),
          ],
        ),
      ],
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
    return Card(
      margin: EdgeInsets.all(10.0),
      child: Container(
        height: 355,
        child: Column(
          children: [
            Container(
              height: 150,
              width: double.infinity,
              child: Image.asset(
                imageUrl,
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(description),
                  Text(price, style: TextStyle(color: Colors.green)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.add_shopping_cart),
                        onPressed: () {},
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}