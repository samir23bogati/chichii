import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'package:padshala/Billing/BillingConfirmationPage.dart';
import 'package:padshala/model/cart_item.dart';

class AddressSelectionPage extends StatefulWidget {
  final List<CartItem> cartItems;
  final double totalPrice;

  AddressSelectionPage(
      {required this.cartItems, required this.totalPrice, Key? key})
      : super(key: key);

  @override
  _AddressSelectionPageState createState() => _AddressSelectionPageState();
}

class _AddressSelectionPageState extends State<AddressSelectionPage> {
  Timer? _debounce;
  GoogleMapController? mapController;
  LatLng? selectedLocation;
  String address = "Move the marker to select an address";
  TextEditingController searchController = TextEditingController();
  List<dynamic> predictions = [];
  final Logger logger = Logger();

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _updateAddress(LatLng newPosition) async {
    final String? apiKey = dotenv.env['GOOGLE_MAPS_API_KEY']!;
    if (apiKey == null || apiKey.isEmpty) {
      logger.e("Error: Missing Google Maps API Key");
      return;
    }

    final url = 'https://maps.googleapis.com/maps/api/geocode/json'
        '?latlng=${newPosition.latitude},${newPosition.longitude}'
        '&key=$apiKey';
try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK' && result['results'].isNotEmpty) {
        final formattedAddress = result['results'][0]['formatted_address'];

        setState(() {
          searchController.text = formattedAddress; // Update search box
          selectedLocation = newPosition; // Update marker position
        });
      } else {
       logger.w("Geocode API Error: ${result['status']}");
      }
    } else {
      logger.e('Failed to fetch address from lat/lng: ${response.statusCode}');
    }
  } catch (e) {
      logger.e("Error updating address: $e");
    }
  }

  // Fetch autocomplete predictions from Google Places API
  Future<void> _fetchAutocompleteSuggestions(String query) async {
    try {
      final String? apiKey = dotenv.env['GOOGLE_MAPS_API_KEY']!;
      if (apiKey == null || apiKey.isEmpty) {
       logger.e("Error: Missing Google Maps API Key");
        return;
      }
      final url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json'
          '?input=$query'
          '&components=country:np'
          '&location=27.67816,85.27256'
          '&radius=40000' // 20km to cover nearby districts
          '&key=$apiKey';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['status'] == 'OK') {
          setState(() {
            predictions = result['predictions'];
          });
        } else {
          logger.w("Google API Error: ${result['status']}");
        }
      } else {
        logger.e('Failed to fetch autocomplete: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Error fetching autocomplete suggestions: $e');
    }
  }

  // Handle the selection of a place from the suggestions
  Future<void> _onPlaceSelected(String placeId) async {
    final String? apiKey = dotenv.env['GOOGLE_MAPS_API_KEY']!;
    final url =
        Uri.https('maps.googleapis.com', '/maps/api/place/details/json', {
      'place_id': placeId,
      'key': apiKey,
    });
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK' && data['result'] != null) {
        final location = data['result']['geometry']['location'];
        final newLocation = LatLng(location['lat'], location['lng']);
        logger.i('Selected Place LatLng: ${newLocation.latitude}, ${newLocation.longitude}');
      logger.i('Selected Address: ${data['result']['formatted_address']}');

      _getAddressFromLatLng(newLocation);
         setState(() {
        selectedLocation = newLocation;
        predictions.clear();
        searchController.text = data['result']['formatted_address']; // Update search bar with selected address
      });
       mapController
          ?.animateCamera(CameraUpdate.newLatLngZoom(selectedLocation!, 15));
    } else {
     logger.e('Failed to retrieve valid location data: ${data['status']}');
    }
  } else {
    logger.e('Failed to fetch place details: ${response.statusCode}');
  }
}

  Future<void> _getAddressFromLatLng(LatLng location) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(location.latitude, location.longitude);
      if (placemarks.isNotEmpty) {
        setState(() {
          address =
              "${placemarks[0].name}, ${placemarks[0].locality}, ${placemarks[0].country}";
        });
      } else {
        setState(() {
          address = "No address found";
        });
      }
    } catch (e) {
      logger.e("Error fetching address: $e");
      setState(() {
        address = "Internet Error: Error Retrieving Address ";
      });
    }
  }

  Future<void> _determinePosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        selectedLocation = LatLng(position.latitude, position.longitude);
      });
      if (mapController != null) {
        mapController!
            .animateCamera(CameraUpdate.newLatLngZoom(selectedLocation!, 15));
      }
      _getAddressFromLatLng(selectedLocation!);
    } catch (e) {
      logger.e("Failed to get location: $e");
    }
  }

  Future<void> _fetchLatLngFromPlaceId(String placeId) async {
    final String? apiKey = dotenv.env['GOOGLE_MAPS_API_KEY']!;
    if (apiKey == null || apiKey.isEmpty) {
      print("Error: Missing Google Maps API Key");
      return;
    }

    final url = 'https://maps.googleapis.com/maps/api/place/details/json'
        '?place_id=$placeId'
        '&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        final location = result['result']['geometry']['location'];
        final LatLng newLatLng = LatLng(location['lat'], location['lng']);

        setState(() {
          selectedLocation = newLatLng;
          searchController.text = result['result']['formatted_address'];
        });

        mapController?.animateCamera(CameraUpdate.newLatLng(newLatLng));
      } else {
        logger.w("Place Details API Error: ${result['status']}");
      }
    } else {
      logger.w('Failed to fetch lat/lng from place ID: ${response.statusCode}');
    }
  }

  onChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchAutocompleteSuggestions(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Address")),
      body: GestureDetector(
        onTap: () {
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
                        mapController!.animateCamera(
                            CameraUpdate.newLatLngZoom(selectedLocation!, 15));
                      }
                    },
                    initialCameraPosition:
                        CameraPosition(target: selectedLocation!, zoom: 15),
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
                            _updateAddress(newPosition);
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
                  _fetchAutocompleteSuggestions(searchController
                      .text); // Trigger autocomplete fetch on tap
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 5)
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey[600]),
                      SizedBox(width: 10),
                     Expanded(
  child: TextField(
    controller: searchController,
    decoration: InputDecoration(
      hintText: 'Search for a place',
      border: InputBorder.none,
      suffixIcon: IconButton(
        icon: Icon(Icons.clear, color: Colors.grey),
        onPressed: () {
          setState(() {
            searchController.clear(); // Clear the text
            predictions.clear(); // Optionally clear predictions
          });
        },
      ),
    ),
    onChanged: (query) {
      _fetchAutocompleteSuggestions(query);
    },
  ),
)
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
                  height: 200,
                  child: ListView.builder(
                    itemCount: predictions.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(predictions[index]['description']),
                        onTap: () async {
                          String placeId = predictions[index]['place_id'];
                          await _onPlaceSelected(placeId);
                          setState(() {
                            predictions.clear();
                          });
                          FocusScope.of(context).unfocus();
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
                     constraints: BoxConstraints(
          minHeight: 50,  
          maxHeight: 100, 
        ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 5)
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        searchController.text.isNotEmpty ? searchController.text : address,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: selectedLocation != null
                        ? () {
                          logger.w('userLat: ${selectedLocation!.latitude}');
                          logger.w('userLng: ${selectedLocation!.longitude}');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BillingConfirmationPage(
                                  address: searchController.text.isNotEmpty ? searchController.text : address, 
                                  userLat: selectedLocation!.latitude,
                                  userLng: selectedLocation!.longitude,
                                  cartItems: widget.cartItems,
                                  totalPrice: widget.totalPrice,
                                ),
                              ),
                            );
                          }
                        : null,
                    child: const Text("CONFIRM LOCATION"),
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