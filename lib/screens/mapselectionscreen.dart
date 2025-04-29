import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

class MapSelectionScreen extends StatefulWidget {
   final Function(LatLng) onLocationSelected;

  MapSelectionScreen({required this.onLocationSelected});
  @override
  _MapSelectionScreenState createState() => _MapSelectionScreenState();
}

class _MapSelectionScreenState extends State<MapSelectionScreen> {
  late GoogleMapController _mapController;
  LatLng? selectedLocation;
  String? selectedAddress;
  List<String> autocompleteSuggestions = [];
  final TextEditingController _searchController = TextEditingController();
  final Logger logger = Logger();
   Position? _currentPosition;


  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    requestLocationPermission();
  }
Future<void> requestLocationPermission() async {
    PermissionStatus status = await Permission.location.request();
    if (status.isGranted) {
      // Proceed with fetching location
      _getCurrentLocation();
    } else {
     ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Location permission denied")),
     );
    }
  }
  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
         _currentPosition = position;
        selectedLocation = LatLng(position.latitude, position.longitude);
          _searchController.clear(); 
      autocompleteSuggestions.clear();
      });
      _updateAddress(selectedLocation!);
      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(selectedLocation!,14.0),
      );
    } catch (e) {
      logger.e("Error fetching location: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error fetching location. Please try again.")),
    );
  }
}

  Future<void> _updateAddress(LatLng position) async {
    final String? apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      logger.e("Error: Missing Google Maps API Key");
      return;
    }
    final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$apiKey",
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'].isNotEmpty) {
          setState(() {
            selectedAddress = data['results'][0]['formatted_address'];
          });
        }
      } else {
        logger.e("Failed to fetch address");
      }
    } catch (e) {
      logger.e("Error fetching address: $e");
    }
  }

  Future<void> _fetchNearbyAutocompleteSuggestions(String input) async {
    final String? apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
    if (apiKey == null || apiKey.isEmpty || _currentPosition == null) return;


   final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/place/autocomplete/json?"
      "input=$input&location=${_currentPosition!.latitude},${_currentPosition!.longitude}&radius=5000&key=$apiKey",
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          autocompleteSuggestions =
              List<String>.from(data['predictions'].map((p) => p['description']));
        });
      }
    } catch (e) {
      logger.e("Error fetching autocomplete suggestions: $e");
    }
  }

  void _onPlaceSelected(String place) async {
  final String? apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) return;

  final url = Uri.parse(
    "https://maps.googleapis.com/maps/api/place/details/json?"
    "place_id=${await _getPlaceId(place)}&key=$apiKey",
  );

  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final location = data['result']['geometry']['location'];
      final LatLng newLocation = LatLng(location['lat'], location['lng']);

      setState(() {
        selectedLocation = newLocation;
        _searchController.text = place;
        autocompleteSuggestions.clear();
      });

      _updateAddress(newLocation);
      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(newLocation, 14.0),
      );
    }
  } catch (e) {
    logger.e("Error selecting place: $e");
  }
}
// Helper function to fetch Place ID
Future<String?> _getPlaceId(String place) async {
  final String? apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) return null;

  final url = Uri.parse(
    "https://maps.googleapis.com/maps/api/place/autocomplete/json?"
    "input=$place&key=$apiKey",
  );

  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['predictions'].isNotEmpty ? data['predictions'][0]['place_id'] : null;
    }
  } catch (e) {
    logger.e("Error fetching Place ID: $e");
  }
  return null;
}
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _confirmLocation() {
  if (selectedLocation != null && selectedAddress != null) {
    Navigator.pop(context, {
      'location': selectedLocation,
      'address': selectedAddress,
    });
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Please select a location first!")),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Delivery Location")),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: selectedLocation ?? LatLng(27.7172, 85.3240),
              zoom: 14.0,
            ),
            markers: selectedLocation != null
                ? {
                    Marker(
                      markerId: MarkerId("selected"),
                      position: selectedLocation!,
                      draggable: true,
                      onDragEnd: (newPosition) {
                        setState(() {
                          selectedLocation = newPosition;
                        });
                        _updateAddress(newPosition);
                      },
                     icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                    ),
                  }
                : {},
          ),
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: _fetchNearbyAutocompleteSuggestions,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Search Desired Delivery Location",
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
        ? IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              setState(() {
                _searchController.clear();
                autocompleteSuggestions.clear();
              });
            },
          )
        : null,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
  ),
),
                if (autocompleteSuggestions.isNotEmpty)
                  Container(
                    color: Colors.white,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: autocompleteSuggestions.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(autocompleteSuggestions[index]),
                      onTap: () => _onPlaceSelected(autocompleteSuggestions[index]),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
        Positioned(
          bottom: 10, // Adjusted to make space for address box
          left: 10,
          right: 10,
          child: Container(
          padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            selectedAddress != null ? "📍 $selectedAddress" : "Select  Delivery Location.",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            
          ),
        ),
        TextButton(
          onPressed: _confirmLocation,
          style: TextButton.styleFrom(
            backgroundColor: Colors.amber,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          child: Text(
            "Confirm ",
            style: TextStyle(
              color: Colors.white,
             fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      
      // Add a floating action button for GPS button
      Positioned(
        bottom: 100,  
        right: 10,
        child: FloatingActionButton(
          onPressed: _getCurrentLocation,
          backgroundColor: Colors.green,
          child: Icon(Icons.gps_fixed, color: Colors.white),
        ),
      ),
    ],
  ), 
  ); 
  }
}