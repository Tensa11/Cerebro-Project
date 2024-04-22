import 'dart:async';
import 'package:Cerebro/Cerebro/MainDash.dart';
import 'package:Cerebro/util/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Cerebro/Example.dart';
import 'Cerebro/LandV2.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'Cerebro/TestDash.dart';

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
    return FutureBuilder<bool>(
      future: isUserLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return AnimatedSplashScreen(
            backgroundColor: Theme.of(context).colorScheme.background,
            splash: Stack(
              children: [
                Center(
                  child: Container(
                    width: 500,
                    height: 500,
                    child: Lottie.asset('assets/lottie/Logo.json'),
                  ),
                ),
                Center(
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(90),
                      child: Image.asset('assets/logo/applogo.png'),
                    ),
                  ),
                ),
              ],
            ),
            nextScreen: CircularProgressIndicator(), // Show a loading indicator while checking the login state
            splashIconSize: 900,
            duration: 2900,
            splashTransition: SplashTransition.fadeTransition,
          );
        } else if (snapshot.hasData && snapshot.data == true) {
          return MainDash(); // If the user is logged in, navigate to the LandV2 (Landing Page)
        } else {
          return LandingPage(); // If the user is not logged in, navigate to the LoginPage
        }
      },
    );
  }

  Future<bool> isUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    return token != null;
  }
}