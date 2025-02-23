import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:padshala/beverage_promopage.dart';
import 'package:padshala/blocs/foodpromo1/cart_bloc.dart';
import 'package:padshala/blocs/foodpromo1/cart_event.dart';
import 'package:padshala/brands.dart';
import 'package:padshala/carousel_second.dart';
import 'package:padshala/carouselfirst.dart';
import 'package:padshala/common/bottom_navbar.dart';
import 'package:padshala/drawer_menu.dart';
import 'package:padshala/food_promopage1.dart';
import 'package:padshala/food_promopage2.dart';
import 'package:padshala/footer.dart';
import 'package:padshala/screens/explore_page.dart';
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
                  ExplorePage(),
                  
                  // ExploreItemPage(onAddToCart: (newItem) {
                  //     context.read<CartBloc>().add(AddToCartEvent(cartItem: newItem));
                  //   },),
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
        bottomNavigationBar: BottomNavBar(scaffoldKey: _scaffoldKey),

      );
  }
}
