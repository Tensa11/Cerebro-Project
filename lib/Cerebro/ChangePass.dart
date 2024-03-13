import 'dart:convert';
import 'package:Cerebro/Cerebro/Login.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../util/utils.dart';
import 'VerifyPass.dart';

class ChangePass extends StatefulWidget {
  const ChangePass({Key? key}) : super(key: key);

  @override
  _ChangePassState createState() => _ChangePassState();
}

class _ChangePassState extends State<ChangePass> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isObscure = true;
  String _errorMessage = '';

  Future<void> changePassword() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username');
      final currentPassword = _currentPasswordController.text;
      final newPassword = _newPasswordController.text;
      final confirmPassword = _confirmPasswordController.text;

      if (newPassword != confirmPassword) {
        setState(() {
          _errorMessage = 'New password and confirm password do not match.';
        });
        return;
      }

      final response = await http.post(
        Uri.parse('https://ccea-143-44-192-98.ngrok-free.app/auth/change_password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "username": username,
          "current_password": currentPassword,
          "new_password": newPassword,
          "confirm_password": confirmPassword,
        }),
      );

      if (response.statusCode == 200) {
        // Password changed successfully, navigate back to login page
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const Login(),
          ),
        );
      } else {
        setState(() {
          _errorMessage = 'Failed to change password. Please try again later.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 400;
    double sizeAxis = MediaQuery.of(context).size.width / baseWidth;
    double size = sizeAxis * 0.97;

    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove debug banner
      home: Scaffold(
        body: Stack(
          children: [
            // Background image
            Image.asset(
              'assets/images/bgg9.jpg',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            SingleChildScrollView(
              child: SizedBox(
                width: double.infinity,
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                      22 * sizeAxis, 180 * sizeAxis, 21 * sizeAxis, 0 * sizeAxis),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.fromLTRB(0 * sizeAxis, 0 * sizeAxis,
                            50 * sizeAxis, 20 * sizeAxis),
                        child: Text(
                          'Change Password?!',
                          style: GoogleFonts.urbanist(
                            fontSize: 30 * size,
                            fontWeight: FontWeight.w700,
                            height: 1.3 * size / sizeAxis,
                            letterSpacing: -0.3 * sizeAxis,
                            color: const Color(0xff0272bc),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(0 * sizeAxis, 0 * sizeAxis,
                            20 * sizeAxis, 32 * sizeAxis),
                        constraints: BoxConstraints(
                          maxWidth: 307 * sizeAxis,
                        ),
                        child: Text(
                          "Need to reset your password? Enter your new password and make sure its a strong password.",
                          style: SafeGoogleFont(
                            'Urbanist',
                            fontSize: 13 * size,
                            fontWeight: FontWeight.w400,
                            height: 1.3 * size / sizeAxis,
                            letterSpacing: -0.3 * sizeAxis,
                            color: const Color(0xff1e232c),
                          ),
                        ),
                      ),
                      // Enter current password and must match
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
                          controller: _currentPasswordController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            contentPadding: EdgeInsets.fromLTRB(18 * sizeAxis,
                                18 * sizeAxis, 18 * sizeAxis, 19 * sizeAxis),
                            hintText: 'Enter The Current Password',
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
                      // Enter the newly created password
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
                          controller: _newPasswordController,
                          // Assign the text controller
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            contentPadding: EdgeInsets.fromLTRB(18 * sizeAxis,
                                18 * sizeAxis, 18 * sizeAxis, 19 * sizeAxis),
                            hintText: 'Enter The New Password',
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
                      // Re enter the newly created password for confirmation
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
                          controller: _confirmPasswordController,
                          // Assign the text controller
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            contentPadding: EdgeInsets.fromLTRB(18 * sizeAxis,
                                18 * sizeAxis, 18 * sizeAxis, 19 * sizeAxis),
                            hintText: 'Retype The New Password',
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
                            0 * sizeAxis, 150 * sizeAxis),
                        child: TextButton(
                          onPressed: changePassword,
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
                                'Confirm',
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
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
