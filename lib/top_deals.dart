import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:padshala/topdeal_detailpage.dart';

class TopDeals extends StatefulWidget {
  const TopDeals({Key? key}) : super(key: key);

  @override
  State<TopDeals> createState() => _TopDealsState();
}

class _TopDealsState extends State<TopDeals> {
   Future<List<Map<String, String>>> loadTopDeals() async {
    final String jsonString = await rootBundle.loadString('assets/json/topdeals.json');
    final List<dynamic> jsonData = json.decode(jsonString);

    return jsonData.map<Map<String, String>>((item) => {
      'title': item['title'],
      'image': item['image'],
      'price': item['price']
    }).toList();
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, String>>>(
      future: loadTopDeals(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error loading deals: ${snapshot.error}'));
        }

        final topDeals = snapshot.data!;

        return Container(
          padding: EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("TOP DEALS 💰",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              SizedBox(
                height: 160,
                child: PageView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: topDeals.length,
                  controller: PageController(viewportFraction: 0.72),
                  padEnds: false,
                  itemBuilder: (context, index) {
                    final deal = topDeals[index];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TopDealDetailPage(
                              title: deal['title']!,
                              image: deal['image']!,
                              price: deal['price']!,
                              topDeals: topDeals,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 8),
                        width: 321,
                        height: 112,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                          color: Color.fromARGB(255, 185, 140, 46),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                deal['image']!,
                                height: 120,
                                width: 75,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    deal['title']!,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    "NRS ${deal['price']}",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Icon(Icons.arrow_forward_ios, size: 20),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
