import 'package:flutter/material.dart';

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading:IconButton(
          icon:Icon(Icons.menu),
          onPressed: (){},
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
         children: [
           Image.network(
          'https://commons.wikimedia.org/wiki/File:Facebook_Logo_2023.png', // Replace with your image URL
          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
            if (loadingProgress == null) {
              return child;
            } else {
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                      : null,
                ),
              );
            }
          },
          errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
            return Text('Failed to load image');
          },
        ),
            ],
        ),
      ),
    );
  }
}





