import 'package:flutter/material.dart';


class BrandsWeDeal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column( 
      mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child:Text(
            'Brands We Deal With',
            style:  TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
         SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                BrandLogo(imagePath: 'assets/images/cocacola.jpg'),
                BrandLogo(imagePath: 'assets/images/lays.jpg'),
                BrandLogo(imagePath: 'assets/images/1carousel.jpg'),
                BrandLogo(imagePath: 'assets/images/fanta1.jpg'),
                BrandLogo(imagePath: 'assets/images/rum.jpg'),
              ],
            ),
          ),
      ],
        );
  }
}

class BrandLogo extends StatelessWidget {
  final String imagePath;

  const BrandLogo({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Image.asset(
        imagePath,
        height: 180,
        width: 100,
      ),
    );
  }
}
