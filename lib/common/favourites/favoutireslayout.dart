import 'package:flutter/material.dart';
import 'package:padshala/common/favourites/favoutiresdetails.dart';

class Favoutireslayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FavouritesDetails()),
            );
          },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5,vertical: 5),
          child: SizedBox(
            width: double.infinity, 
            height: 200, 
            child: Image.asset(
              'assets/images/favourites.jpeg', 
              fit: BoxFit.cover, 
            ),
          ),
        ),
      ),
    );
  }
}
