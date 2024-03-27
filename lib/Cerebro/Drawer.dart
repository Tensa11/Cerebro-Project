import 'package:Cerebro/Cerebro/ChangePass.dart';
import 'package:Cerebro/Cerebro/Physicians.dart';
import 'package:Cerebro/Cerebro/MainDash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Advisory.dart';
import 'Login.dart';
import '../util/utils.dart';
import 'Nurses.dart';


class CereDrawer extends StatefulWidget {
  const CereDrawer({Key? key}) : super(key: key);

  @override
  _CereDrawerState createState() => _CereDrawerState();
}

class _CereDrawerState extends State<CereDrawer> {
  String username = '';
  String email = '';

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username') ?? '';
    email = prefs.getString('email') ?? '';
     // Generate avatar URL based on username
    setState(() {}); // Update the UI with retrieved data
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 375;
    double sizeAxis = MediaQuery.of(context).size.width / baseWidth;
    double size = sizeAxis * 0.97;

    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
      child: Container(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(
                username,
                style: SafeGoogleFont(
                  'Urbanist',
                  fontSize: 15 * size,
                  height: 1.2 * size / sizeAxis,
                  color: const Color(0xFFFFFFFF),
                ),
              ),
              accountEmail: Text(email),
              currentAccountPicture: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white, // Border color
                    width: 2, // Border width
                  ),
                ),
                child: ClipOval(
                  child: RandomAvatar(
                    username,
                    height: 40,
                    width: 40,
                  ),
                ),
              ),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/bgg15.jpg"),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.dashboard,
                color: const Color(0xffe33924), // Changed icon color
              ),
              title: Text(
                'Home',
                style: SafeGoogleFont(
                  'Urbanist',
                  fontSize: 13 * size,
                  height: 1.2 * size / sizeAxis,
                  color: const Color(0xFF13A4FF),
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
            ListTile(
              leading: const Icon(
                Icons.newspaper,
                color: const Color(0xffe33924), // Changed icon color
              ),
              title: Text(
                'Advisory',
                style: SafeGoogleFont(
                  'Urbanist',
                  fontSize: 13 * size,
                  height: 1.2 * size / sizeAxis,
                  color: const Color(0xFF13A4FF),
                ),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => Advisory(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.person,
                color: const Color(0xffe33924), // Changed icon color
              ),
              title: Text(
                'Nurses',
                style: SafeGoogleFont(
                  'Urbanist',
                  fontSize: 13 * size,
                  height: 1.2 * size / sizeAxis,
                  color: const Color(0xFF13A4FF),
                ),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ManageNurses(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.person_add_alt_1,
                color: const Color(0xffe33924), // Changed icon color
              ),
              title: Text(
                'Physicians',
                style: SafeGoogleFont(
                  'Urbanist',
                  fontSize: 13 * size,
                  height: 1.2 * size / sizeAxis,
                  color: const Color(0xFF13A4FF),
                ),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ManagePhysicians(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.password,
                color: const Color(0xffe33924), // Changed icon color
              ),
              title: Text(
                'Change Password',
                style: SafeGoogleFont(
                  'Urbanist',
                  fontSize: 13 * size,
                  height: 1.2 * size / sizeAxis,
                  color: const Color(0xFF13A4FF),
                ),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ChangePass(),
                  ),
                );
              },
            ),
            // const Divider(),
            ListTile(
              leading: const Icon(
                Icons.logout,
                color: const Color(0xffe33924), // Changed icon color
              ),
              title: Text(
                'Logout',
                style: SafeGoogleFont(
                  'Urbanist',
                  fontSize: 13 * size,
                  height: 1.2 * size / sizeAxis,
                  color: const Color(0xFF13A4FF),
                ),
              ),
              onTap: () async {
                QuickAlert.show(
                  context: context,
                  type: QuickAlertType.confirm,
                  title: 'Confirm Logout',
                  text: 'Are you sure you want to log out?',
                  confirmBtnText: 'Logout',
                  cancelBtnText: 'Cancel',
                  confirmBtnColor: Theme.of(context).primaryColor, // Optional: Set button color
                  onConfirmBtnTap: () async {
                    try {
                      // Show loading indicator while logging out
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );

                      // Logout logic (clear shared preferences, etc.)
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.clear();

                      // Navigate to Login screen and pop the drawer
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const Login(),
                        ),
                      );
                      Navigator.pop(context); // Close the drawer

                      SystemNavigator.pop(); // Disable back button (optional)
                    } catch (e) {
                      print('Error logging out: $e');
                      // Handle errors (optional)
                    } finally {
                      // Hide loading indicator after logout is complete
                      Navigator.of(context, rootNavigator: true).pop();
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
