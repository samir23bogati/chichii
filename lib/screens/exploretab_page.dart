import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:padshala/blocs/foodpromo1/cart_bloc.dart';
import 'package:padshala/blocs/foodpromo1/cart_event.dart';
import 'package:padshala/blocs/foodpromo1/cart_state.dart';
import 'package:padshala/model/cart_item.dart';
import 'package:provider/provider.dart';

class ExploretabPage extends StatefulWidget {
  final int initialIndex;

  const ExploretabPage({required this.initialIndex, Key? key})
      : super(key: key);

  @override
  _ExploretabPageState createState() => _ExploretabPageState();
}

class _ExploretabPageState extends State<ExploretabPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> tabs = [
    "Exclusive Deals",
    "Chicken Buckets",
    "Sides",
    "Chicken Meals",
    "Burgers & Twisters",
    "Beverages"
  ];
  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: tabs.length, vsync: this, initialIndex: widget.initialIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Helper function to load menu items from JSON file based on category
  Future<List<Map<String, dynamic>>> _loadMenuItems(String category) async {
    String jsonPath = '';

    switch (category) {
      case "Exclusive Deals":
        jsonPath = 'assets/json/exclusive_deals.json';
        break;
      case "Chicken Buckets":
        jsonPath = 'assets/json/chicken_buckets.json';
        break;
      case "Sides":
        jsonPath = 'assets/json/sides.json';
        break;
      case "Chicken Meals":
        jsonPath = 'assets/json/chicken_meals.json';
        break;
      case "Burgers & Twisters":
        jsonPath = 'assets/json/burgers_twisters.json';
        break;
      case "Beverages":
        jsonPath = 'assets/json/beverages.json';
        break;
      default:
        throw Exception('Category not found');
    }

    String jsonString = await rootBundle.loadString(jsonPath);
    List<dynamic> jsonResponse = json.decode(jsonString);
    return jsonResponse.map((item) => item as Map<String, dynamic>).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Explore Menu"),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: tabs.map((title) => Tab(text: title)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: tabs.map((category) {
          return FutureBuilder<List<Map<String, dynamic>>>(
            future: _loadMenuItems(
                category), // Load items dynamically based on category
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error loading menu.'));
              }

              final items = snapshot.data ?? [];
              return MenuList(menuItems: items);
            },
          );
        }).toList(),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Consumer<CartBloc>(
          builder: (context, cartBloc, child) {
            return Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.shopping_cart),
                    onPressed: () {
                      // Navigate to the cart page or show cart summary
                    },
                  ),
                  Text(
                    'Items in Cart: ${(cartBloc.state is CartUpdatedState) ? (cartBloc.state as CartUpdatedState).cartItems.length : 0}',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class MenuList extends StatelessWidget {
  final List<Map<String, dynamic>> menuItems;

  const MenuList({required this.menuItems});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(16.0),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return Card(
          margin: EdgeInsets.only(bottom: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Image.asset(item["image"],
                    height: 80, width: 80, fit: BoxFit.cover),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item["title"],
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(height: 4),
                      Text(item["price"],
                          style: TextStyle(color: Colors.red, fontSize: 14)),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final cartItem = CartItem(
                      id: item["title"],
                      title: item["title"],
                      price: double.tryParse(item["price"]) ?? 0.0,
                      imageUrl: item["image"],
                    );
                    // Dispatch the event to CartBloc to add item to the cart
                    context
                        .read<CartBloc>()
                        .add(AddToCartEvent(cartItem: cartItem));
                  },
                  child: Text("Add to Cart"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
