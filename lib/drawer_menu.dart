import 'package:flutter/material.dart';
import 'package:padshala/screens/exploretab_page.dart'; 

class DrawerMenu extends StatelessWidget {
  final List<String> categories = [
    "Chichii Snacks",
    "Chichii Grilled",
    "Chichii Fried",
    "Biryani/Gravy",
    "Momo/Burger/Noodles",
    "Beverages",
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
    
      child: Container(
        child: Padding(
          padding: const EdgeInsets.only(top: 0), 
          child: Column(
            children: <Widget>[
              _buildCategoryTitle(context),
              Expanded(
                child: ListView(
                  children: [
                    _buildCategoryList(context), 
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  
  Widget _buildCategoryTitle(BuildContext context) {
    return Container(
      width: double.infinity, 
      height: 56.0, 
      color: Colors.amber, 
      child: Center(
        child: Text(
          "Categories",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryList(BuildContext context) {
    return Column(
      children: categories
          .asMap()
          .map(
            (index, category) => MapEntry(
              index,
              ListTile(
                title: Text(category), 
                onTap: () {
                 
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ExploretabPage(
                        initialIndex: index, 
                      ),
                    ),
                  );
                },
              ),
            ),
          )
          .values
          .toList(),
    );
  }
}
