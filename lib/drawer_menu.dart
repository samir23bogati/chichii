import 'package:flutter/material.dart';
import 'package:padshala/expandable_category.dart';

class DrawerMenu extends StatefulWidget {
  @override
  _DrawerMenuState createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  bool showMenu = true; 

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Column(
          children: <Widget>[
            //SearchBar(),
            SizedBox(height:10),
            SizedBox(
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        showMenu = true;
                      });
                    },
                    child: Text(
                      'Menu',
                      style: TextStyle(
                        fontSize: 18,
                        color: showMenu ? Colors.amber : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        showMenu = false;
                      });
                    },
                    child: Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: 18,
                        color: !showMenu ? Colors.amber : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: showMenu ? _buildMenuSection() : _buildCategoriesSection(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection() {
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        ListTile(
          leading: Icon(Icons.home),
          title: Text('Home'),
          onTap: () {
            // Handle Home tap
          },
        ),
        ListTile(
          leading: Icon(Icons.shop),
          title: Text('Shop'),
        ),
        ListTile(
          leading: Icon(Icons.food_bank),
          title: Text('Recipes'),
        ),
        ListTile(
          leading: Icon(Icons.book_rounded),
          title: Text('About Us'),
        ),
        ListTile(
          leading: Icon(Icons.computer),
          title: Text('Blog'),
        ),
        ListTile(
          leading: Icon(Icons.phone),
          title: Text('Contacts'),
        ),
        ListTile(
          leading: Icon(Icons.shopping_cart),
          title: Text('Cart'),
        ),
        ListTile(
          leading: Icon(Icons.favorite),
          title: Text('Wishlist'),
        ),
      ],
    );
  }

  Widget _buildCategoriesSection() {
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        ExpandableCategory(
          title: 'Tobacco Products',
          items: ['Cigarette'],
        ),
        ExpandableCategory(
          title: 'Cooked Food',
          items: ['Nuggets','Curry','Chilli','Rice',
          'Lollipop','Roti','Choila','Sadeko','Dal',
          'Fish Finger','Sekuwa','Chicken Drums','Ribs'],
        ),
        ExpandableCategory(
          title: 'Drinks',
          items: ['Rum','Wine','Whisky','Liqueur',
          'Tequilla','Cold Drinks','Sake and Soju',
          'Beer','Gin','Vodka',],
        ),
        ExpandableCategory(
          title: 'Fast Food',
          items: ['MOMO', 'Fries','Grilled'],
        ),
        ExpandableCategory(
          title: 'Ice Cream',
          items: ['Item 1', 'Item 2'],
        ),
        ExpandableCategory(
          title: 'Packed Food',
          items: ['Item 1', 'Item 2'],
        ),
        ExpandableCategory(
          title: 'ChiChii Offer',
          items: ['Christmas & New Year Offer',],
        ),
        
      ],
    );
  }
}
