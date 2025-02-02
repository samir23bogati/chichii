import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class Carouselfirst extends StatefulWidget {
  const Carouselfirst({super.key});

  @override
  State<Carouselfirst> createState() => _CarouselfirstState();
}

class _CarouselfirstState extends State<Carouselfirst> {
 final CarouselSliderController _controller = CarouselSliderController();
  int _currentIndex = 0; // Track the current index

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 235, 232, 232),
      child: Column(
        children: [
          // Title Section
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Today's Special",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          
          // Carousel Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Card(
              color: Colors.amber,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 5,
              child: Stack(
                children: [
                  CarouselSlider(
                 carouselController: _controller,
                    options: CarouselOptions(
                      height: 250.0,
                      autoPlay: true,
                      enlargeCenterPage: true,
                      viewportFraction: 0.9,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentIndex = index; // Update current index
                        });
                      },
                    ),
                    items: [
                      'assets/images/1carousel.jpg',
                      'assets/images/2carousel.jpg',
                      'assets/images/3carousel.jpg',
                      'assets/images/4carousel.jpg',
                    ].map((imagePath) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.0),
                              color: Colors.amber, 
                            ),
                            margin: const EdgeInsets.all(5.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15.0),
                              child: Image.asset(
                                imagePath,
                                fit: BoxFit.cover,
                                width: MediaQuery.of(context).size.width,
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                  
                  // Arrow Buttons
                  Positioned(
                    left: 10,
                    top: 80,
                    child: IconButton(
                      icon: Icon(Icons.keyboard_arrow_left, size: 35,color: Colors.white),
                      onPressed: () {
                        if (_currentIndex > 0) {
                          _controller.previousPage(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.linear); // Move to the previous page
                        }
                      },
                    ),
                  ),
                  Positioned(
                    right: 10,
                    top: 80,
                    child: IconButton(
                      icon: Icon(Icons.keyboard_arrow_right,size: 35, color: Colors.white),
                      onPressed: () {
                        if (_currentIndex < 3) { // Ensure it's within range
                          _controller.nextPage(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.linear); // Move to the next page
                        }
                      },
                    ),
                  ),

                  // Dot Indicators
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        4, // Number of slides
                        (index) => Container(
                          width: 8.0,
                          height: 8.0,
                          margin: const EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 2.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentIndex == index
                                ? Colors.white
                                : Colors.black, // Active dot
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
