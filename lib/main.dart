import 'package:flutter/material.dart';
import 'package:headsup/pages/const/splashscreen.dart';
//import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await SharedPreferences.getInstance();
    // MobileAds.instance.initialize();
  } catch (e) {
    debugPrint("Error initializing SharedPreferences: $e");
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Add const if MyApp is immutable.

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
