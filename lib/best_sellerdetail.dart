import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:padshala/blocs/foodpromo1/cart_event.dart';
import 'package:padshala/blocs/foodpromo1/cart_state.dart';
import 'package:padshala/common/bottom_navbar.dart';
import 'package:padshala/model/cart_item.dart';
import 'blocs/foodpromo1/cart_bloc.dart';

class BestSellerDetailPage extends StatefulWidget {
  final String title;
  final String image;
  final String price;
  final List<Map<String, String>> bestSellers;

  const BestSellerDetailPage({
    Key? key,
    required this.title, 
    required this.image, 
    required this.price,
    required this.bestSellers, 
  }) : super(key: key);

  @override
  State<BestSellerDetailPage> createState() => _BestSellerDetailPageState();
}

class _BestSellerDetailPageState extends State<BestSellerDetailPage> {
   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

 @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, 
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: Colors.amber,
          bottom: TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: "Details"),
              Tab(text: "Other Best Sellers"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Display Selected Item Details
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(widget.image, height: 250, width: double.infinity, fit: BoxFit.cover),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      widget.title,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "Delicious and freshly prepared ${widget.title.toLowerCase()} made with premium ingredients.",
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                  ),
                  SizedBox(height: 10), 
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: BlocBuilder<CartBloc, CartState>(
                      builder: (context, state) {
                        bool isAddedToCart = false;
                        CartItem? existingCartItem;

                        if (state is CartUpdatedState) {
                          existingCartItem = state.cartItems.firstWhere(
                            (item) => item.id == widget.title,
                            orElse: () => CartItem(
                              id: widget.title,
                              title: widget.title,
                              price: double.tryParse(widget.price) ?? 0.0,
                              imageUrl: widget.image,
                              quantity: 1,
                            ),
                          );
                          isAddedToCart =
                              state.cartItems.any((item) => item.id == widget.title);
                        }

                        return AnimatedSwitcher(
                          duration: Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) =>
                              FadeTransition(opacity: animation, child: child),
                          child: isAddedToCart
                           ? Container(
                                key: ValueKey("added_${widget.title}"),
                                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.green),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "Added to Cart",
                                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              )
                            : ElevatedButton(
                                onPressed: () {
                                  final cartItem = CartItem(
                                    id: widget.title,
                                    title: widget.title,
                                    price: double.tryParse(widget.price) ?? 0.0,
                                    imageUrl: widget.image,
                                    quantity: 1,
                                  );

                                  // Add to cart
                                  context.read<CartBloc>().add(AddToCartEvent(cartItem: cartItem));
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.shopping_cart,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "Add to Cart",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).primaryColor,
                                ),
                              ),
                        );

                      },
                    ),
                  ),
                ],
              ),
            ),

            // Display Other Best Sellers
            ListView.builder(
              itemCount: widget.bestSellers.length,
              itemBuilder: (context, index) {
                final item = widget.bestSellers[index];
                return ListTile(
                  leading: Image.asset(item['image']!, width: 50, height: 50, fit: BoxFit.cover),
                  title: Text(item['title']!),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BestSellerDetailPage(
                          title: item['title']!,
                          image: item['image']!,
                          price: item['price']!,
                          bestSellers: widget.bestSellers,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
       bottomNavigationBar:BottomNavBar(scaffoldKey: _scaffoldKey),
      ),
    );
  }
}