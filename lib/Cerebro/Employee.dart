import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import '../util/utils.dart';
import 'Details.dart';
import 'Drawer.dart';

class ManageEmployee extends StatefulWidget {
  const ManageEmployee({Key? key}) : super(key: key);

  @override
  _ManageEmployeeState createState() => _ManageEmployeeState();
}

class _ManageEmployeeState extends State<ManageEmployee> {
  late List<Physician> physicians = [];
  final StreamController<bool> _streamController = StreamController<bool>();

  late List<Physician> filteredPhysicians;
  TextEditingController searchController = TextEditingController();

  late String dropdownValue = 'Alphabetical';

  @override
  void initState() {
    super.initState();
    fetchPhysicians();
    startListeningToChanges();
    filteredPhysicians = List.from(physicians); // Initialize with all physicians
    startListeningToChanges();
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  void startListeningToChanges() {
    Timer.periodic(Duration(seconds: 10), (timer) {
      // Check for database changes periodically
      fetchDataAndNotify(); // Fetch data and notify listeners
    });
  }

  void fetchDataAndNotify() async {
    try {
      await fetchPhysicians(); // Fetch total sales data
      _streamController.add(true); // Notify listeners about the change
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> fetchPhysicians() async {
    try {
      final apiUrl = dotenv.env['API_URL']; // Retrieve API URL from .env file
      if (apiUrl == null) {
        throw Exception('API_URL environment variable is not defined');
      }
      var url = Uri.parse('$apiUrl/med/physicians');
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

  Future<void>  filterSearchResults(String query) async {
    List<Physician> searchResults = physicians.where((physician) {
      return physician.doctorName.toLowerCase().contains(query.toLowerCase()) ||
          physician.specialty.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredPhysicians = searchResults;
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    double baseWidth = 375;
    double sizeAxis = MediaQuery.of(context).size.width / baseWidth;
    double size = sizeAxis * 0.97;

    if (physicians.isNotEmpty && filteredPhysicians.isEmpty) {
      filteredPhysicians = List.from(physicians); // Initialize with all physicians
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      key: _scaffoldKey,
      appBar: AppBar(
        // Set a custom height for the app bar
        toolbarHeight: 80,
        // Transparent background with gradient in flexible space
        backgroundColor: Colors.transparent,
        elevation: 15,
        // Remove default shadow
        leading: IconButton(
          icon: Icon(Icons.menu, color: Theme.of(context).colorScheme.tertiary),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, color: Theme.of(context).colorScheme.tertiary),
            onPressed: () {
              // Add functionality for account button
            },
          ),
        ],
        // Add a gradient background with rounded corners at the bottom
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      drawer: CereDrawer(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          children: [
            SizedBox(height: 30,),
            Container(
              margin: EdgeInsets.fromLTRB(
                  0 * sizeAxis, 20 * sizeAxis, 0 * sizeAxis, 0 * sizeAxis),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Physicians',
                    style: SafeGoogleFont(
                      'Urbanist',
                      fontSize: 18 * size,
                      fontWeight: FontWeight.bold,
                      height: 1.2 * size / sizeAxis,
                      color: const Color(0xFF13A4FF),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'List of Physicians in the database.',
                    style: SafeGoogleFont(
                      'Urbanist',
                      fontSize: 12 * size,
                      height: 1.2 * size / sizeAxis,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Container(
              margin: EdgeInsets.fromLTRB(1 * sizeAxis, 0 * sizeAxis,
                  0 * sizeAxis, 15 * sizeAxis),
              width: 331 * sizeAxis,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Theme.of(context).colorScheme.primary,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: Offset(0, 1), // changes position of shadow
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                onChanged: filterSearchResults,
                decoration: InputDecoration(
                  labelText: "Search",
                  hintText: "Search for Physicians",
                  prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.tertiary,),
                  border: InputBorder.none, // Remove the underline
                ),
              ),
            ),
            // Sort the ListView
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Sort",
                      style: SafeGoogleFont(
                        'Urbanist',
                        fontSize: 13 * size,
                        height: 1.2 * size / sizeAxis,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    DropdownButton<String>(
                      value: dropdownValue,
                      onChanged: (String? newValue) {
                        setState(() {
                          dropdownValue = newValue!;
                        });
                      },
                      items: <String>['Alphabetical', 'Status']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: filteredPhysicians.length,
                itemBuilder: (context, index) {
                  Physician physician = filteredPhysicians[index];
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
                      color: Theme.of(context).colorScheme.secondary,
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundImage: AssetImage('assets/images/userCartoon.png'),
                        ),
                        title: Text(
                          physician.doctorName,
                          style: SafeGoogleFont(
                            'Urbanist',
                            fontSize: 13 * size,
                            height: 1.2 * size / sizeAxis,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 5),
                            Text(
                              physician.specialty,
                              style: SafeGoogleFont(
                                'Inter',
                                fontSize: 11 * size,
                                height: 1.2 * size / sizeAxis,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        trailing: Icon(
                          physician.isActive ? Icons.check_circle : Icons.cancel,
                          color: physician.isActive ? Colors.green : Colors.red,
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