import 'package:flutter/material.dart';

class FoodPromopage1 extends StatefulWidget {
  const FoodPromopage1({super.key});

  @override
  State<FoodPromopage1> createState() => _FoodPromopage1State();
}

class _FoodPromopage1State extends State<FoodPromopage1> {
  late PageController _pageController;
  final List<Map<String, dynamic>> promoItems = [
    {
      'title': 'Brazilian Chicken Drum[1 Person]',
      'oldPrice':'Nrs 2000',
      'price': 'NRS 1525.00',
      'imageUrl': 'assets/images/chickendrum.jpg',
    },
    {
      'title': 'Jumbo Sour Marinated Chicken Sadeko[3 Person]',
      'oldPrice': null,
      'price': 'NRS 965.00',
      'imageUrl': 'assets/images/sdhekochick.jpg',
    },
    {
      'title': 'Brazilian Chicken Drum[1 Person]',
      'oldPrice':'Nrs 2000',
      'price': 'NRS 1525.00',
      'imageUrl': 'assets/images/chickendrum.jpg',
    },
     {
      'title': 'Jumbo Sour Marinated Chicken Sadeko[3 Person]',
      'oldPrice': null,
      'price': 'NRS 965.00',
      'imageUrl': 'assets/images/sdhekochick.jpg',
    },
    {
      'title': 'Jumbo Savoury Grilled Buff Sekuwa [1 Kg]',
      'oldPrice': 'Rs 895.00',
      'discountedPrice': 'Rs 799.00',
      'imageUrl': 'assets/images/sdhekochick.jpg',
    },
    {
      'title': 'Jumbo Umami Fried and Stirred Chicken Chili [3]',
      'oldPrice': null,
      'discountedPrice': 'Rs 975.00',
      'imageUrl': 'assets/images/sdhekochick.jpg',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.5,
      initialPage: 0,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  void _nextPage() { 
    int nextPage = _pageController.page!.toInt() + 1;
     if (nextPage >= promoItems.length) { 
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
        previousPage = promoItems.length - 1; // Loop back to the last item 
        }
        _pageController.animateToPage( 
          previousPage,
           duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
             );
    }


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      color:Colors.grey[200],
      child: FoodPromoContent(
        pageController: _pageController,
        promoItems: promoItems,
        nextPage:_nextPage,
        previousPage:_previousPage,
    ),
    );
  }
}

class FoodPromoContent extends StatelessWidget {
  final PageController pageController;
  final List<Map<String, dynamic>> promoItems;
  final VoidCallback nextPage;
  final VoidCallback previousPage;

  FoodPromoContent({required this.pageController,
  required this.promoItems,
  required this.nextPage,
  required this.previousPage});

  @override
  Widget build(BuildContext context) {
    return  SingleChildScrollView(
      child: Column(
        mainAxisSize:MainAxisSize.min,
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
            Row( 
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               IconButton( icon: Icon(
              Icons.arrow_back_ios,
               color: Colors.black), 
               onPressed: previousPage,
                    ),
                    Expanded( 
                      child: SizedBox(
                         height: 340, 
                   child: PageView.builder(
                     controller: pageController,
                      itemCount: promoItems.length, 
                      itemBuilder: (context, index)
                       { final item = promoItems[index];
                        return PromoItem(
                           title: item['title'] ?? 'No Title',
                           description: item.containsKey('description')
                      ?item['description'] ??"": 'Cooked Food',
                       price: item['price'] ?? item['discountedPrice'] ?? 'N/A',
                             imageUrl: item['imageUrl'] ?? 'assets/images/default.webp',
                              ); 
                              }, 
                              ),
                               ),
                               ),
          IconButton( icon: Icon(Icons.arrow_forward_ios,
           color: Colors.black ),
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
    return Card(
      margin: EdgeInsets.all(10.0),
      shape:RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 180,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top:Radius.circular(10.0),
                  ),
                  child: Image.asset(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context,error,stackTrace){
                    return const Icon(Icons.image,size: 50);
                  },
                  ),
                ),
              ),
             Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 2, 
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    maxLines: 2, 
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4), 
                  Text(price, style: TextStyle(color: Colors.green)),
                  SizedBox(height: 4), 
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
          ],
                ),
        ),
    );
  }
}