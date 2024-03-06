import 'dart:convert';
import 'package:flutter/material.dart';
import '../util/utils.dart';
import 'ForgotPass.dart';
import 'package:http/http.dart' as http;
import 'MainDash.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _usernameTextController = TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();
  bool _isObscure = true;
  String _errorMessage = '';

  Future<void> signIn() async {
    try {
      final response = await http.post(
        Uri.parse('https://5f8f-103-62-152-132.ngrok-free.app/auth/signin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "username": _usernameTextController.text,
          "password": _passwordTextController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        // Check for successful login message (adjust based on your API):
        if (data['message'] == 'Successfully logged in' ||
            data['message'].toLowerCase().contains('success')) {
          // User successfully logged in, proceed to the next page
          print('Login successful!');
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const MainDash(),
            ),
          );
        } else {
          // Handle invalid credentials error
          print('Invalid username or password.');
        }
      } else {
        print('Error fetching data: ${response.statusCode}');
        // Handle other errors
      }
    } catch (e) {
      print('Error: $e');
      // Handle other errors
    }
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 400;
    double sizeAxis = MediaQuery.of(context).size.width / baseWidth;
    double size = sizeAxis *
        0.97; // Check if the user is already authenticated and their role

    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove debug banner
      home: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                  22 * sizeAxis, 120 * sizeAxis, 21 * sizeAxis, 50 * sizeAxis),
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage(
                    'assets/images/bgg9.jpg',
                  ),
                ),
              ),
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
                        color: const Color(0xff1e232c),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(1 * sizeAxis, 0 * sizeAxis,
                        0 * sizeAxis, 15 * sizeAxis),
                    width: 331 * sizeAxis,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8 * sizeAxis),
                      border: Border.all(color: const Color(0xffe8ecf4)),
                      color: const Color(0xfff7f8f9),
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
                  Container(
                    margin: EdgeInsets.fromLTRB(1 * sizeAxis, 0 * sizeAxis,
                        0 * sizeAxis, 15 * sizeAxis),
                    width: 331 * sizeAxis,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8 * sizeAxis),
                      border: Border.all(color: const Color(0xffe8ecf4)),
                      color: const Color(0xfff7f8f9),
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
                            _isObscure
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _isObscure = !_isObscure;
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
                      obscureText: _isObscure, // Toggle password visibility
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
                  Container(
                    margin: EdgeInsets.fromLTRB(
                        1 * sizeAxis, 0 * sizeAxis, 0 * sizeAxis, 0 * sizeAxis),
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ForgotPass(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                      ),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: SafeGoogleFont(
                            'Poppins',
                            fontSize: 15 * size,
                            fontWeight: FontWeight.w600,
                            height: 1.4 * size / sizeAxis,
                            letterSpacing: 0.15 * sizeAxis,
                            color: const Color(0xff1e232c),
                          ),
                          children: [
                            TextSpan(
                              text: "Can't Remember? ",
                              style: SafeGoogleFont(
                                'Urbanist',
                                fontSize: 15 * size,
                                fontWeight: FontWeight.w500,
                                height: 1.4 * size / sizeAxis,
                                letterSpacing: 0.15 * sizeAxis,
                                color: const Color(0xff1e232c),
                              ),
                            ),
                            TextSpan(
                              text: 'Rest Password',
                              style: SafeGoogleFont(
                                'Urbanist',
                                fontSize: 15 * size,
                                fontWeight: FontWeight.w700,
                                height: 1.4 * size / sizeAxis,
                                letterSpacing: 0.15 * sizeAxis,
                                color: const Color(0xff0272bc),
                              ),
                            ),
                          ],
                        ),
                      ),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
