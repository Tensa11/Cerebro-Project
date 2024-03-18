import 'package:Cerebro/Cerebro/Login.dart';
import 'package:flutter/material.dart';
import '../util/utils.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    double baseWidth = 360;
    double size = MediaQuery.of(context).size.width / baseWidth;
    double sizes = size * 0.97;
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Stack(
          children: [
            Positioned(
              left: 0 * size,
              top: 0 * size,
              child: Container(
                width: 360 * size,
                height: 800 * size,
                decoration: const BoxDecoration(
                  color: Color(0xff19191c),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage(
                      'assets/images/bgg8.jpg',
                    ),
                  ),
                ),
                child: Center(
                  child: SizedBox(
                    width: double.infinity,
                    height: 800 * size,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0x66000000),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 27 * size,
              top: 136 * size,
              child: SizedBox(
                width: 206 * size,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(0 * size, 0 * size, 0 * size, 19 * size),
                      width: 142 * size,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Your content here
                        ],
                      ),
                    ),
                    Text(
                      'Cerebro',
                      style: SafeGoogleFont(
                        'Poppins',
                        fontSize: 20 * sizes,
                        fontWeight: FontWeight.w600,
                        height: 0.5365853659 * sizes / size,
                        letterSpacing: -0.4079999924 * size,
                        color: const Color(0xff0075ff),
                      ),
                    ),
                    SizedBox(height: 20 * size),
                    Text(
                      'Diagnostic',
                      style: SafeGoogleFont(
                        'Poppins',
                        fontSize: 35 * sizes,
                        fontWeight: FontWeight.w600,
                        height: 0.5365853659 * sizes / size,
                        letterSpacing: -0.4079999924 * size,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20 * size),
                    Text(
                      'System',
                      style: SafeGoogleFont(
                        'Poppins',
                        fontSize: 35 * sizes,
                        fontWeight: FontWeight.w600,
                        height: 0.5365853659 * sizes / size,
                        letterSpacing: -0.4079999924 * size,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10 * size),
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: 206 * size,
                      ),
                      child: Text(
                        'We are here to help you!',
                        style: SafeGoogleFont(
                          'Poppins',
                          fontSize: 13 * sizes,
                          fontWeight: FontWeight.w400,
                          height: 1.5 * sizes / size,
                          color: const Color(0xffffffff),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Login()),
          );
        },
        child: Icon(Icons.arrow_forward),
      ),
    );
  }
}
