import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:padshala/Admin/admin_dashboardpage.dart';
import 'package:padshala/best_seller.dart';
import 'package:padshala/blocs/foodpromo1/cart_bloc.dart';
import 'package:padshala/blocs/foodpromo1/cart_event.dart';
import 'package:padshala/common/bottom_navbar.dart';
import 'package:padshala/common/favourites/favoutireslayout.dart';
import 'package:padshala/drawer_menu.dart';
import 'package:padshala/footer.dart';
import 'package:padshala/screens/explore_page.dart';
import 'package:padshala/screens/topcircle.dart';
import 'package:padshala/screens/whats_new.dart';
import 'package:padshala/top_deals.dart';
import 'package:padshala/whatsapp_support.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _tapCount = 0;
  int unreadNotifications = 0;
  int _previousOrderCount = 0;
  AudioPlayer audioPlayer = AudioPlayer();
  StreamSubscription? _orderSubscription;

  @override
  void initState() {
    super.initState();
  

     context.read<CartBloc>().add(LoadCartEvent());
  _orderSubscription = FirebaseFirestore.instance.collection('orders').snapshots().listen((snapshot) {
      final currentOrderCount = snapshot.docs.length;

   if (_previousOrderCount == 0) {
    _previousOrderCount = currentOrderCount;
    return; // Do not play sound
  }

  if (currentOrderCount > _previousOrderCount) {
    setState(() {
      unreadNotifications++;
    });
    _playNotificationSound();
  }

  _previousOrderCount = currentOrderCount;
});
  }
  @override
void dispose() {
  _orderSubscription?.cancel();
  audioPlayer.dispose(); 
  super.dispose();
}

  // Function to play notification sound
  void _playNotificationSound() async {
    await audioPlayer.play(AssetSource('sounds/order_alert.mp3'));
  }


  // Function to check if the current user is an admin
  Future<bool> _isAdmin() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      print('Current User phoneNumber ${user.phoneNumber}');
      // Check the Firestore document for this user
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('admins')
          .doc(user.phoneNumber)
          .get();
          

      if (userDoc.exists && userDoc.data() != null) {
        var userData = userDoc.data() as Map<String, dynamic>;
        print("User Data: $userData");
        bool isAdmin = userData['isAdmin'] ?? false; // Return whether the user is an admin
        print('User isAdmin: $isAdmin');
        return isAdmin;
     } else {
      print('No admin record found in Firestore.');
    }
  } else {
    print('User not authenticated.');
  }

  return false;
}

  void _onLogoTap() async {
    _tapCount++;

    if (_tapCount == 3) {
      _tapCount = 0;

      bool isAdmin = await _isAdmin();
      print('Is current user admin?  $isAdmin');
      if (isAdmin) {
        print('Navigating to AdminDashboardScreen...');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AdminDashboardScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Access Denied. Admins Only!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          automaticallyImplyLeading: false,
           leading: const SizedBox(),
          title: GestureDetector(
                onTap: _onLogoTap,
                  child: Image.asset('assets/images/logo.webp'),
                ),
              
              centerTitle: true,
         actions: [
  Stack(
    children: [
      IconButton(
        icon: const Icon(Icons.notifications),
        onPressed: () async {
          bool isAdmin = await _isAdmin();
          if (isAdmin) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AdminDashboardScreen()),
            );
            setState(() {
              unreadNotifications = 0; // Reset badge on open
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Access Denied. Admins Only!')),
            );
          }
        },
      ),
      if (unreadNotifications > 0)
        Positioned(
          right: 11,
          top: 11,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
            constraints: const BoxConstraints(
              minWidth: 16,
              minHeight: 16,
            ),
            child: Text(
              '$unreadNotifications',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
    ],
  ),
  const SizedBox(width: 8),
],

        ),
        drawer: DrawerMenu(),
        body: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                // Carouselfirst(),
                Topcircle(),
                WhatsNewSection(),
                ExplorePage(),
                BestSellerPage(),
                TopDeals(),
                Favoutireslayout(),
                /*CarouselSecond(),
              FoodPromopage1(onAddToCart: (newItem) { context.read<CartBloc>().add(AddToCartEvent(cartItem: newItem));  }, ),
                _promoBanner(),
                BeveragePromoPage(
                  onAddToCart: (newItem) {
                    context
                        .read<CartBloc>()
                        .add(AddToCartEvent(cartItem: newItem));
                  },
                ),
                FoodPromopage2(
                  onAddToCart: (newItem) {
                    context
                        .read<CartBloc>()
                        .add(AddToCartEvent(cartItem: newItem));
                  },
                ),
                BrandsWeDeal(),
                */
                Footer(),
              ],
            ),
            const Positioned(
              bottom: 12,
              right: 14,
              child: WhatsappSupportButton(),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavBar(scaffoldKey: _scaffoldKey),
      ),
    );
  }


  /*Widget _promoBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(10),
      color: Colors.amber,
      child: const Text(
        "Cravings Never Sleep, And Neither Do WE--24/7 Food Delivery At Your Service!",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
*/

}