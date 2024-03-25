import 'dart:async';
import 'package:Cerebro/Cerebro/Sale.dart';
import 'package:Cerebro/util/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Cerebro/Advisory.dart';
import 'Cerebro/LandV2.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

late SharedPreferences _prefs;

Future<void> main() async {
  // Load environment variables
  await dotenv.load();

  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  _prefs = await SharedPreferences.getInstance();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Set the status bar color and brightness
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Color(0xFF010D23), // Change this to your desired color
        statusBarBrightness: Brightness.dark, // Adjust based on your color
      ),
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightMode,
      darkTheme: darkMode,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      backgroundColor: Theme.of(context).colorScheme.background,
      splash: Lottie.asset('assets/lottie/LottieAnimIntro.json'),
      nextScreen: const Advisory(),
      splashIconSize: 900,
      duration: 2900,
      splashTransition: SplashTransition.fadeTransition,
    );
  }
}
