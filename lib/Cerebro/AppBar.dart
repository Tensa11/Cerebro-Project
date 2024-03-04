import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double baseWidth = 375;
    double sizeAxis = MediaQuery.of(context).size.width / baseWidth;
    double size = sizeAxis * 0.97;

    return Container(
      margin: EdgeInsets.fromLTRB(0 * sizeAxis, 30 * sizeAxis, 0 * sizeAxis, 0 * sizeAxis),
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(0 * sizeAxis, 0 * sizeAxis, 155 * sizeAxis, 0 * sizeAxis),
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
              ),
              child: Container(
                width: 115 * sizeAxis,
                height: 105 * sizeAxis,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24 * sizeAxis),
                  image: const DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage('assets/logo/appNameLogo.png'),
                  ),
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0 * sizeAxis, 20 * sizeAxis, 0 * sizeAxis, 20 * sizeAxis),
            child: Builder(
              builder: (context) => IconButton(
                icon: Image.asset(
                  'assets/images/drawer.png',
                  width: 25 * sizeAxis,
                  height: 18 * sizeAxis,
                ),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
