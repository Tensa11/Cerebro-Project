import 'package:Cerebro/Cerebro/MainDash.dart';
import 'package:Cerebro/Cerebro/Sale.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'AccountManage.dart';
import 'Home.dart';
import 'Login.dart';
import 'Employee.dart';

class CereDrawer extends StatefulWidget {
  const CereDrawer({Key? key}) : super(key: key);

  @override
  _CereDrawerState createState() => _CereDrawerState();
}

class _CereDrawerState extends State<CereDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text("Admin Name"),
              accountEmail: Text("Email"),
              currentAccountPicture: CircleAvatar(
                backgroundImage: AssetImage("assets/images/userCartoon.png"),
              ),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    "assets/images/bgg2.jpg",
                  ),
                  fit: BoxFit.fill,
                ),
              ),
              // otherAccountsPictures: [
              //   CircleAvatar(
              //     backgroundColor: Colors.white,
              //     backgroundImage:  AssetImage(
              //         "assets/images/bgg1.jpg"),
              //   ),
              //   CircleAvatar(
              //     backgroundColor: Colors.white,
              //     backgroundImage:  AssetImage(
              //         "assets/images/bgg4.jpg"),
              //   ),
              // ],
            ),
            ListTile(
              leading: const Icon(
                Icons.dashboard,
                color: const Color(0xffe33924), // Changed icon color
              ),
              title: const Text(
                'Home',
                style: TextStyle(
                  color: const Color(0xff231b53), // Changed text color
                ),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SaleDash(),
                  ),
                );
              },
            ),
            // ListTile(
            //   leading: const Icon(
            //     Icons.admin_panel_settings,
            //     color: const Color(0xffe33924), // Changed icon color
            //   ),
            //   title: const Text(
            //     'Users',
            //     style: TextStyle(
            //       color: const Color(0xff231b53), // Changed text color
            //     ),
            //   ),
            //   onTap: () {
            //     Navigator.of(context).push(
            //       MaterialPageRoute(
            //         builder: (context) => ManageAdmin(),
            //       ),
            //     );
            //   },
            // ),
            ListTile(
              leading: const Icon(
                Icons.person,
                color: const Color(0xffe33924), // Changed icon color
              ),
              title: const Text(
                'Employee',
                style: TextStyle(
                  color: const Color(0xff231b53), // Changed text color
                ),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ManageEmployee(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(
                Icons.logout,
                color: const Color(0xffe33924), // Changed icon color
              ),
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: const Color(0xff231b53), // Changed text color
                ),
              ),
              onTap: () async {
                try {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    // Set to false to prevent dialog dismissal on tap outside
                    builder: (context) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: const Color(0xffdfb153),
                        ),
                      );
                    },
                  );
                  Navigator.of(context).pushReplacement(
                    // Use pushReplacement to prevent going back to the previous screen
                    MaterialPageRoute(
                      builder: (context) => const Login(),
                    ),
                  );
                  SystemNavigator.pop(); // Disable back button
                } catch (e) {
                  print('Error logging out: $e');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
