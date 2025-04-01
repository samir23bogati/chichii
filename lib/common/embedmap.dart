import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Embedmap extends StatelessWidget {
  final LatLng location = LatLng(27.721099, 85.308499);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: location, zoom: 15),
        markers: {
          Marker(
            markerId: MarkerId("shop_location"),
            position: location,
            infoWindow: InfoWindow(title: "ChiChii Online"),
          ),
        },
      ),
    );
  }
}
