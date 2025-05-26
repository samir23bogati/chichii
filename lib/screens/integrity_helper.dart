import 'package:flutter/services.dart';

class IntegrityHelper {
  static const platform = MethodChannel('com.chichii.integrity');

  static Future<String?> getPlayIntegrityToken() async {
    try {
      final String token = await platform.invokeMethod('getIntegrityToken');
      return token;
    } catch (e) {
      print('❌ Failed to get token: $e');
      return null;
    }
  }
}
