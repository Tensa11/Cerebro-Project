import 'dart:convert';
import 'package:Cerebro/Cerebro/Login.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../util/utils.dart';
import 'Drawer.dart';
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
  bool _hideCofrmPass = true;
  bool _hideCurrentPass = true;
  bool _hideNewPass = true;
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
        Uri.parse('https://ef80-103-62-152-132.ngrok-free.app/auth/change_password'),
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    double baseWidth = 400;
    double sizeAxis = MediaQuery.of(context).size.width / baseWidth;
    double size = sizeAxis * 0.97;

    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove debug banner

      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          // Set a custom height for the app bar
          toolbarHeight: 80,
          // Transparent background with gradient in flexible space
          backgroundColor: Colors.transparent,
          elevation: 15,  // Remove default shadow
          leading: IconButton(
            icon: Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          actions: [
            Image(
              image: AssetImage('assets/logo/appNameLogo.png'),
              width: 150,  // Adjust width as needed
              height: 150,  // Adjust height as needed
            ),
            Image(
              image: AssetImage('assets/logo/space.png'),
              width: 50,  // Adjust width as needed
              height: 150,  // Adjust height as needed
            ),
            Image(
              image: AssetImage('assets/logo/space.png'),
              width: 90,  // Adjust width as needed
              height: 150,  // Adjust height as needed
            ),
            IconButton(
              icon: Icon(Icons.search, color: Colors.black),
              onPressed: () {
                // Add functionality for search button
              },
            ),
            IconButton(
              icon: Icon(Icons.account_circle, color: Colors.black),
              onPressed: () {
                // Add functionality for account button
              },
            ),
          ],
          // Add a gradient background with rounded corners at the bottom
          flexibleSpace: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bgg4.jpg'),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
          ),
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        drawer: CereDrawer(),
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
                      22 * sizeAxis, 80 * sizeAxis, 21 * sizeAxis, 0 * sizeAxis),
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
                                _hideCurrentPass
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _hideCurrentPass = !_hideCurrentPass;
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
                          obscureText: _hideCurrentPass, // Toggle password visibility
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
                                _hideNewPass
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _hideNewPass = !_hideNewPass;
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
                          obscureText: _hideNewPass, // Toggle password visibility
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
                                _hideCofrmPass
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _hideCofrmPass = !_hideCofrmPass;
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
                          obscureText: _hideCofrmPass, // Toggle password visibility
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
