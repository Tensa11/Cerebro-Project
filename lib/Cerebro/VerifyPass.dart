import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../util/utils.dart';
import 'Home.dart';
import 'Login.dart';

class VerifyPass extends StatefulWidget {
  const VerifyPass({Key? key}) : super(key: key);

  @override
  _VerifyPassState createState() => _VerifyPassState();
}

class _VerifyPassState extends State<VerifyPass> {
  final TextEditingController _newPasswordTextController = TextEditingController();
  final TextEditingController _confirmPasswordTextController = TextEditingController();

  bool _isObscure = true;


  @override
  Widget build(BuildContext context) {
    double baseWidth = 400;
    double sizeAxis = MediaQuery.of(context).size.width / baseWidth;
    double size = sizeAxis * 0.97;// Check if the user is already authenticated and their role

    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove debug banner
      home: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: Container(
              padding:
              EdgeInsets.fromLTRB(22 * sizeAxis, 200 * sizeAxis, 21 * sizeAxis, 130 * sizeAxis),
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xffffffff),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(0 * sizeAxis, 0 * sizeAxis, 105 * sizeAxis, 20 * sizeAxis),
                    child: Text(
                      'Verify Password',
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
                    margin: EdgeInsets.fromLTRB(0 * sizeAxis, 0 * sizeAxis, 20 * sizeAxis, 32 * sizeAxis),
                    constraints: BoxConstraints(
                      maxWidth: 307 * sizeAxis,
                    ),
                    child: Text(
                      'We will send you an email with a link to reset your password, please enter the email associated with your account below.',
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
                  Container(
                    margin: EdgeInsets.fromLTRB(1 * sizeAxis, 0 * sizeAxis, 0 * sizeAxis, 15 * sizeAxis),
                    width: 331 * sizeAxis,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8 * sizeAxis),
                      border: Border.all(color: const Color(0xffe8ecf4)),
                      color: const Color(0xfff7f8f9),
                    ),
                    child: TextField(
                      controller: _newPasswordTextController,
                      // Assign the text controller
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.fromLTRB(
                            18 * sizeAxis, 18 * sizeAxis, 18 * sizeAxis, 19 * sizeAxis),
                        hintText: 'Enter New your Password',
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
                    margin: EdgeInsets.fromLTRB(1 * sizeAxis, 0 * sizeAxis, 0 * sizeAxis, 15 * sizeAxis),
                    width: 331 * sizeAxis,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8 * sizeAxis),
                      border: Border.all(color: const Color(0xffe8ecf4)),
                      color: const Color(0xfff7f8f9),
                    ),
                    child: TextField(
                      controller: _confirmPasswordTextController,
                      // Assign the text controller
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.fromLTRB(
                            18 * sizeAxis, 18 * sizeAxis, 18 * sizeAxis, 19 * sizeAxis),
                        hintText: 'Confirm New your Password',
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
                    margin: EdgeInsets.fromLTRB(0 * sizeAxis, 50 * sizeAxis, 0 * sizeAxis, 150 * sizeAxis),
                    child: TextButton(
                      onPressed: () {
                        // _signIn();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const Login(),
                          ),
                        );
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
                            'Verify',
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
      ),
    );
  }
}