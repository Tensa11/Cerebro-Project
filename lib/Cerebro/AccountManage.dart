import 'package:flutter/material.dart';
import '../util/utils.dart';
import 'AddPatient.dart';
import 'Drawer.dart';

class AdminManage extends StatefulWidget {
  const AdminManage({Key? key}) : super(key: key);

  @override
  _AdminManageState createState() => _AdminManageState();
}

class _AdminManageState extends State<AdminManage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 375;
    double sizeAxis = MediaQuery.of(context).size.width / baseWidth;
    double size = sizeAxis * 0.97;

    return Scaffold(
      endDrawer: const Drawer(
        child: CereDrawer(),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: Container(
            padding: EdgeInsets.fromLTRB(24 * sizeAxis, 30 * sizeAxis, 24 * sizeAxis, 0 * sizeAxis),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xffffffff),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(0 * sizeAxis, 0 * sizeAxis, 0 * sizeAxis, 20 * sizeAxis),
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
                ),
                // Recent Payments ListView
                Container(
                  margin: EdgeInsets.fromLTRB(0 * sizeAxis, 20 * sizeAxis, 0 * sizeAxis, 13 * sizeAxis),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Management',
                        style: SafeGoogleFont(
                          'Urbanist',
                          fontSize: 18 * size,
                          fontWeight: FontWeight.w500,
                          height: 1.2 * size / sizeAxis,
                          color: const Color(0xff0272bc),
                          decoration: TextDecoration.none,
                        ),
                      ),
                      // ListView for Users
                      // Inside the ListView.builder
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 3,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                            elevation: 3,
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundImage: AssetImage('assets/images/userCartoon.png'),
                              ),
                              title: Text(
                                'Admin: Yusef',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xffe33924),
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 5),
                                  Text(
                                    'Hospital: Maria Reyna',
                                    style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xff0272bc),
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                  Text(
                                    'Address: Hayes St, CDO, Mis Or.',
                                    style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xff0272bc),
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                  Text(
                                    'Contact: 09361247859',
                                    style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xff0272bc),
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      // Trailing
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddPatient(),
            ),
          );
        },
        backgroundColor: const Color(0xff1f375b),
        child: const Icon(
          Icons.add,
          color: Color(0xffe33924),
        ),
      ),
    );
  }
}