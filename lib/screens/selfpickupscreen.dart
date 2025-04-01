import 'package:flutter/material.dart';
import 'package:padshala/common/embedmap.dart'; 

class SelfPickupScreen extends StatefulWidget {
  @override
  _SelfPickupScreenState createState() => _SelfPickupScreenState();
}

class _SelfPickupScreenState extends State<SelfPickupScreen> {
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
              padding: const EdgeInsets.all(20.0),
              child: Image.asset(
                'assets/images/selfpick.jpg', 
                height: 200, 
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            
            Container(
              height: 300, // Adjust height as needed
              width: double.infinity,
              child: Embedmap(),  
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
