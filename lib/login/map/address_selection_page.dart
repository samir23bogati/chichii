import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;  
import 'package:google_maps_flutter/google_maps_flutter.dart' as google_maps;
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart' as places;
import 'package:padshala/Billing/BillingConfirmationPage.dart';
import 'package:padshala/model/cart_item.dart';

class AddressSelectionPage extends StatefulWidget {
  final List<CartItem> cartItems;
  final double totalPrice;

  AddressSelectionPage({
    required this.cartItems,
    required this.totalPrice,
    Key? key,
  }) : super(key: key);

  @override
  _AddressSelectionPageState createState() => _AddressSelectionPageState();
}

class _AddressSelectionPageState extends State<AddressSelectionPage> {
  google_maps.GoogleMapController? mapController;
  google_maps.LatLng? selectedLocation;
  String address = "Move the marker to select an address";
  TextEditingController _searchController = TextEditingController();
  final _places = places.FlutterGooglePlacesSdk("AIzaSyDub1Zi-dM0YXcoQB_DJKIYFGhRsvevA5Y");

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showLocationError("Location services are disabled.");
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        _showLocationError("Location permission is denied permanently.");
        return;
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        selectedLocation = google_maps.LatLng(position.latitude, position.longitude);
      });
      if (mapController != null) {
        mapController!.animateCamera(google_maps.CameraUpdate.newLatLngZoom(selectedLocation!, 15));
      }
      _getAddressFromLatLng(selectedLocation!);
    } catch (e) {
      _showLocationError("Failed to get current location.");
    }
  }

  Future<void> _getAddressFromLatLng(google_maps.LatLng location) async {
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

  Future<List<places.AutocompletePrediction>> _getSuggestions(String query) async {
    final result = await _places.findAutocompletePredictions(query);
    return result.predictions;
  }

  Future<google_maps.LatLng?> _getLatLngFromPlaceId(String placeId) async {
    final details = await _fetchPlaceDetails(placeId); // Fetch place details using HTTP request
    final location = details['result']['geometry']['location'];
    if (location != null) {
      return google_maps.LatLng(location['lat'], location['lng']);
    }
    return null;
  }

  // Fetch place details from Google Places API using HTTP
  Future<Map<String, dynamic>> _fetchPlaceDetails(String placeId) async {
    final apiKey = 'AIzaSyDub1Zi-dM0YXcoQB_DJKIYFGhRsvevA5Y';
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch place details');
    }
  }

  void _showLocationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Address")),
      body: Stack(
        children: [
          selectedLocation == null
              ? const Center(child: CircularProgressIndicator())
              : google_maps.GoogleMap(
                  onMapCreated: (controller) {
                    mapController = controller;
                    if (selectedLocation != null) {
                      mapController!.animateCamera(google_maps.CameraUpdate.newLatLngZoom(selectedLocation!, 15));
                    }
                  },
                  initialCameraPosition: google_maps.CameraPosition(target: selectedLocation!, zoom: 15),
                  markers: {
                    google_maps.Marker(
                      markerId: const google_maps.MarkerId("selected"),
                      position: selectedLocation!,
                      draggable: true,
                      onDragEnd: (google_maps.LatLng newPosition) {
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
            child: Autocomplete<places.AutocompletePrediction>(
              optionsBuilder: (textEditingValue) async {
                if (textEditingValue.text.isEmpty) return [];
                return await _getSuggestions(textEditingValue.text);
              },
              displayStringForOption: (option) => option.fullText,
              onSelected: (selectedPrediction) async {
                google_maps.LatLng? newLocation = await _getLatLngFromPlaceId(selectedPrediction.placeId);
                if (newLocation != null) {
                  setState(() {
                    selectedLocation = newLocation;
                    address = selectedPrediction.fullText;
                  });
                  mapController?.animateCamera(google_maps.CameraUpdate.newLatLngZoom(selectedLocation!, 15));
                }
              },
              fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                _searchController = controller;
                return TextField(
                  controller: _searchController,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    hintText: "Search Address",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 98,
            right: 10,
            child: IconButton(
              icon:Icon(Icons.my_location),
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
    );
  }
}
