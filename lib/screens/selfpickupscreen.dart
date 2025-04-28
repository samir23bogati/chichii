import 'package:flutter/material.dart';
import 'package:padshala/common/embedmap.dart';
import 'package:padshala/screens/exploretab_page.dart'; 

class SelfPickupScreen extends StatefulWidget {
  @override
  _SelfPickupScreenState createState() => _SelfPickupScreenState();
}

class _SelfPickupScreenState extends State<SelfPickupScreen> {
   String? selectedCity = "Kathmandu"; // Default city
  String? selectedStore;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Self Pickup")),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Display Image
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 8),
              child: Image.asset(
                'assets/images/selfpick.jpg', 
                height: 150, 
                width: double.infinity,
                fit: BoxFit.fill,
              ),
            ),
           Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("WHICH OUTLET YOU WOULD LIKE TO PICKUP FROM:", 
                      style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold)),

                  SizedBox(height: 10),

                  // City Dropdown
                  Container(
                    padding: EdgeInsets.only(bottom: 5),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Kathmandu",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Row(
                          children: [
                            Text(" 🇳🇵", style: TextStyle(fontSize: 22)), // Nepali flag
                            SizedBox(width: 8),
                            Icon(Icons.arrow_drop_down, color: Colors.black),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // Store Dropdown
                  Container(
                    padding: EdgeInsets.only(bottom: 5),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        hint: Text("Store", style: TextStyle(color: Colors.grey)),
                        value: selectedStore,
                        icon: Icon(Icons.arrow_drop_down, color: Colors.black),
                        isExpanded: true,
                        items: [
                          "ChiChii Online - 24/7 Night Food & Drinks Delivery"
                        ].map((store) {
                          return DropdownMenuItem(
                            value: store,
                            child: Text(store),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedStore = value;
                          });
                        },
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // SELF PICKUP Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ExploretabPage(initialIndex: 0,)),
    );
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.amber,
    padding: EdgeInsets.symmetric(vertical: 12),
  ),
  child: Text(
    "SELF PICKUP",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 4),

            Container(
              height: 265, // Adjust height as needed
              width: double.infinity,
              child: Embedmap(),  
            ),
          ],
        ),
      ),
    );
  }
}
