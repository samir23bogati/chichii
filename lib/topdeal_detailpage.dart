import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:padshala/blocs/foodpromo1/cart_bloc.dart';
import 'package:padshala/blocs/foodpromo1/cart_event.dart';
import 'package:padshala/blocs/foodpromo1/cart_state.dart';
import 'package:padshala/model/cart_item.dart';
import 'package:padshala/common/bottom_navbar.dart';

class TopDealDetailPage extends StatefulWidget {
  final String title;
  final String image;
  final String price;
  final List<Map<String, String>> topDeals;

  const TopDealDetailPage({
    Key? key,
    required this.title,
    required this.image,
    required this.price,
    required this.topDeals,
  }) : super(key: key);

  @override
  State<TopDealDetailPage> createState() => _TopDealDetailPageState();
}

class _TopDealDetailPageState extends State<TopDealDetailPage> {
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
            tabs: [
              Tab(text: "Details"),
              Tab(text: "Other Top Deals"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Item Details with Add to Cart
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(widget.image, height: 250, fit: BoxFit.cover),
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(widget.title,
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "Price: NRS ${double.tryParse(widget.price)?.toStringAsFixed(2) ?? '0.00'}",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),

                  // Bloc for Add to Cart
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: BlocBuilder<CartBloc, CartState>(
                      builder: (context, state) {
                        bool isAddedToCart = false;

                        if (state is CartUpdatedState) {
                          isAddedToCart = state.cartItems
                              .any((item) => item.id == widget.title);
                        }

                        return isAddedToCart
                            ? Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.green),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle, color: Colors.green),
                                    SizedBox(width: 8),
                                    Text("Added to Cart",
                                        style: TextStyle(color: Colors.green)),
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

                                  context
                                      .read<CartBloc>()
                                      .add(AddToCartEvent(cartItem: cartItem));
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.shopping_cart, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text("Add to Cart"),
                                  ],
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.amber,
                                ),
                              );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Other Top Deals List
            ListView.builder(
              itemCount: widget.topDeals.length,
              itemBuilder: (context, index) {
                final deal = widget.topDeals[index];
                return ListTile(
                  leading:
                      Image.asset(deal['image']!, width: 50, fit: BoxFit.cover),
                  title: Text(deal['title']!),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TopDealDetailPage(
                          title: deal['title']!,
                          image: deal['image']!,
                          price: deal['price']!,
                         topDeals: widget.topDeals,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
        bottomNavigationBar: BottomNavBar(scaffoldKey: _scaffoldKey),
      ),
    );
  }
}