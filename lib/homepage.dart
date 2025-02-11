import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:padshala/beverage_promopage.dart';
import 'package:padshala/blocs/foodpromo1/cart_bloc.dart';
import 'package:padshala/blocs/foodpromo1/cart_event.dart';
import 'package:padshala/blocs/foodpromo1/cart_state.dart';
import 'package:padshala/brands.dart';
import 'package:padshala/carousel_second.dart';
import 'package:padshala/carouselfirst.dart';
import 'package:padshala/drawer_menu.dart';
import 'package:padshala/food_promopage1.dart';
import 'package:padshala/food_promopage2.dart';
import 'package:padshala/footer.dart';
import 'package:padshala/model/cartpage_track.dart';
import 'package:padshala/whatsapp_support.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    context.read<CartBloc>().add(LoadCartEvent());
  }


  @override
  Widget build(BuildContext context) {
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Center(
            child: Image.asset('assets/images/logo.webp'),
          ),
        ),
        drawer: DrawerMenu(),
        body: Stack(
          children: <Widget>[
            SizedBox.expand(
              child: ListView(
                children: <Widget>[
                  Carouselfirst(),
                  SizedBox(height: 20),
                  CarouselSecond(),
                  SizedBox(height: 20),
                  FoodPromopage1(
                    onAddToCart: (newItem) {
                      context.read<CartBloc>().add(AddToCartEvent(cartItem: newItem));
                    },
                  ),
                  SizedBox(height: 20),
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
                  SizedBox(height: 20),
                  BeveragePromoPage(
                    onAddToCart: (newItem) {
                      context.read<CartBloc>().add(AddToCartEvent(cartItem: newItem));
                    },
                  ),
                  SizedBox(height: 20),
                  FoodPromopage2(
                    onAddToCart: (newItem) {
                      context.read<CartBloc>().add(AddToCartEvent(cartItem: newItem));
                    },
                  ),
                  SizedBox(height: 20),
                  BrandsWeDeal(),
                  SizedBox(height: 20),
                  Footer(),
                ],
              ),
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
              Builder(builder: (context) {
                return IconButton(
                  icon: Icon(Icons.menu),
                  color: Colors.black,
                  onPressed: () {
                    _scaffoldKey.currentState!.openDrawer(); // Open the drawer
                  },
                );
              }),
              IconButton(
                icon: Icon(Icons.home),
                color: Colors.black,
                onPressed: () {
                  // Handle Home button tap (you can navigate if needed)
                },
              ),
              BlocBuilder<CartBloc, CartState>(
                builder: (context, state) {
                  int cartItemCount = 0;
                  if (state is CartUpdatedState) {
                    cartItemCount = state.cartItems.length;
                  }

                  return IconButton(
                    icon: Stack(
                      children: [
                        Icon(Icons.shopping_cart),
                       if (cartItemCount > 0)
                        Positioned(
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8),
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
                      // Navigate to CartPage and pass the updated cart items
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CartPage(
                           cartItems: (state is CartUpdatedState)
                                ? state.cartItems
                                : [], // Pass the updated cart items
                            onRemoveItem: (item) {
                              context.read<CartBloc>().add(RemoveFromCartEvent(cartItem: item));
                            },
                            onUpdateQuantity: (item, change) {
                               context.read<CartBloc>().add(UpdateQuantityEvent(cartItem: item, quantity:change,isIncrement: change > 0,));
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          
        ),
      ),
    );
  }
}
