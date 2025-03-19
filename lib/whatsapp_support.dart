import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsappSupportButton extends StatelessWidget {
  final String whatsappUrl ='https://api.whatsapp.com/send/?phone=9779841557870&text=Hello+ChiChi+Online+Support+Team%2C%0D%0AI+need+some+help+learning+more+about+your+website.+Could+you+please+assist+me+in+navigating+the+site+or+direct+me+to+resources+that+can+help%3F&type=phone_number&app_absent=0' ;

  const WhatsappSupportButton({super.key});

  static Future<void> launchWhatsApp() async { 
    final Uri url = Uri.parse('https://api.whatsapp.com/send/?phone=9779841557870&text=Hello+ChiChi+Online+Support+Team%2C%0D%0AI+need+some+help+learning+more+about+your+website.+Could+you+please+assist+me+in+navigating+the+site+or+direct+me+to+resources+that+can+help%3F&type=phone_number&app_absent=0');

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
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
      label: Text('Support'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green, 
      ),
     
    );
    
  }
}
