import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:padshala/best_seller.dart';
import 'package:padshala/blocs/foodpromo1/cart_bloc.dart';
import 'package:padshala/blocs/foodpromo1/cart_event.dart';
import 'package:padshala/common/bottom_navbar.dart';
import 'package:padshala/drawer_menu.dart';
import 'package:padshala/footer.dart';
import 'package:padshala/screens/explore_page.dart';
import 'package:padshala/screens/topcircle.dart';
import 'package:padshala/screens/whats_new.dart';
import 'package:padshala/top_deals.dart';
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
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Center(
            child: Image.asset('assets/images/logo.webp'),
          ),
        ),
        drawer: DrawerMenu(),
        body: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
               // Carouselfirst(),
               Topcircle(),
                WhatsNewSection(),
                ExplorePage(),
                BestSellerPage(),
                TopDeals(),
              /*CarouselSecond(),
              FoodPromopage1(onAddToCart: (newItem) { context.read<CartBloc>().add(AddToCartEvent(cartItem: newItem));  }, ),
                _promoBanner(),
                BeveragePromoPage(
                  onAddToCart: (newItem) {
                    context
                        .read<CartBloc>()
                        .add(AddToCartEvent(cartItem: newItem));
                  },
                ),
                FoodPromopage2(
                  onAddToCart: (newItem) {
                    context
                        .read<CartBloc>()
                        .add(AddToCartEvent(cartItem: newItem));
                  },
                ),
                BrandsWeDeal(),
                */
                 Footer(),
             ],
            ),
            const Positioned(
              bottom: 12,
              right: 14,
              child: WhatsappSupportButton(),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavBar(scaffoldKey: _scaffoldKey),
      ),
    );
  }

  Widget _promoBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(10),
      color: Colors.amber,
      child: const Text(
        "Cravings Never Sleep, And Neither Do WE--24/7 Food Delivery At Your Service!",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
