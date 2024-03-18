import 'package:Cerebro/Cerebro/ChangePass.dart';
import 'package:Cerebro/Cerebro/MainDash.dart';
import 'package:Cerebro/Cerebro/Sale.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
                  color: Colors.blue, // Changed text color
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
                'Employee',
                style: TextStyle(
                  color: Colors.blue, // Changed text color
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
                  color: Colors.blue, // Changed text color
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
                  color: Colors.blue, // Changed text color
                ),
              ),
              onTap: () async {
                try {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: const Color(0xffdfb153),
                        ),
                      );
                    },
                  );
                  Navigator.of(context).pushReplacement(
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
