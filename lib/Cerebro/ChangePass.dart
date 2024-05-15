import 'dart:convert';
import 'package:Cerebro/Cerebro/Login.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
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
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _hideConfirmPass = true;
  bool _hideCurrentPass = true;
  bool _hideNewPass = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _getAvatarData();
    _getUserData();
  }

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

  String avatarUrl = '';
  String username = '';
  Future<void> _getAvatarData() async {
    try {
      final apiUrl = dotenv.env['API_URL']; // Retrieve API URL from .env file
      if (apiUrl == null) {
        throw Exception('API_URL environment variable is not defined');
      }
      var url = Uri.parse('$apiUrl/med/hospital/me');
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token'); // Assuming you saved the token with this key
      final refreshToken = prefs.getString('refreshToken'); // Assuming refresh token is stored separately

      if (token == null) {
        throw Exception('Token not found.');
      }
      var response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Cookie': 'refreshToken=$refreshToken',
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        String? avatar = data['avatar']; // Store the avatar URL

        setState(() {
          avatarUrl = avatar ?? ''; // If avatar is null, assign an empty string
        });
      } else {
        throw Exception('Failed to load total _getHospitalData');
      }
    } catch (e) {
      print('Error fetching total _getHospitalData: $e');
      setState(() {});
    }
  }
  Future<void> _getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username') ?? '';
    setState(() {}); // Update the UI with retrieved data
  }


  @override
  Widget build(BuildContext context) {
    double baseWidth = 375;
    double sizeAxis = MediaQuery.of(context).size.width / baseWidth;
    double size = sizeAxis * 0.97;

    return Scaffold(
      backgroundColor: Color(0xFF1497E8),
      key: _scaffoldKey,
      drawer: CereDrawer(),
      appBar: AppBar(
        // Set a custom height for the app bar
        toolbarHeight: 80,
        // Transparent background with gradient in flexible space
        backgroundColor: Colors.transparent,
        elevation: 15,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          GestureDetector(
            onTap: () async {
              if (avatarUrl.isNotEmpty) {
                await showDialog(
                  context: context,
                  builder: (_) => Dialog(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                icon: Icon(Icons.close_rounded),
                                color: Colors.redAccent,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          child: Image.network(
                            avatarUrl,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white, // Border color
                  width: 2, // Border width
                ),
              ),
              child: ClipOval(
                child: avatarUrl.isNotEmpty
                    ? CachedNetworkImage(
                  imageUrl: avatarUrl,
                  height: 40,
                  width: 40,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Icon(Icons.local_hospital, size: 40), // Fallback icon when avatarUrl fails to load
                ) : Icon(Icons.local_hospital, size: 40), // Fallback icon when avatarUrl is empty
              ),
            ),
          ),
          SizedBox(width: 20),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Color(0xFF1497E8),
          ),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: LiquidPullToRefresh(
        onRefresh: _handleRefresh,
        color: Color(0xFF1497E8),
        height: 150,
        backgroundColor: Colors.redAccent,
        animSpeedFactor: 2,
        showChildOpacityTransition: false,
        child: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 15.0),
              child: Column(
                children: [
                  SizedBox(height: 10,),
                  // WELCOME! ----------------------------------------------------
                  Padding(
                    padding: EdgeInsets.only(left: 30.0, right: 30.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Change Password?!',
                          style: GoogleFonts.urbanist(
                            fontSize: 20 * size,
                            fontWeight: FontWeight.w700,
                            height: 1.3 * size / sizeAxis,
                            letterSpacing: -0.3 * sizeAxis,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Need to reset your password? Enter your new password and make sure its a strong password.",
                          style: SafeGoogleFont(
                            'Urbanist',
                            fontSize: 13 * size,
                            fontWeight: FontWeight.w400,
                            height: 1.3 * size / sizeAxis,
                            letterSpacing: -0.3 * sizeAxis,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 30),
                      ],
                    ),
                  ),
                  SizedBox(height: 5.0),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.background,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(75.0)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(left: 30.0, right: 30.0),
                        child: Column(
                          children: [
                            SizedBox(height: 65),
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
                            SizedBox(height: 10),
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
                            SizedBox(height: 10),
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
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    _currentPasswordController.text = '';
    _newPasswordController.text = '';
    _confirmPasswordController.text = '';

    await _getAvatarData();
    await _getUserData();
    setState(() {});
    return await Future.delayed(Duration(seconds: 2));
  }

}
