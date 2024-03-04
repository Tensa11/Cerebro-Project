import 'package:Cerebro/Cerebro/MainDash.dart';
import 'package:flutter/material.dart';

import 'AccountManage.dart';
import 'Home.dart';
import 'Login.dart';
import 'PatientManage.dart';

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
              accountName: Text(
                'Your Account Name',
                style: TextStyle(color: Colors.white), // Changed text color
              ),
              accountEmail: Text(
                'your_email@example.com',
                style: TextStyle(color: Colors.white), // Changed text color
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: ClipOval(
                  child: Image.asset(
                    'assets/logo/applogo.png', // Replace 'your_image.png' with the path to your image asset
                    width: 42.0, // Set the width of the image
                    height: 42.0, // Set the height of the image
                  ),
                ),
              ),
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
                    builder: (context) => MainDash(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.admin_panel_settings,
                color: const Color(0xffe33924), // Changed icon color
              ),
              title: const Text(
                'Users',
                style: TextStyle(
                  color: const Color(0xff231b53), // Changed text color
                ),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ManageAdmin(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.person,
                color: const Color(0xffe33924), // Changed icon color
              ),
              title: const Text(
                'Patients',
                style: TextStyle(
                  color: const Color(0xff231b53), // Changed text color
                ),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ManagePatient(),
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
                    barrierDismissible: false, // Set to false to prevent dialog dismissal on tap outside
                    builder: (context) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: const Color(0xffdfb153),
                        ),
                      );
                    },
                  );
                  Navigator.of(context).pushReplacement(  // Use pushReplacement to prevent going back to the previous screen
                    MaterialPageRoute(
                      builder: (context) => const Login(),
                    ),
                  );
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
