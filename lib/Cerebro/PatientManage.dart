import 'package:flutter/material.dart';
import '../util/utils.dart';
import 'AddPatient.dart';
import 'Details.dart';
import 'Drawer.dart';
import 'appbar.dart'; // Import the custom app bar

class ManagePatient extends StatefulWidget {
  const ManagePatient({Key? key}) : super(key: key);

  @override
  _ManagePatientState createState() => _ManagePatientState();
}

class _ManagePatientState extends State<ManagePatient> {
  @override
  Widget build(BuildContext context) {
    double baseWidth = 375;
    double sizeAxis = MediaQuery.of(context).size.width / baseWidth;
    double size = sizeAxis * 0.97;

    return Scaffold(
      endDrawer: const Drawer(
        child: CereDrawer(),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          children: [
            CustomAppBar(), // Replace the AppBar with the CustomAppBar
            Container(
              margin: EdgeInsets.fromLTRB(
                  0 * sizeAxis, 40 * sizeAxis, 0 * sizeAxis, 0 * sizeAxis),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Patient Management',
                    style: SafeGoogleFont(
                      'Urbanist',
                      fontSize: 18 * size,
                      fontWeight: FontWeight.w500,
                      height: 1.2 * size / sizeAxis,
                      color: const Color(0xff0272bc),
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      // Navigate to the next page when a list item is tapped
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => Details(),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 3,
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundImage:
                              AssetImage('assets/images/userCartoon.png'),
                        ),
                        title: Text(
                          'Name: John Doe',
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
                              'Room: 207',
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xff0272bc),
                                decoration: TextDecoration.none,
                              ),
                            ),
                            Text(
                              'Doctor: Dr. Darth',
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xff0272bc),
                                decoration: TextDecoration.none,
                              ),
                            ),
                            Text(
                              'Status: Discharged',
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
                    ),
                  );
                },
              ),
            ),
          ],
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
