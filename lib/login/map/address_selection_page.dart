import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:padshala/Billing/BillingConfirmationPage.dart';
import 'package:padshala/model/cart_item.dart';

class AddressSelectionPage extends StatefulWidget {
  final List<CartItem> cartItems;
  final double totalPrice;

  AddressSelectionPage({required this.cartItems, required this.totalPrice, Key? key}) : super(key: key);

  @override
  _AddressSelectionPageState createState() => _AddressSelectionPageState();
}

class _AddressSelectionPageState extends State<AddressSelectionPage> {
  GoogleMapController? mapController;
  LatLng? selectedLocation;
  String address = "Move the marker to select an address";
  TextEditingController searchController = TextEditingController();
  List<dynamic> predictions = [];

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  // Fetch autocomplete predictions from Google Places API
  Future<void> _fetchAutocompleteSuggestions(String query) async {
    final apiKey = 'AIzaSyCvWC56L0KevuHNhmcmMxNBF7U5jaKPZu0'; // Replace with your actual API key
    final url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json'
    '?input=$query'
    '&components=country:np'
    '&location=27.7172,85.3240' // Approx. location of Kathmandu
    '&radius=40000' // 20km to cover nearby districts
    '&key=$apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      setState(() {
        predictions = json.decode(response.body)['predictions'];
      });
    } else {
      throw Exception('Failed to fetch autocomplete predictions');
    }
  }

  // Handle the selection of a place from the suggestions
Future<void> _onPlaceSelected(String placeId) async {
  print("Fetching details for place ID: $placeId");
  final apiKey = 'AIzaSyCvWC56L0KevuHNhmcmMxNBF7U5jaKPZu0'; // Replace with your actual API key
  final url = Uri.https('maps.googleapis.com', '/maps/api/place/details/json', {
    'place_id': placeId,
    'key': apiKey,
  });
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['status'] == 'OK' && data['result'] != null) {
      final location = data['result']['geometry']['location'];
      final formattedAddress = data['result']['formatted_address'] ?? "Selected Location";
      final newLocation = LatLng(location['lat'], location['lng']);

      setState(() {
        selectedLocation = newLocation;
        address = formattedAddress;
        predictions.clear(); // Clear suggestions after selection
        searchController.text = formattedAddress; // Update search bar with selected address
      });
       print("New Location: $selectedLocation, Address: $address");
      FocusScope.of(context).unfocus(); // Close the dropdown menu

      if (mapController != null) {
        mapController!.animateCamera(CameraUpdate.newLatLngZoom(newLocation, 15));
      }
    } else {
     print('Failed to retrieve valid location data: ${data['status']}');
    }
  } else {
     print('Failed to fetch place details: ${response.statusCode}');
  }
}

  Future<void> _determinePosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        selectedLocation = LatLng(position.latitude, position.longitude);
      });
      if (mapController != null) {
        mapController!.animateCamera(CameraUpdate.newLatLngZoom(selectedLocation!, 15));
      }
      _getAddressFromLatLng(selectedLocation!);
    } catch (e) {
      print("Failed to get location: $e");
    }
  }

  Future<void> _getAddressFromLatLng(LatLng location) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(location.latitude, location.longitude);
      if (placemarks.isNotEmpty) {
        setState(() {
          address = "${placemarks[0].name}, ${placemarks[0].locality}, ${placemarks[0].country}";
        });
      }
    } catch (e) {
      print("Error fetching address: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Address")),
      body: GestureDetector(
        onTap: (){
          setState(() {
            predictions.clear();
          });
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            selectedLocation == null
                ? const Center(child: CircularProgressIndicator())
                : GoogleMap(
                    onMapCreated: (controller) {
                      mapController = controller;
                      if (selectedLocation != null) {
                        mapController!.animateCamera(CameraUpdate.newLatLngZoom(selectedLocation!, 15));
                      }
                    },
                    initialCameraPosition: CameraPosition(target: selectedLocation!, zoom: 15),
                    markers: {
                      if (selectedLocation != null)
                      Marker(
                        markerId: const MarkerId("selected"),
                        position: selectedLocation!,
                        draggable: true,
                        onDragEnd: (newPosition) {
                          setState(() {
                            selectedLocation = newPosition;
                          });
                          _getAddressFromLatLng(newPosition);
                        },
                      ),
                    },
                  ),
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: GestureDetector(
                onTap: () {
                  _fetchAutocompleteSuggestions(searchController.text); // Trigger autocomplete fetch on tap
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey[600]),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          decoration: const InputDecoration(
                            hintText: 'Search for a place',
                            border: InputBorder.none,
                          ),
                          onChanged: (query) {
                            _fetchAutocompleteSuggestions(query); // Update suggestions on text change
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (predictions.isNotEmpty)
              Positioned(
                top: 60,
                left: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.white,
                  child: ListView.builder(
                    itemCount: predictions.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(predictions[index]['description']),
                        onTap: () {
                          _onPlaceSelected(predictions[index]['place_id']);
                        },
                      );
                    },
                  ),
                ),
              ),
            Positioned(
              bottom: 98,
              right: 10,
              child: IconButton(
                icon: Icon(Icons.my_location),
                onPressed: _determinePosition,
                iconSize: 50,
                color: Colors.green,
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                    ),
                    child: Text(address, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: selectedLocation != null
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BillingConfirmationPage(
                                  address: address,
                                  cartItems: widget.cartItems,
                                  totalPrice: widget.totalPrice,
                                ),
                              ),
                            );
                          }
                        : null,
                    child: const Text("Confirm Address"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}