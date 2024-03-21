import 'package:Cerebro/Cerebro/ChangePass.dart';
import 'package:Cerebro/Cerebro/Sale.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Login.dart';
import 'Employee.dart';

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
    setState(() {}); // Update the UI with retrieved data
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
      child: Container(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(username),
              accountEmail: Text(email),
              currentAccountPicture: CircleAvatar(
                backgroundImage: AssetImage("assets/images/userCartoon.png"),
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
              title: const Text(
                'Home',
                style: TextStyle(
                  color: Color(0xFF13A4FF), // Changed text color
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
                Icons.person,
                color: const Color(0xffe33924), // Changed icon color
              ),
              title: const Text(
                'Physicians',
                style: TextStyle(
                  color: Color(0xFF13A4FF), // Changed text color
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
            ListTile(
              leading: const Icon(
                Icons.password,
                color: const Color(0xffe33924), // Changed icon color
              ),
              title: const Text(
                'Change Password',
                style: TextStyle(
                  color: Color(0xFF13A4FF), // Changed text color
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
            const Divider(),
            ListTile(
              leading: const Icon(
                Icons.logout,
                color: const Color(0xffe33924), // Changed icon color
              ),
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: Color(0xFF13A4FF), // Changed text color
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
