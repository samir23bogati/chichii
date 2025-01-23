import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:padshala/beverage_promopage.dart';
import 'package:padshala/brands.dart';
import 'package:padshala/carousel_second.dart';
import 'package:padshala/carouselfirst.dart';
import 'package:padshala/drawer_menu.dart';
import 'package:padshala/food_promopage1.dart';
import 'package:padshala/food_promopage2.dart';
import 'package:padshala/footer.dart';
import 'package:padshala/model/cart_item.dart';
import 'package:padshala/model/cartpage_track.dart';
import 'package:padshala/whatsapp_support.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<CartItem> cartItems = [];

    void _addToCart(CartItem newItem) {
  setState(() {
    // Check if the item already exists in the cart
    final existingItemIndex =
        cartItems.indexWhere((item) => item.title == newItem.title);

    if (existingItemIndex != -1) {
      // If item exists, increase its quantity
      cartItems[existingItemIndex].quantity++;
    } else {
      // Otherwise, add a new item
      cartItems.add(newItem);
    }
  });
}
void _updateQuantity(CartItem item, int change) {
  setState(() {
    final index = cartItems.indexWhere((cartItem) => cartItem.title == item.title);
    if (index != -1) {
      cartItems[index].quantity += change;
      if (cartItems[index].quantity <= 0) {
        cartItems.removeAt(index); // Remove item if quantity is 0 or less
      }
    }
  });
}

 void _removeFromCart(CartItem item) {
    setState(() {
      cartItems.remove(item);
    });
  }
  int get cartItemCount => cartItems.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
          automaticallyImplyLeading:false,
        title: Center(
          child: Image.asset(
            'assets/images/logo.webp',
          ),
        ),
      ),
      drawer: DrawerMenu(),
      body: Stack(
        children: <Widget>[
          ListView(
            children: <Widget>[
              Carouselfirst(),
              Gap(20),
              CarouselSecond(),
              Gap(20),
              FoodPromopage1(
                onAddToCart: _addToCart,
              ),
              Gap(20),
              Container(
                color: Colors.amber,
                child: Text(
                  "Cravings Never Sleep, And Neither Do WE--24/7 Food Delivery At Your Service!",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Gap(20),
              BeveragePromoPage(),
              Gap(20),
              FoodPromopage2(),
              Gap(20),
              BrandsWeDeal(),
              Gap(20),
              Footer(),
            ],
          ),
          Positioned(
            bottom: 12,
            right: 14,
            child: WhatsappSupportButton(),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.amber,
       
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Builder( builder: (context) {
                return IconButton(
                  icon: Icon(Icons.menu),
                  color: Colors.black,
                  onPressed: () {
                    _scaffoldKey.currentState!.openDrawer();
                  },
                );
              }
            ),
            IconButton(
              icon: Icon(Icons.home),
              color: Colors.black,
              onPressed: () {
                // Handle Home button tap
              },
            ),
            IconButton(
              icon: Icon(Icons.search),
              color: Colors.black,
              onPressed: () {
                // Handle Search button tap
              },
            ),
            IconButton(
              icon: Stack(
                children: [
                  Icon(Icons.shopping_cart),
                  if (cartItemCount > 0)
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                       cartItemCount.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
              onPressed: () {
                // Handle shopping cart action
                 Navigator.push(context,
      MaterialPageRoute(
        builder: (context) => CartPage(
          cartItems: cartItems,
          onRemoveItem: _removeFromCart,
          onUpdateQuantity: _updateQuantity,
          ), 
      ),
                 );
              },
            ),
          ],
        ),
      ),
    );
  }
}
