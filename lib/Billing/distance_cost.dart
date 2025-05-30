import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> calculateDistance(double userLat, double userLng) async {
  const double fixedLat = 27.7210704; // Chichii Online's latitude (Kathmandu)
  const double fixedLng = 85.30847450000002; // Chichii Online's longitude (Kathmandu)
    
  final String? apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    throw Exception("Google Maps API Key is missing. Check your .env file.");
  }

  
  final String url =
      'https://maps.googleapis.com/maps/api/distancematrix/json?'
      'origins=$fixedLat,$fixedLng'
      '&destinations=$userLat,$userLng'
      '&mode=driving' 
      '&key=$apiKey';

  try {
    
    final response = await http.get(Uri.parse(url));

   
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      
      print('API Response: $data');

     
      if (data['status'] == 'OK') {
        var elementStatus = data['rows'][0]['elements'][0]['status'];
       if (elementStatus == 'OK') {
          final distanceInMeters = data['rows'][0]['elements'][0]['distance']['value'];
          final durationInSeconds = data['rows'][0]['elements'][0]['duration']['value'];

          if (distanceInMeters > 0) {
            final distanceInKm = distanceInMeters / 1000.0; 
            final double deliveryCost = calculateDeliveryCost(distanceInKm);


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
    rethrow; 
  }
}

double calculateDeliveryCost(double distance) {
  DateTime now = DateTime.now().toUtc().add(Duration(hours: 5, minutes: 45));

  // Default base cost
  double baseCost = 100.0;

 if ((now.hour == 23 && now.minute >= 5) || (now.hour < 4)) {
  baseCost = 200.0;
}

  double additionalCostPerKm = 12.0; 

  if (distance <= 3) {
    return baseCost;
  } else {
    double extraDistance = distance - 3;
    double extraCost = extraDistance * additionalCostPerKm;
    return baseCost + extraCost;
  }
}
