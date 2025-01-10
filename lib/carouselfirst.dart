import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class Carouselfirst extends StatelessWidget {
  const Carouselfirst({super.key});

  @override
  Widget build(BuildContext context) {
    return  CarouselSlider(
              options: CarouselOptions(
                height: 200.0,
                autoPlay: true,
                enlargeCenterPage: true,
              ),
              items: [
                'assets/images/1carousel.jpg',
                'assets/images/2carousel.jpg',
                'assets/images/3carousel.jpg',
                'assets/images/4carousel.jpg',
              ].map((i) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      child: Image.asset(i, fit: BoxFit.cover),
                    );
                  },
                );
              }).toList(),
            );
  }
}