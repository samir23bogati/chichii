import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:padshala/blocs/foodpromo1/cart_bloc.dart';
import 'package:padshala/blocs/foodpromo1/cart_event.dart';
import 'package:padshala/model/cart_item.dart';
import 'package:provider/provider.dart';

class FoodPromopage2 extends StatefulWidget {
  final Function(CartItem) onAddToCart;
  const FoodPromopage2({super.key, required this.onAddToCart});

  @override
  State<FoodPromopage2> createState() => _FoodPromopage2State();
}

class _FoodPromopage2State extends State<FoodPromopage2> {
  late PageController _pageController;
  List<Map<String, dynamic>> foodpromoItems = [];

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
    final String response =
        await rootBundle.loadString('assets/json/feastpromo_items.json');
    final List<dynamic> data = json.decode(response);
    setState(() {
      foodpromoItems =
          data.map((item) => item as Map<String, dynamic>).toList();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _previousPage() {
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

  void _nextPage() {
    int nextPage = (_pageController.page?.toInt() ?? 0) + 1;
    if (foodpromoItems.isNotEmpty && nextPage >= foodpromoItems.length) {
      nextPage = 0; // Loop back to the first item
    }
    _pageController.animateToPage(
      nextPage,
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
                        imagePath: foodpromoItems[index]['imageUrl'] ??
                            'assets/images/default.webp',
                        title: foodpromoItems[index]['title'] ?? 'No Title',
                        price: foodpromoItems[index]['price'] ?? 'N/A',
                        onAddToCart: widget.onAddToCart,
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
  final Function(CartItem) onAddToCart;

  const FoodItemCard({
    required this.imagePath,
    required this.title,
    required this.price,
    required this.onAddToCart,
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
        children: [
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
                      'Rs $price',
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
            right: 10,
            child: IconButton(
                icon: Icon(Icons.add_shopping_cart),
                color: Colors.black,
                onPressed: () {
                  try {
                    double itemPrice = double.tryParse(price) ?? 0.0;
                    CartItem newItem = CartItem(
                      id: DateTime.now().toString(),
                      imageUrl: imagePath,
                      title: title,
                      price: itemPrice,
                    );
                    // Dispatch AddToCartEvent
      context.read<CartBloc>().add(AddToCartEvent(newItem));
                  } catch (e) {
                    print("Error adding item to cart: $e");
                  }
                }),
          ),
        ],
      ),
    );
  }
}
