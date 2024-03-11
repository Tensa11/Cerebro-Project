import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../util/utils.dart';
import 'AddPatient.dart';
import 'Details.dart';
import 'Drawer.dart';
import 'appbar.dart';
import 'package:http/http.dart' as http;


class ManageEmployee extends StatefulWidget {
  const ManageEmployee({Key? key}) : super(key: key);

  @override
  _ManageEmployeeState createState() => _ManageEmployeeState();
}

class _ManageEmployeeState extends State<ManageEmployee> {
  late List<Physician> physicians = [];

  @override
  void initState() {
    super.initState();
    fetchPhysicians();
  }

  Future<void> fetchPhysicians() async {
    try {
      var url = Uri.parse('https://6b27-103-62-152-132.ngrok-free.app/physicians');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        List<Physician> fetchedPhysicians = List.generate(data['data'].length, (index) {
          return Physician.fromJson(data['data'][index]);
        });

        setState(() {
          physicians = fetchedPhysicians;
        });
      } else {
        throw Exception('Failed to load physicians');
      }
    } catch (e) {
      print('Error fetching physicians: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 375;
    double sizeAxis = MediaQuery.of(context).size.width / baseWidth;
    double size = sizeAxis * 0.97;

    return Scaffold(
      endDrawer: Drawer(
        child: CereDrawer(),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          children: [
            CustomAppBar(), // Replace the AppBar with the CustomAppBar
            Container(
              margin: EdgeInsets.fromLTRB(
                  0 * sizeAxis, 20 * sizeAxis, 0 * sizeAxis, 0 * sizeAxis),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Employee Management',
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
                itemCount: physicians.length,
                itemBuilder: (context, index) {
                  Physician physician = physicians[index];
                  return GestureDetector(
                    onTap: () {
                      // Navigate to the next page when a list item is tapped
                      // Navigator.of(context).push(
                      //   MaterialPageRoute(
                      //     builder: (context) => Details(),
                      //   ),
                      // );
                    },
                    child: Card(
                      elevation: 3,
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundImage: AssetImage('assets/images/userCartoon.png'),
                        ),
                        title: Text(
                          physician.doctorName,
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
                              physician.specialty,
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xff0272bc),
                                decoration: TextDecoration.none,
                              ),
                            ),
                            Text(
                              physician.isActive ? 'Active' : 'Inactive',
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
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.of(context).push(
      //       MaterialPageRoute(
      //         builder: (context) => const AddPatient(),
      //       ),
      //     );
      //   },
      //   backgroundColor: const Color(0xff1f375b),
      //   child: const Icon(
      //     Icons.add,
      //     color: Color(0xffe33924),
      //   ),
      // ),
    );
  }
}

class Physician {
  final String id;
  final int pin;
  final String doctorName;
  final String specialty;
  final bool isActive;

  Physician({
    required this.id,
    required this.pin,
    required this.doctorName,
    required this.specialty,
    required this.isActive,
  });

  factory Physician.fromJson(Map<String, dynamic> json) {
    return Physician(
      id: json['id'],
      pin: json['pin'],
      doctorName: json['doctor_name'],
      specialty: json['specialty'],
      isActive: json['is_active'],
    );
  }
}