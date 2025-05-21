import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:padshala/blocs/foodpromo1/cart_bloc.dart';
import 'package:padshala/blocs/foodpromo1/cart_event.dart';
import 'package:padshala/blocs/foodpromo1/cart_state.dart';
import 'package:padshala/homepage.dart';
import 'package:padshala/model/cartpage_track.dart';
import 'package:padshala/profile_screen.dart';
import 'package:padshala/screens/exploretab_page.dart';

class BottomNavBar extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  BottomNavBar({required this.scaffoldKey});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;
  void _onItemTapped(int index, VoidCallback navigationCallback) {
    setState(() {
      _selectedIndex = index;
    });
    navigationCallback();
  }
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        IgnorePointer( 
    ignoring: true,
    child: ClipPath(
      clipper: BottomNavBarClipper(),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.brown[900],
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: Offset(0, -3),
            ),
          ],
        ),
      ),
    ),
        ),
    
    // Navigation Items (Placed on Top of Clipped Navbar)
        Positioned(
    bottom: 10,
    left: 0,
    right: 0,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildNavItem(Icons.home, "Home", isActive: _selectedIndex == 0, onTap: () {
                _onItemTapped(0, () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage()));
                });
              }),
              _buildNavItem(Icons.list_alt, "Menu", isActive: _selectedIndex == 1, onTap: () {
                _onItemTapped(1, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ExploretabPage(initialIndex: 0)));
                });
              }),
              SizedBox(width: 60),
              _buildNavItem(Icons.account_circle, "Account", isActive: _selectedIndex == 2, onTap: () {
                _onItemTapped(2, () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ProfileScreen()));
                });
              }),
              _buildNavItem(Icons.grid_view, "More", isActive: _selectedIndex == 3, onTap: () {
                _onItemTapped(3, () {
                  widget.scaffoldKey.currentState!.openDrawer();
                });
              }),
      ],
    ),
        ),
    
       
        Positioned(
    top: -35, 
      child: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
    int cartItemCount = (state is CartUpdatedState) ? state.cartItems.length : 0;
    
    return GestureDetector(
        onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartPage(
          cartItems: (state is CartUpdatedState) ? state.cartItems : [],
          onRemoveItem: (item) {
            context.read<CartBloc>().add(RemoveFromCartEvent(cartItem: item));
          },
          onUpdateQuantity: (item, change) {
            context.read<CartBloc>().add(UpdateQuantityEvent(cartItem: item, quantity: change, isIncrement: change > 0));
          },
        ),
      ),
    );
        },
        behavior: HitTestBehavior.translucent, 
        child: ClipRect(
    child: Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.transparent, blurRadius: 8)],
      ),
      child: FloatingActionButton(
        backgroundColor: Colors.brown[800],
        elevation: 1,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CartPage(
                cartItems: (state is CartUpdatedState) ? state.cartItems : [],
                onRemoveItem: (item) {
                  context.read<CartBloc>().add(RemoveFromCartEvent(cartItem: item));
                },
                onUpdateQuantity: (item, change) {
                  context.read<CartBloc>().add(UpdateQuantityEvent(cartItem: item, quantity: change, isIncrement: change > 0));
                },
              ),
            ),
          );
        },
                  child: Stack(                             
                    clipBehavior: Clip.none,
                    children: [
                      Icon(Icons.shopping_cart, color: Colors.amber, size: 28),
                      if (cartItemCount > 0)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              cartItemCount.toString(),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  ),
                              textAlign: TextAlign.center,
                           ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
        ),
    );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(IconData icon, String label,
      {bool isActive = false, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? Colors.amber : Colors.white),
          Text(label,
              style: TextStyle(
                  color: isActive ? Colors.amber : Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}
class BottomNavBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double width = size.width;
    double height = size.height;
    double centerX = width / 2;
    double curveDepth = 45; // Depth of the dip
    double curveWidth = 102; 

    Path path = Path();
    path.lineTo(centerX - curveWidth / 2, 0); 

    // Create transparent curve
    path.quadraticBezierTo(centerX, curveDepth * 1.8, centerX + curveWidth / 2, 0);

    path.lineTo(width, 0);
    path.lineTo(width, height); 
    path.lineTo(0, height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}