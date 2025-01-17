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

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              "Dish Discoveries",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.3,
            child: Stack(
              children: [
                CarouselSlider(
                  carouselController: _controller,
                  options: CarouselOptions(
                    height: MediaQuery.of(context).size.height * 0.35,
                    enlargeCenterPage: true,
                    enableInfiniteScroll: false,
                    viewportFraction: 0.5,
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
                            style:const TextStyle(
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
                  left: 10,//5
                  top: MediaQuery.of(context).size.height * 0.1,
                  child: _buildArrowButton(
                    icon:Icons.keyboard_arrow_left,
                    onTap: (){
                      setState(() {
                        _currentIndex =(_currentIndex > 0)
                        ? _currentIndex - 1
                        :imgList.length - 1;
                      });
                      _controller.jumpToPage(_currentIndex);
                    },
                  ),
                ),
                  

                // Right arrow
                Positioned(
                  right: 10,
                  top: MediaQuery.of(context).size.height * 0.1,
                   child: _buildArrowButton(
                      icon: Icons.keyboard_arrow_right,
                      onTap: () {
                        setState(() {
                          _currentIndex = (_currentIndex < imgList.length - 1)
                              ? _currentIndex + 1
                              : 0;
                        });
                        _controller.jumpToPage(_currentIndex);
                      },
                      ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
Widget _buildArrowButton({required IconData icon, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            spreadRadius: 2,
            blurRadius: 4,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 35, color: Colors.black),
        onPressed: onTap,
      ),
    );
  }
}