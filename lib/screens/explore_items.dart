import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:padshala/blocs/foodpromo1/cart_bloc.dart';
import 'package:padshala/blocs/foodpromo1/cart_event.dart';
import 'package:padshala/model/cart_item.dart';
import 'package:provider/provider.dart';

class ExploreItemPage extends StatefulWidget {
  final Function(CartItem) onAddToCart;
  const ExploreItemPage({super.key, required this.onAddToCart});

  @override
  State<ExploreItemPage> createState() => _ExploreItemPageState();
}

class _ExploreItemPageState extends State<ExploreItemPage> {
  late PageController _pageController;
  List<Map<String, dynamic>> exploreItems = [];
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadExploreItems();
  }

  Future<void> _loadExploreItems() async {
    final String response =
        await rootBundle.loadString('assets/json/feastpromo_items.json');
    final List<dynamic> data = json.decode(response);
    setState(() {
      exploreItems =
          data.map((item) => item as Map<String, dynamic>).toList();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _previousPage() {
    setState(() {
      currentIndex = (currentIndex - 6 + exploreItems.length) % exploreItems.length;
    });
  }

  void _nextPage() {
    setState(() {
      currentIndex = (currentIndex + 6) % exploreItems.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView( // Wrap the entire content inside a scrollable view
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Explore Delicious Items',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: _previousPage,
              ),
              // Wrap the GridView with Expanded so that it takes available space
              Expanded(
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(), // Disable its own scrolling
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: (exploreItems.length - currentIndex).clamp(0, 6),
                  itemBuilder: (context, index) {
                    final itemIndex = currentIndex + index;
                    return ExploreItemCard(
                      imagePath: exploreItems[itemIndex]['imageUrl'] ?? 'assets/images/default.webp',
                      title: exploreItems[itemIndex]['title'] ?? 'No Title',
                      price: exploreItems[itemIndex]['price'] ?? 'N/A',
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
        ],
      ),
    );
  }
}

class ExploreItemCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String price;
  final Function(CartItem) onAddToCart;

  const ExploreItemCard({
    required this.imagePath,
    required this.title,
    required this.price,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
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
                  height: 150,
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
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Rs $price',
                      style: TextStyle(
                        fontSize: 14,
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
                  context.read<CartBloc>().add(AddToCartEvent(cartItem: newItem));
                } catch (e) {
                  print("Error adding item to cart: $e");
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
