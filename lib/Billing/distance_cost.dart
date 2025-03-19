import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> calculateDistance(double userLat, double userLng) async {
  const double fixedLat = 27.7211462; // Chichii Online's latitude (Kathmandu)
  const double fixedLng = 85.3085712; // Chichii Online's longitude (Kathmandu)

  // Load API key from environment variables
  final String? apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    throw Exception("Google Maps API Key is missing. Check your .env file.");
  }

  // Construct the API URL
  final String url =
      'https://maps.googleapis.com/maps/api/distancematrix/json?'
      'origins=$userLat,$userLng'
      '&destinations=$fixedLat,$fixedLng'
      '&mode=driving' 
      '&key=$apiKey';

  try {
    // Make the API call
    final response = await http.get(Uri.parse(url));

    // Check if the response is successful
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      // Log the full response to debug
      print('API Response: $data');

      // Check if the API returned a valid result
      if (data['status'] == 'OK') {
        var elementStatus = data['rows'][0]['elements'][0]['status'];
       if (elementStatus == 'OK') {
          final distanceInMeters = data['rows'][0]['elements'][0]['distance']['value'];
          final durationInSeconds = data['rows'][0]['elements'][0]['duration']['value'];
          print('Distance in meters: $distanceInMeters'); 
          print('Duration in seconds: $durationInSeconds');

          if (distanceInMeters > 0) {
            final distanceInKm = distanceInMeters / 1000.0; // Convert meters to km
            final double deliveryCost = calculateDeliveryCost(distanceInKm);

            print('Total distance: $distanceInKm km');
            print('Delivery cost: $deliveryCost NRS');

            return {
              'distance': distanceInKm,
              'cost': deliveryCost,
            };
          } else {
            print('Error: Distance returned is zero or invalid.');
            throw Exception('Invalid distance value returned from Google API.');
          }
        } else {
          print('Distance calculation error: $elementStatus');
          throw Exception('Error in API response: $elementStatus');
        }
      } else {
        print('Google Maps API Error: ${data['status']}');
        throw Exception('Google Maps API error: ${data['status']}');
      }
    } else {
      print('Error response: ${response.body}');
      throw Exception('Failed to fetch distance data from Google Maps API');
    }
  } catch (e) {
    print('Error occurred: $e');
    rethrow;  // Re-throw the error after logging it
  }
}

double calculateDeliveryCost(double distance) {
  double baseCost = 100.0; // Base delivery cost for up to 4 km
  double additionalCostPerKm = 12.0; // Additional cost per km

  if (distance <= 3) {
    return baseCost; 
  } else {
    double extraDistance = distance - 3;
    double extraCost = extraDistance * additionalCostPerKm;
    return baseCost + extraCost;
  }
}
