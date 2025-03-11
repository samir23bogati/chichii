import 'dart:convert';
import 'package:http/http.dart' as http;

Future<double> calculateDistance(double userLat, double userLng) async {
  const String fixedLat = 27.7172; // Chichii Online's latitude (e.g., Kathmandu)
  const String fixedLng = 85.3240; // Chichii Online's longitude (e.g., Kathmandu)

  final String apiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
  final String url = 'https://maps.googleapis.com/maps/api/distancematrix/json?origins=$userLat,$userLng&destinations=$fixedLat,$fixedLng&key=$apiKey';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final distanceInMeters = data['rows'][0]['elements'][0]['distance']['value'];
    final distanceInKm = distanceInMeters / 1000.0; // Convert meters to kilometers
    
    // Calculate the delivery cost based on the distance
    return calculateDeliveryCost(distanceInKm);
  } else {
    throw Exception('Failed to load distance data');
  }
}

double calculateDeliveryCost(double distance) {
  double baseCost = 100.0; // Base delivery cost (e.g., 100 NRS for the first 5 km)
  double additionalCostPerKm = 10.0; // Additional cost per km

  if (distance <= 5) {
    return baseCost; // Free or fixed delivery cost for the first 5 km
  } else {
    double extraDistance = distance - 5;
    double extraCost = extraDistance * additionalCostPerKm;
    return baseCost + extraCost;
  }
}
