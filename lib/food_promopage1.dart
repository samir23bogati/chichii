import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:padshala/blocs/foodpromo1/cart_bloc.dart';
import 'package:padshala/blocs/foodpromo1/cart_event.dart';
import 'package:padshala/model/cart_item.dart';



class FoodPromopage1 extends StatefulWidget {
  final Function(CartItem) onAddToCart;
  const FoodPromopage1({super.key,
  required this.onAddToCart});

  @override
  State<FoodPromopage1> createState() => _FoodPromopage1State();
}

class _FoodPromopage1State extends State<FoodPromopage1> {
  late PageController _pageController;
  List<Map<String, dynamic>> promoItems = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.5,
      initialPage: 0,
    );
    _loadFoodPromoItems();
  }

 Future<void> _loadFoodPromoItems() async {
  try{

    String jsonString = await rootBundle.loadString('assets/json/foodpromo_items.json');
    List<dynamic> jsonData = json.decode(jsonString);
    setState(() {
      promoItems = jsonData.map<Map<String, dynamic>>((item) {
        return {
          'title': item['title'] ?? 'No Title',
          'description': item['description'] ?? 'Cooked Food',
          'price': item['price'] ?? item['discountedPrice'] ?? 'N/A',
          'imageUrl': item['imageUrl'] ?? 'assets/images/default.webp',
        };
      }).toList();
    });
  }catch (e) {
      // Handle JSON load error
      print("Error loading promo items: $e");
    }
  }
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  void _nextPage() { 
    int nextPage = (_pageController.page?.toInt()?? 0) + 1;
    if (promoItems.isNotEmpty && nextPage >= promoItems.length) {
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
        onAddToCart: (CartItem item) {
          // Dispatch the event to CartBloc to add item to the cart
          context.read<CartBloc>().add(AddToCartEvent(cartItem: item)); // Add to cart event
      
        
        },
      ),
    );
  }
}

class FoodPromoContent extends StatelessWidget {
  final PageController pageController;
  final List<Map<String, dynamic>> promoItems;
  final VoidCallback nextPage;
  final VoidCallback previousPage;
  final Function(CartItem) onAddToCart;

  const FoodPromoContent({
  required this.pageController,
  required this.promoItems,
  required this.nextPage,
  required this.previousPage,
  required this.onAddToCart,
  });

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
                         width: double.infinity,
                   child: PageView.builder(
                     controller: pageController,
                      itemCount: promoItems.length, 
                      itemBuilder: (context, index)
                       { final item = promoItems[index];
                        return PromoItem(
                           title: item['title'] ?? 'No Title',
                           description: 'Cooked Food',
                       price: item['price'] ?? item['discountedPrice'] ?? 'N/A',
                        imageUrl: item['imageUrl'] ?? 'assets/images/default.webp',
                        onAddToCart: onAddToCart, // Pass onAddToCart to PromoItem 
                              ); 
                              }, 
                              ),
                               ),
                               ),
          IconButton(
             icon: Icon(Icons.arrow_forward_ios,
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
  final Function(CartItem) onAddToCart; //accept the callback

  PromoItem({
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox( 
      height: 350,
      child: Card(
        margin: EdgeInsets.all(10.0),
        shape:RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 150,
                width: MediaQuery.of(context).size.width * 0.8,
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
                      fontWeight:FontWeight.bold,
                      color: Colors.grey[700]),
                      maxLines: 2, 
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4), 
                    Text('Rs $price',
                    style: TextStyle(
                      color: Colors.green,fontSize: 16,
                      fontWeight: FontWeight.bold),
                    ),
                      Spacer(),
                    
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: Icon(Icons.add_shopping_cart),
                        onPressed: () {
                           final cartItem = CartItem(
                            id: title, 
                            title: title,
                            price: double.tryParse(price) ?? 0.0, 
                            imageUrl: imageUrl,
                          );
                       
                          onAddToCart(cartItem); 
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
