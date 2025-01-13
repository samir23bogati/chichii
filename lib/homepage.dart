import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:padshala/carousel_second.dart';
import 'package:padshala/carouselfirst.dart';
import 'package:padshala/drawer_menu.dart';
import 'package:padshala/food_promopage1.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
              Scaffold.of(context).openDrawer();
              },
            );
          }
        ),
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
      body: ListView(
        children: <Widget>[
          // Padding(
          //   padding: const EdgeInsets.all(16.0),
          //   child: GestureDetector(
          //     onTap: () {
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(builder: (context) => TodaySpecialPage()),
          //       );
          //     },
          //   ),
          // ),
          Carouselfirst(),
          Gap(20),
          CarouselSecond(),
          Gap(20),
           FoodPromopage1(),
        ],
        
        ),
      );
    
  }
}
