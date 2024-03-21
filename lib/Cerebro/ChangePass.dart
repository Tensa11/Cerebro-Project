import 'dart:convert';
import 'package:Cerebro/Cerebro/Login.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../util/utils.dart';
import 'Drawer.dart';

class ChangePass extends StatefulWidget {
  const ChangePass({Key? key}) : super(key: key);

  @override
  _ChangePassState createState() => _ChangePassState();
}

class _ChangePassState extends State<ChangePass> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _hideConfirmPass = true;
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

      if (newPassword.isEmpty ||
          confirmPassword.isEmpty ||
          currentPassword.isEmpty) {
        setState(() {
          _errorMessage =
              'Current password, New password and Confirm password are required.';
        });
        return;
      }

      if (newPassword != confirmPassword) {
        setState(() {
          _errorMessage = 'New password and Confirm password do not match.';
        });
        return;
      }
      final apiUrl = dotenv.env['API_URL']; // Retrieve API URL from .env file
      if (apiUrl == null) {
        throw Exception('API_URL environment variable is not defined');
      }
      final response = await http.post(
        Uri.parse('$apiUrl/auth/change_password'),
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

  void confirmAndPasswordChange() {
    changePassword();
    Navigator.pop(context, true); // Explicitly close dialog and return true
  }

  Future<bool> confirmPasswordChange() async {
    final result = await QuickAlert.show(
      backgroundColor: Theme.of(context).colorScheme.background,
      context: context,
      type: QuickAlertType.confirm,
      title: 'Confirm', // Clear and concise title
      titleColor: Color(0xFF13A4FF),
      text: 'Are you sure you want to change your password?',
      textColor: Theme.of(context).colorScheme.tertiary,
      confirmBtnText: 'Confirm',
      cancelBtnText: 'Cancel',
      confirmBtnColor: Theme.of(context).colorScheme.primary, // Optional: Set button color
      onConfirmBtnTap: confirmAndPasswordChange, // Call the separate function
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 400;
    double sizeAxis = MediaQuery.of(context).size.width / baseWidth;
    double size = sizeAxis * 0.97;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      key: _scaffoldKey,
      appBar: AppBar(
        // Set a custom height for the app bar
        toolbarHeight: 80,
        // Transparent background with gradient in flexible space
        backgroundColor: Colors.transparent,
        elevation: 15,
        // Remove default shadow
        leading: IconButton(
          icon: Icon(Icons.menu, color: Theme.of(context).colorScheme.tertiary),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle,
                color: Theme.of(context).colorScheme.tertiary),
            onPressed: () {
              // Add functionality for account button
            },
          ),
        ],
        // Add a gradient background with rounded corners at the bottom
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
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
          // Image.asset(
          //   'assets/images/bgg9.jpg',
          //   fit: BoxFit.cover,
          //   width: double.infinity,
          //   height: double.infinity,
          // ),
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
                          color: const Color(0xFF13A4FF),
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
                          color: Theme.of(context).colorScheme.tertiary,
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
                        controller: _currentPasswordController,
                        // Assign the text controller
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
                              color: Theme.of(context).colorScheme.tertiary,
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
                        controller: _newPasswordController,
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
                              color: Theme.of(context).colorScheme.tertiary,
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
                        obscureText:
                            _hideNewPass // Toggle password visibility
                      ),
                    ),
                    // Re enter the newly created password for confirmation
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
                        controller: _confirmPasswordController,
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
                              _hideConfirmPass
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                            onPressed: () {
                              setState(() {
                                _hideConfirmPass = !_hideConfirmPass;
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
                        obscureText:
                            _hideConfirmPass, // Toggle password visibility
                      ),
                    ),
                    if (_errorMessage.isNotEmpty)
                      Container(
                        margin: EdgeInsets.fromLTRB(13 * sizeAxis,
                            10 * sizeAxis, 0 * sizeAxis, 0 * sizeAxis),
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
                    // Button
                    Container(
                      margin: EdgeInsets.fromLTRB(0 * sizeAxis, 50 * sizeAxis,
                          0 * sizeAxis, 150 * sizeAxis),
                      child: TextButton(
                        onPressed: () async {
                          if (await confirmPasswordChange()) {
                            changePassword();
                          }
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
    );
  }
}
