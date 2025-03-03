import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:padshala/blocs/foodpromo1/cart_bloc.dart';
import 'package:padshala/blocs/foodpromo1/cart_event.dart';
import 'package:padshala/blocs/foodpromo1/cart_state.dart';
import 'package:padshala/common/bottom_navbar.dart';
import 'package:padshala/model/cart_item.dart';

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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<String> tabs = [
    "Exclusive Deals",
    "Chicken Buckets",
    "Sides",
    "Chicken Meals",
    "Veg Items",
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
      case "Veg Items":
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
      bottomNavigationBar: BottomNavBar(scaffoldKey: _scaffoldKey),
    );
  }
}

class MenuList extends StatefulWidget {
  final List<Map<String, dynamic>> menuItems;

  const MenuList({required this.menuItems, Key? key}): super(key: key);

   @override
  _MenuListState createState() => _MenuListState();
}

class _MenuListState extends State<MenuList> {

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        final cartItems = state is CartUpdatedState ? state.cartItems : [];

    return ListView.builder(
      padding: EdgeInsets.all(16.0),
      itemCount: widget.menuItems.length,
      itemBuilder: (context, index) {
        final item = widget.menuItems[index];
        final isAdded = cartItems.any((cartItem) => cartItem.id == item["title"]); 
        return GestureDetector(
          onTap: (){
            _showItemDialog(context,item);
          },
          child: Card(
            margin: EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Image.asset(item["image"], height: 80, width: 80, fit: BoxFit.cover),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item["title"],
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        SizedBox(height: 4),
                        Text("Rs.${item["price"]}",
                            style: TextStyle(color: Colors.red, fontSize: 14)),
                      ],
                    ),
                  ),
                   AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                    child: isAdded
                        ? Icon(Icons.check_circle, color: Colors.green, key: ValueKey("added_${item["title"]}"))
                        :ElevatedButton(
                    onPressed: () {
                      final cartItem = CartItem(
                        id: item["title"],
                        title: item["title"],
                        price: double.tryParse(item["price"]) ?? 0.0,
                        imageUrl: item["image"],
                      );
                      context.read<CartBloc>().add(AddToCartEvent(cartItem: cartItem));
                    },
                    child: Text("Add to Cart"),
                      ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showItemDialog(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) {
        return BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          final cartItems = state is CartUpdatedState ? state.cartItems : [];
          bool isAddedToCart = cartItems.any((cartItem) => cartItem.id == item["title"]);


        return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(item["image"], height: 200, width: 200, fit: BoxFit.cover),
                SizedBox(height: 12),
                Text(item["title"], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                SizedBox(height: 4),
                Text("Rs.${item["price"]}", style: TextStyle(color: Colors.red, fontSize: 16)),
                SizedBox(height: 12),
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
                  child: isAddedToCart
                      ? Icon(Icons.check_circle, color: Colors.green, size: 40, key: ValueKey("added_${item["title"]}"))
                      : ElevatedButton(
                          onPressed: () {
                            final cartItem = CartItem(
                              id: item["title"],
                              title: item["title"],
                              price: double.tryParse(item["price"]) ?? 0.0,
                              imageUrl: item["image"],
                            );
                            context.read<CartBloc>().add(AddToCartEvent(cartItem: cartItem));

                            // Wait for the Bloc state to update, then close the dialog after 2 seconds
                            Future.delayed(Duration(milliseconds: 200), () {
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              }
                            });
                          },
                          child: Text("Add to Cart"),
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}