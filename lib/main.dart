import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:navigation/Cerebro/Login.dart';
import 'Cerebro/Home.dart';

Future <void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'iPECS',
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      // splash: Lottie.asset('assets/lottie/LottieAnimationIntro.json'),
      splash: Lottie.network('https://lottie.host/21218a7c-b9b8-41b1-ae95-6e4b7a95be04/77eXIk00NF.json'),
      nextScreen: const Login(),
      splashIconSize: 900,
      duration: 3000,
      splashTransition: SplashTransition.fadeTransition,
    );
  }
}

