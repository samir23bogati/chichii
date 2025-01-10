import 'package:flutter/material.dart';
import 'package:padshala/carousel_slider_widget.dart';
import 'package:padshala/homepage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ChiChii', 
      theme: ThemeData(
        useMaterial3: false, 
        primarySwatch: Colors.amber, 
      ),
      home: HomePage(), 
    );
  }
}

// class HomePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final List<String> imagePaths = [ 
//       "https://chichii.online/wp-content/uploads/2024/08/all-100x100.jpg.webp",
//     ];

//     return Scaffold(
//       appBar: AppBar( 
//         title: Text('Flutter Carousel Demo'),
//       ),
//       body: Column(
//         children: [
//           // Add any additional widgets here if needed
//           Expanded(
//             child: CarouselSliderWidget(imagePaths: imagePaths),
//           ),
//         ],
//       ),
//     );
//   }
// }
