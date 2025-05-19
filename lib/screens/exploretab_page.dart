import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:padshala/blocs/foodpromo1/cart_bloc.dart';
import 'package:padshala/blocs/foodpromo1/cart_event.dart';
import 'package:padshala/blocs/foodpromo1/cart_state.dart';
import 'package:padshala/common/bottom_navbar.dart';
import 'package:padshala/common/favourites/fav_bloc.dart';
import 'package:padshala/common/favourites/fav_event.dart';
import 'package:padshala/model/cart_item.dart';
import 'package:padshala/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExploretabPage extends StatefulWidget {
  final int initialIndex;

  const ExploretabPage({required this.initialIndex, Key? key}) : super(key: key);

  @override
  _ExploretabPageState createState() => _ExploretabPageState();
}

class _ExploretabPageState extends State<ExploretabPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<String> tabs = [
    "Chichii Snacks",
    "Chichii Grilled",
    "Chichii Fried",
    "Biryani/Gravy",
    "Momo/Burger/Noodles",
    "Beverages"
  ];

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: tabs.length, vsync: this, initialIndex: widget.initialIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _loadMenuItems(String category) async {
    String jsonPath;

    switch (category) {
      case "Chichii Snacks":
        jsonPath = 'assets/json/chichiisnacks.json';
        break;
      case "Chichii Grilled":
        jsonPath = 'assets/json/chichiigrilled.json';
        break;
      case "Chichii Fried":
        jsonPath = 'assets/json/chichiifried.json';
        break;
      case "Biryani/Gravy":
        jsonPath = 'assets/json/biryani_gravy.json';
        break;
      case "Momo/Burger/Noodles":
        jsonPath = 'assets/json/momo_burger_noodles.json';
        break;
      case "Beverages":
        jsonPath = 'assets/json/beverages.json';
        break;
      default:
        throw Exception('Category not found');
    }

    String jsonString = await rootBundle.loadString(jsonPath);
    List<dynamic> jsonResponse = json.decode(jsonString);

    if (category == "Beverages") {
      return jsonResponse
          .map((cat) => {"category": cat["category"], "items": cat["items"]})
          .toList();
    }

    return jsonResponse.cast<Map<String, dynamic>>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
            future: _loadMenuItems(category),
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
  const MenuList({required this.menuItems, Key? key}) : super(key: key);
  @override
  _MenuListState createState() => _MenuListState();
}

class _MenuListState extends State<MenuList> {
  List<String> favoriteItems = [];
  String searchQuery = "";
  @override
  void initState() {
    super.initState();
    _loadFavoriteItems(); // load Favorite items 
  }

  Future<void> _loadFavoriteItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      favoriteItems = prefs.getStringList('favoriteItems') ?? [];
    });
  }

  Future<void> _saveFavoriteItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('favoriteItems', favoriteItems);
  }
List<Map<String, dynamic>> _filterMenuItems() {
    if (searchQuery.isEmpty) return widget.menuItems;

    return widget.menuItems.where((item) {
      if (item.containsKey('title')) {
        return item['title'].toString().toLowerCase().contains(searchQuery.toLowerCase());
      } else if (item.containsKey('items')) {
        final filteredSubItems = (item['items'] as List)
            .where((subItem) => subItem['title']
                .toString()
                .toLowerCase()
                .contains(searchQuery.toLowerCase()))
            .toList();
        return filteredSubItems.isNotEmpty;
      }
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _filterMenuItems();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search snacks, drinks, meals...',
              filled: true,
              fillColor: Colors.white,
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (value) {
              setState(() => searchQuery = value);
            },
          ),
        ),
        Expanded(
          child: BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              final List<CartItem> cartItems =
                  state is CartUpdatedState ? state.cartItems : <CartItem>[];
              return ListView.builder(
                padding: EdgeInsets.all(4.0),
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: buildItemList(item, cartItems),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
 List<Widget> buildItemList(Map<String, dynamic> item, List<CartItem> cartItems) {
    if (item.containsKey('category') && item.containsKey('items')) {
      final filteredSubItems = (item['items'] as List) 
          .where((subItem) => subItem['title']
              .toString()
              .toLowerCase()
              .contains(searchQuery.toLowerCase()))
          .toList();

      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8),
          child: Text(
            item['category'],
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ...filteredSubItems.map((subItem) => _buildMenuCard(subItem, cartItems)).toList(),
      ];
    } else {
      return [_buildMenuCard(item, cartItems)];
    }
  }
   Widget _buildMenuCard(Map<String, dynamic> item, List<CartItem> cartItems) {
    final isAdded = cartItems.any((cartItem) => cartItem.id == item["title"]);
    final isFavorite = favoriteItems.contains(item["title"]);
    return GestureDetector(
      onTap: () => _showItemDialog(context, item),
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
                    Text(item["title"], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 4),
                    Text("Rs.${item["price"]}",
                        style: TextStyle(color: Colors.green[700], fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : null,
                ),
                onPressed: () {
                  setState(() {
                    isFavorite ? favoriteItems.remove(item["title"]) : favoriteItems.add(item["title"]);
                  });
                  _saveFavoriteItems();
                  context.read<FavoriteBloc>().add(ToggleFavorite(item));
                },
              ),
              SizedBox(width: 8),
              AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                child: isAdded
                    ? Icon(Icons.check_circle, color: Colors.green, key: ValueKey("added_${item["title"]}"))
                    : ElevatedButton(
                        key: ValueKey("button_${item["title"]}"),
                        onPressed: () {
                          final cartItem = CartItem(
                            id: item["title"],
                            title: item["title"],
                            price: double.tryParse(item["price"].toString()) ?? 0.0,
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
  }
  void _showItemDialog(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) {
        return BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
            final cartItems = state is CartUpdatedState ? state.cartItems : [];
            final isAdded = cartItems.any((cartItem) => cartItem.id == item["title"]);
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(item["image"], height: 200, width: 200, fit: BoxFit.cover),
                  SizedBox(height: 12),
                  Text(item["title"], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  SizedBox(height: 4),
                  Text("Rs.${item["price"]}",
                      style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold, fontSize: 14)),
                  SizedBox(height: 12),
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    child: isAdded
                        ? Icon(Icons.check_circle, color: Colors.green, size: 40, key: ValueKey("added_${item["title"]}"))
                        : ElevatedButton(
                            onPressed: () {
                              final cartItem = CartItem(
                                id: item["title"],
                                title: item["title"],
                                price: double.tryParse(item["price"].toString()) ?? 0.0,
                                imageUrl: item["image"],
                              );
                              context.read<CartBloc>().add(AddToCartEvent(cartItem: cartItem));
                              Future.delayed(Duration(milliseconds: 200), () {
                                if (Navigator.canPop(context)) Navigator.pop(context);
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
