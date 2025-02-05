import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddressSelectionPage extends StatefulWidget {
  @override
  _AddressSelectionPageState createState() => _AddressSelectionPageState();
}

class _AddressSelectionPageState extends State<AddressSelectionPage> {
  GoogleMapController? mapController;
  LatLng? selectedLocation;
  String address = "Move the marker to select an address";

  @override
  void initState() {
    super.initState();
    _determinePosition();
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

      _getAddressFromLatLng(selectedLocation!);
    } catch (e) {
      _showLocationError("Failed to get current location.");
    }
  }

  // Convert LatLng to Address
  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        setState(() {
          address =
              "${place.street ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}, ${place.country ?? ''}".trim();
        });
      }
    } catch (e) {
      _showLocationError("Failed to fetch address.");
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
