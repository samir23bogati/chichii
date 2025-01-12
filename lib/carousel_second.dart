import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class CarouselSecond extends StatefulWidget {
  const CarouselSecond({super.key});

  @override
  State<CarouselSecond> createState() => _CarouselSecondState();
}

class _CarouselSecondState extends State<CarouselSecond> {
  final CarouselSliderController _controller = CarouselSliderController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> imgList = [
      {'image': 'assets/images/1carousel.jpg', 'title': 'Cheese Balls'},
      {'image': 'assets/images/cookfood.jpg', 'title': 'Cooked Food'},
      {'image': 'assets/images/3carousel.jpg', 'title': 'Drinks'},
      {'image': 'assets/images/fastfood.jpg', 'title': 'Fast Food'},
      {'image': 'assets/images/chickendrum.jpg', 'title': 'Chicken Drum'},
    ];

    return Container(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Dish Discoveries",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Stack(
            children: [
              CarouselSlider(
                carouselController: _controller,
                options: CarouselOptions(
                  height: 210,
                  enlargeCenterPage: true,
                  enableInfiniteScroll: true,
                  viewportFraction: 0.4,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
                items: imgList.map((item) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 150.0,
                        height: 150.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey,
                              spreadRadius: 2,
                              blurRadius: 4,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.asset(
                            item['image']!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          item['title']!,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
              
              
              Positioned(
                left: 5,
                top: 80,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white, 
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                child: IconButton(
                  icon: Icon(Icons.keyboard_arrow_left, size: 35,color:Colors.black),
                  onPressed: () {
                    if (_currentIndex > 0) { // Fixed condition to avoid negative index
                      _controller.previousPage(
                        duration: Duration(milliseconds: 250),
                        curve: Curves.linear,
                      );
                    }
                  },
                ),
              ),
              ),
              
              // Right arrow
              Positioned(
                right: 18, 
                top: 82,
                 child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white, 
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                child: IconButton(
                  icon: Icon(Icons.keyboard_arrow_right,size: 35,color: Colors.black),
                  onPressed: () {
                    if (_currentIndex < imgList.length - 1) { // Fixed condition for last index check
                      _controller.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.linear,
                      );
                    }
                  },
                ),
              ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
