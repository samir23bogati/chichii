import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart';
import 'package:padshala/screens/whatsnew_foodlist.dart';

class WhatsNewSection extends StatelessWidget {
 Future<List<Map<String, dynamic>>> loadNewItems() async {
    try {
      String data = await rootBundle.loadString('assets/json/whatsnew.json');
      List<dynamic> jsonResult = json.decode(data);
      return jsonResult.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (error) {
      print('Error loading or parsing JSON: $error');
      return []; 
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: loadNewItems(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading data: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No new items available'));
        } else {
          List<Map<String, dynamic>> newItems = snapshot.data!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  "WHAT'S NEW 🍟",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  
                ),
              ),
              CarouselSlider(
                options: CarouselOptions(
                  height: 157,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  enableInfiniteScroll: true,
                ),
                items: newItems.map((item) {
                  String imageUrl = item["image"] ?? 'assets/images/default.jpg';
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WhatsnewFoodlist(
                            comboName: item["title"] as String? ?? "Unknown",
                            price: (item["price"] as num?)?.toDouble() ?? 0.0,
                            foodItems: (item["foodItems"] is List)
                                ? List<Map<String, dynamic>>.from(
                                    item["foodItems"])
                                : [],
                            imageUrl: [imageUrl],
                          ),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        }
      },
    );
  }
}
