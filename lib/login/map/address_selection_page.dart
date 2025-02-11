import 'dart:convert'; 
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http; // Add this import for HTTP requests

class AddressSelectionPage extends StatefulWidget {
  @override
  _AddressSelectionPageState createState() => _AddressSelectionPageState();
}

class _AddressSelectionPageState extends State<AddressSelectionPage> {
  GoogleMapController? mapController;
  LatLng? selectedLocation;
  String address = "Move the marker to select an address";
  TextEditingController _searchController = TextEditingController(); // Controller for search input

  @override
  void initState() {
    super.initState();
    _determinePosition(); // Get initial location when the page is loaded
  }

  // Get user location
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
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        selectedLocation = LatLng(position.latitude, position.longitude);
      });

      if (mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(selectedLocation!, 15),
        );
      }

      _getAddressFromLatLng(selectedLocation!); // Call method to get address from LatLng
    } catch (e) {
      _showLocationError("Failed to get current location.");
    }
  }

  // Convert LatLng to Address
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

  // Convert Address to LatLng
  Future<LatLng?> _getLatLngFromAddress(String address) async {
    final apiKey = "YOUR_GOOGLE_PLACES_API_KEY"; // Replace with your API Key
    final url =
        "https://maps.googleapis.com/maps/api/geocode/json?address=$address&key=$apiKey";

    try {
      final response = await http.get(Uri.parse(url)); // Use the http package
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["status"] == "OK") {
          final location = data["results"][0]["geometry"]["location"];
          return LatLng(location["lat"], location["lng"]);
        }
      }
    } catch (e) {
      print("Error converting address to coordinates: $e");
    }
    return null; // Return null if there's an error
  }

  // Show error message
  void _showLocationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // Search for an address using Google Places API
  Future<List<String>> _getSuggestions(String query) async {
    final apiKey = "YOUR_GOOGLE_PLACES_API_KEY"; // Replace with your actual key
    final url =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$apiKey&components=country:np"; // Restrict to Nepal (change as needed)

    try {
      final response = await http.get(Uri.parse(url)); // Use the http package
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["status"] == "OK") {
          return (data["predictions"] as List)
              .map((item) => item["description"].toString())
              .toList();
        }
      }
    } catch (e) {
      print("Error fetching suggestions: $e");
    }
    return []; // Return empty list if there's an error
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Address")),
      body: Stack(
        children: [
          selectedLocation == null
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                  onMapCreated: (controller) {
                    mapController = controller;
                    if (selectedLocation != null) {
                      mapController!.animateCamera(
                        CameraUpdate.newLatLngZoom(selectedLocation!, 15),
                      );
                    }
                  },
                  initialCameraPosition: CameraPosition(
                    target: selectedLocation!,
                    zoom: 15,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId("selected"),
                      position: selectedLocation!,
                      draggable: true,
                      onDragEnd: (LatLng newPosition) {
                        setState(() {
                          selectedLocation = newPosition;
                        });
                        _getAddressFromLatLng(newPosition);
                      },
                    ),
                  },
                ),
          // GPS Tracking Icon Button
          Positioned(
            top: 50,
            right: 20,
            child: IconButton(
              icon: Icon(Icons.my_location, size: 30),
              onPressed: () {
                _determinePosition(); // Recenter map to current location
              },
            ),
          ),
          // Search bar for Address search using Google Places API
          Positioned(
            top: 100,
            left: 20,
            right: 20,
            child: TypeAheadField<String>(
              controller: _searchController,
              suggestionsCallback: (pattern) async {
                return await _getSuggestions(pattern); // Fetch suggestions
              },
              itemBuilder: (context, suggestion) {
                return ListTile(
                  title: Text(suggestion),
                );
              },
              onSelected: (suggestion) async {
                // Update the map view to the selected address
                LatLng? newLocation = await _getLatLngFromAddress(suggestion);
                if (newLocation != null) {
                  setState(() {
                    selectedLocation = newLocation;
                    address = suggestion;
                  });
                  mapController?.animateCamera(
                    CameraUpdate.newLatLngZoom(selectedLocation!, 15),
                  );
                }
              },
            ),
          ),
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 5),
                    ],
                  ),
                  child: Text(
                    address,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: selectedLocation != null
                      ? () => Navigator.pop(context, selectedLocation)
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
