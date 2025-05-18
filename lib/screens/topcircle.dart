import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:padshala/screens/mapselectionscreen.dart';
import 'package:padshala/screens/selfpickupscreen.dart';

class Topcircle extends StatefulWidget {
  @override
  _TopcircleState createState() => _TopcircleState();
}

class _TopcircleState extends State<Topcircle> {
  int selectedIndex = 1; 
  LatLng? selectedAddress;

  final List<Map<String, dynamic>> orderTypes = [
    {"label": "DELIVERY", "icon": Icons.delivery_dining},
    {"label": "SELF-PICKUP", "icon": Icons.shopping_bag},
  ];

   void _onLocationSelected(LatLng location) {
    setState(() {
      selectedAddress = location;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
          height: 75,
          child:Scaffold(
            body: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal, 
            child: Row(
              mainAxisSize: MainAxisSize.min, 
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(orderTypes.length, (index) {
                bool isSelected = selectedIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                   if (index == 0) {
                       
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MapSelectionScreen(
                              onLocationSelected: _onLocationSelected,
                            ),
                          ),
                        );
                      } else if (index == 1) {
                       
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SelfPickupScreen(), 
                          ),
                        );
                      }
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.red : Colors.grey,
                              width: isSelected ? 3 : 1,
                            ),
                            boxShadow: isSelected
                                ? [BoxShadow(color: Colors.red.withOpacity(0.2), blurRadius: 5)]
                                : [],
                          ),
                          child: Icon(
                            orderTypes[index]["icon"],
                            size: 23,
                            color: isSelected ? Colors.red : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          orderTypes[index]["label"],
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? Colors.red : Colors.black,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
