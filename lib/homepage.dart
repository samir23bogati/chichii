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
import 'package:padshala/whatsapp_support.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(builder: (context) {
          return IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          );
        }),
        title: Center(
          child: Image.asset(
            'assets/images/logo.webp',
          ),
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.shopping_cart),
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
                      '23',
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
            },
          ),
        ],
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
              FoodPromopage1(),
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
            bottom: 14,
            right: 14,
            child: WhatsappSupportButton(),
          ),
        ],
      ),
    );
  }
}
