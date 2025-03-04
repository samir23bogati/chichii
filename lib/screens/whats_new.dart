import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:padshala/screens/whatsnew_foodlist.dart';

class WhatsNewSection extends StatelessWidget {
  final List<Map<String, dynamic>> newItems = [
    {
      "image": "assets/images/delicious78.jpeg",
      "title": "COMBO ONE",
      "price": 1500.0,
      "foodItems": [
      {"name": "Burger", "image": "assets/images/goldenoak180.jpg"},
      {"name": "Fries", "image": "assets/images/goldenoak180.jpg"},
      {"name": "Coke", "image": "assets/images/goldenoak180.jpg"}
    ]
    },
    {
      "image": "assets/images/delicious55.jpg",
      "title": "COMBO TWO",
      "price": 1800.0,
      "foodItems": [
      {"name": "Burger", "image": "assets/images/goldenoak180.jpg"},
      {"name": "Fries", "image": "assets/images/goldenoak180.jpg"},
      {"name": "Coke", "image": "assets/images/goldenoak180.jpg"}
    ]
    },
    {
      "image": "assets/images/delicious44.jpeg",
      "title": "COMBO THREE",
      "price": 2080.0,
      "foodItems": [
      {"name": "Burger", "image": "assets/images/goldenoak180.jpg"},
      {"name": "Fries", "image": "assets/images/goldenoak180.jpg"},
      {"name": "Coke", "image": "assets/images/goldenoak180.jpg"}
    ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(10),
          child: Text(
            "WHAT'S NEW",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        CarouselSlider(
          options: CarouselOptions(
            height: 200,
            autoPlay: true,
            enlargeCenterPage: true,
            enableInfiniteScroll: true,
          ),
          items: newItems.map((item) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WhatsnewFoodlist(
                      comboName: item["title"] as String? ?? "Unknown",
                      price: (item["price"] as num?)?.toDouble() ?? 0.0,
                      foodItems: (item["foodItems"] is List)
                         ? List<Map<String, String>>.from(item["foodItems"])
                          : [],
                      imageUrl: [item["image"] as String],
                    ),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  item["image"]!,
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
}
