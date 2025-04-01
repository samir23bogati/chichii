import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Embedmap extends StatefulWidget {
  @override
  _EmbedmapState createState() => _EmbedmapState();
}

class _EmbedmapState extends State<Embedmap> {
  final LatLng location = LatLng(27.721099, 85.308499);
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _markers.add(Marker(
      markerId: MarkerId("shop_location"),
      position: location,
      infoWindow: InfoWindow(title: "ChiChii Online - 24/7 Night Food & Drinks Delivery",
        snippet: "in Thamel, Kathmandu",),
      onTap: () {
        // This will show the info window when the marker is tapped
        _mapController.showMarkerInfoWindow(MarkerId("shop_location"));
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        onMapCreated: (controller) {
          _mapController = controller;
        },
        initialCameraPosition: CameraPosition(target: location, zoom: 15),
        markers: _markers,
      ),
    );
  }
}
