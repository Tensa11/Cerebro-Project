import 'dart:convert';
import 'package:Cerebro/Cerebro/MainDash.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../util/utils.dart';
import 'package:http/http.dart' as http;

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _usernameTextController = TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();
  bool _isHide = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
  }

  Future<void> signIn() async {
    try {
      final username = _usernameTextController.text;
      final password = _passwordTextController.text;
      String convertedPassword;

      // Check for empty username
      if (username.isEmpty) {
        setState(() {
          _errorMessage = 'Please enter your username.';
        });
        return;
      }

      // Check for empty password
      if (password.isEmpty) {
        setState(() {
          _errorMessage = 'Please enter your password.';
        });
        return;
      }

      if (int.tryParse(password) != null) {
        // Password is an integer
        convertedPassword = password.toString();
      } else {
        // Password is a string (or combination)
        convertedPassword = password;
      }

      final apiUrl = dotenv.env['API_URL']; // Retrieve API URL from .env file
      if (apiUrl == null) {
        throw Exception('API_URL environment variable is not defined');
      }

      // Retrieve the refresh token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refreshToken'); // Assuming refresh token is stored separately

      final response = await http.post(
        Uri.parse('$apiUrl/auth/signin'), // Use the retrieved API URL
        headers: {
          'Content-Type': 'application/json',
          'Cookie': 'refreshToken=$refreshToken', // Include the refresh token in the Cookie header
        },
        body: jsonEncode({
          "username": username,
          "password": convertedPassword,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        if (data.containsKey('token')) {
          // Extract token from the response
          final token = data['token'];
          print('Token: $token'); // Print token in the console

          // Save token or handle it as needed
          await prefs.setString('username', username);
          await prefs.setString('email', data['email'] ?? ''); // Handle null email
          await prefs.setString('token', token);

          // Navigate to the main dashboard or home screen
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => LoginSplashScreen(),
            ),
          );
        } else {
          setState(() {
            _errorMessage = 'Token not found in response.';
          });
          print('Token not found in response.');
        }
      } else {
        // Improved error handling for non-200 status codes
        String errorMessage = 'An Error has occurred.';
        if (response.statusCode >= 400 && response.statusCode < 500) {
          errorMessage = 'Client-side error';
        } else if (response.statusCode >= 500) {
          errorMessage = 'Server-side error';
        }
        setState(() {
          _errorMessage = errorMessage;
        });
        print('Error: ${response.statusCode} - ${errorMessage}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An Error has occurred. Please try again later.';
      });
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 400;
    double sizeAxis = MediaQuery.of(context).size.width / baseWidth;
    double size = sizeAxis * 0.97; // Check if the user is already authenticated and their role

    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove debug banner
      home: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                  22 * sizeAxis, 110 * sizeAxis, 22 * sizeAxis, 90 * sizeAxis),
              width: double.infinity,
              // Background Image
              // decoration: const BoxDecoration(
              //   image: DecorationImage(
              //     fit: BoxFit.cover,
              //     image: AssetImage(
              //       'assets/images/bgg9.jpg',
              //     ),
              //   ),
              // ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(2 * sizeAxis, 0 * sizeAxis,
                        0 * sizeAxis, 30 * sizeAxis),
                    child: Image.asset(
                      'assets/logo/applogoNoBG.png', // Replace with your AssetImage
                      width: 100 * sizeAxis, // Adjust the width as needed
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(0 * sizeAxis, 0 * sizeAxis,
                        23 * sizeAxis, 32 * sizeAxis),
                    constraints: BoxConstraints(
                      maxWidth: 307 * sizeAxis,
                    ),
                    child: Text(
                      'Welcome back!\nGlad to see you again!',
                      style: SafeGoogleFont(
                        'Urbanist',
                        fontSize: 30 * size,
                        fontWeight: FontWeight.w700,
                        height: 1.3 * size / sizeAxis,
                        letterSpacing: -0.3 * sizeAxis,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(1 * sizeAxis, 0 * sizeAxis,
                        0 * sizeAxis, 15 * sizeAxis),
                    width: 331 * sizeAxis,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8 * sizeAxis),
                      color: Theme.of(context).colorScheme.primary,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: Offset(0, 1), // changes position of shadow
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _usernameTextController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.fromLTRB(18 * sizeAxis,
                            18 * sizeAxis, 18 * sizeAxis, 19 * sizeAxis),
                        hintText: 'Enter Username',
                        hintStyle: const TextStyle(color: Color(0xff8390a1)),
                      ),
                      style: SafeGoogleFont(
                        'Urbanist',
                        fontSize: 15 * size,
                        fontWeight: FontWeight.w500,
                        height: 1.25 * size / sizeAxis,
                        color: const Color(0xff0272bc),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 5),
                  Container(
                    margin: EdgeInsets.fromLTRB(1 * sizeAxis, 0 * sizeAxis,
                        0 * sizeAxis, 15 * sizeAxis),
                    width: 331 * sizeAxis,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8 * sizeAxis),
                      color: Theme.of(context).colorScheme.primary,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: Offset(0, 1), // changes position of shadow
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _passwordTextController,
                      // Assign the text controller
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.fromLTRB(18 * sizeAxis,
                            18 * sizeAxis, 18 * sizeAxis, 19 * sizeAxis),
                        hintText: 'Enter your Password',
                        hintStyle: const TextStyle(color: Color(0xff8390a1)),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isHide
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                          onPressed: () {
                            setState(() {
                              _isHide = !_isHide;
                            });
                          },
                        ),
                      ),
                      style: SafeGoogleFont(
                        'Urbanist',
                        fontSize: 15 * size,
                        fontWeight: FontWeight.w500,
                        height: 1.25 * size / sizeAxis,
                        color: const Color(0xff0272bc),
                      ),
                      keyboardType: TextInputType.text,
                      obscureText: _isHide, // Toggle password visibility
                    ),
                  ),
                  if (_errorMessage.isNotEmpty)
                    Container(
                      margin: EdgeInsets.fromLTRB(1 * sizeAxis, 10 * sizeAxis,
                          0 * sizeAxis, 0 * sizeAxis),
                      child: Text(
                        _errorMessage,
                        style: SafeGoogleFont(
                          'Urbanist',
                          fontSize: 15 * size,
                          fontWeight: FontWeight.w500,
                          height: 1.4 * size / sizeAxis,
                          letterSpacing: 0.15 * sizeAxis,
                          color: const Color(0xffe74c3c),
                        ),
                      ),
                    ),
                  Container(
                    margin: EdgeInsets.fromLTRB(0 * sizeAxis, 50 * sizeAxis,
                        0 * sizeAxis, 100 * sizeAxis),
                    child: TextButton(
                      onPressed: () {
                        // Call fetchData() function when the button is pressed
                        signIn();
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                      ),
                      child: Container(
                        width: 331 * sizeAxis,
                        height: 56 * sizeAxis,
                        decoration: BoxDecoration(
                          color: const Color(0xffe33924),
                          borderRadius: BorderRadius.circular(8 * sizeAxis),
                        ),
                        child: Center(
                          child: Text(
                            'Login',
                            textAlign: TextAlign.center,
                            style: SafeGoogleFont(
                              'Urbanist',
                              fontSize: 15 * size,
                              fontWeight: FontWeight.w600,
                              height: 1.2 * size / sizeAxis,
                              color: const Color(0xffffffff),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Container(
                  //   margin: EdgeInsets.fromLTRB(
                  //       1 * sizeAxis, 0 * sizeAxis, 0 * sizeAxis, 0 * sizeAxis),
                  //   child: TextButton(
                  //     onPressed: () {
                  //       Navigator.of(context).push(
                  //         MaterialPageRoute(
                  //           builder: (context) => const ForgotPass(),
                  //         ),
                  //       );
                  //     },
                  //     style: TextButton.styleFrom(
                  //       padding: EdgeInsets.zero,
                  //     ),
                  //     child: RichText(
                  //       textAlign: TextAlign.center,
                  //       text: TextSpan(
                  //         style: SafeGoogleFont(
                  //           'Poppins',
                  //           fontSize: 15 * size,
                  //           fontWeight: FontWeight.w600,
                  //           height: 1.4 * size / sizeAxis,
                  //           letterSpacing: 0.15 * sizeAxis,
                  //           color: const Color(0xff1e232c),
                  //         ),
                  //         children: [
                  //           TextSpan(
                  //             text: "Can't Remember? ",
                  //             style: SafeGoogleFont(
                  //               'Urbanist',
                  //               fontSize: 15 * size,
                  //               fontWeight: FontWeight.w500,
                  //               height: 1.4 * size / sizeAxis,
                  //               letterSpacing: 0.15 * sizeAxis,
                  //               color: const Color(0xff1e232c),
                  //             ),
                  //           ),
                  //           TextSpan(
                  //             text: 'Rest Password',
                  //             style: SafeGoogleFont(
                  //               'Urbanist',
                  //               fontSize: 15 * size,
                  //               fontWeight: FontWeight.w700,
                  //               height: 1.4 * size / sizeAxis,
                  //               letterSpacing: 0.15 * sizeAxis,
                  //               color: const Color(0xff0272bc),
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LoginSplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      backgroundColor: Theme.of(context).colorScheme.background,
      splash: Stack(
        children: [
          // Lottie animation in the back
          Center(
            child: Container(
              width: 500,
              height: 500,
              child: Lottie.asset('assets/lottie/Logo.json'),
            ),
          ),
          // Image on top
          Center(
            child: Container(
              width: 160, // Specify the width of the image
              height: 160, // Specify the height of the image
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white, // Set the background color to white
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(90), // Adjust the radius as needed
                child: Image.asset('assets/logo/applogo.png'), // Replace with your image asset path
              ),
            ),
          ),
        ],
      ),
      nextScreen: const SaleDash(),
      splashIconSize: 900,
      duration: 3000,
      splashTransition: SplashTransition.fadeTransition,
    );
  }
}