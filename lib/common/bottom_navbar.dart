import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:padshala/blocs/foodpromo1/cart_bloc.dart';
import 'package:padshala/blocs/foodpromo1/cart_event.dart';
import 'package:padshala/blocs/foodpromo1/cart_state.dart';
import 'package:padshala/homepage.dart';
import 'package:padshala/model/cartpage_track.dart';
import 'package:padshala/screens/exploretab_page.dart';

class BottomNavBar extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  BottomNavBar({required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
          ClipPath(
            clipper: BottomNavBarClipper(),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
             color: Colors.brown[900], // Dark brown background
               boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 5,
                  offset: Offset(0, -3),
                )
              ],
            ),
              child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home, "Home", isActive: true, onTap: () {
                 Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
               );
                }),
                _buildNavItem(Icons.list_alt, "Menu", onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ExploretabPage(initialIndex: 0)),
                  );
                }),
          
                SizedBox(width: 60), // Space for floating button
                _buildNavItem(Icons.account_circle, "Account", onTap: () {}),
                _buildNavItem(Icons.grid_view, "More", onTap: () {
                  scaffoldKey.currentState!.openDrawer();
                }),
              ],
            ),
          ),
        ),
        Positioned(
          top: -28, // Lift the cart button
          child: BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              int cartItemCount = (state is CartUpdatedState) ? state.cartItems.length : 0;

             return Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                ),
                child: FloatingActionButton(
                  backgroundColor: Colors.brown[800],
                  elevation: 5,
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
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                         ),
                          ),
                        ),
                    ],
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
    double curveRadius = 75; // Depth of the dip
    double curveWidth = 95; // Width of the curved section
     double fabHeight = 40;

    Path path = Path();
    path.moveTo(0, 0);
    
    // Left straight section
    path.lineTo(centerX - curveWidth / 2, 0);

    // Concave curve for FAB
    path.quadraticBezierTo(centerX, curveRadius, centerX + curveWidth / 2, 0);

    // Right straight section
    path.lineTo(width, 0);
        // Clipping the remaining area except the transparent gap for the FAB
    path.lineTo(width, height );
    path.lineTo(0, height );
    
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}