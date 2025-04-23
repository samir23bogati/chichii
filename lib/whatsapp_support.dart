import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsappSupportButton extends StatelessWidget {
  const WhatsappSupportButton({super.key});

  static Future<void> launchWhatsApp() async {
    final Uri url = Uri.parse(
      'https://api.whatsapp.com/send/?phone=9779841557870&text=Hello%20ChiChii%20Online%20Support%20Team%20%F0%9F%91%8B%2C%0A%0AI%E2%80%99m%20using%20the%20ChiChii%20Online%20app%20and%20I%20need%20a%20little%20help%20understanding%20how%20to%20use%20some%20features.%20Could%20you%20please%20assist%20me%20with%20navigating%20the%20app%20or%20share%20any%20resources%20or%20guides%20that%20might%20help%3F%0A%0AThank%20you%20so%20much!%20%F0%9F%99%8F&type=phone_number&app_absent=0',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch WhatsApp';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: launchWhatsApp,
      icon: Image.asset(
        'assets/images/whatsapp.png',
        height: 18,
        width: 14,
      ),
      label: const Text('Support'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
      ),
    );
  }
}
