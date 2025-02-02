import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class CarouselSliderWidget extends StatelessWidget {
  final List<String> imagePaths;
  CarouselSliderWidget({required this.imagePaths});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 400,
        autoPlay: true,
        enlargeCenterPage: true,
        aspectRatio: 16/9,
        autoPlayCurve: Curves.fastEaseInToSlowEaseOut,
        enableInfiniteScroll: true,
        autoPlayAnimationDuration: Duration(microseconds: 500),
        viewportFraction: 0.8,
      ),
      items: imagePaths.map((item) => Container(
        child: Center(
          child: Image.network(item,fit: BoxFit.cover,height: 400),
        ),
      )).toList(),
    );
  }
}


 