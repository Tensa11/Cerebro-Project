import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:random_avatar/random_avatar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../util/utils.dart';
import 'Details.dart';
import 'Drawer.dart';

class ManagePhysicians extends StatefulWidget {
  const ManagePhysicians({Key? key}) : super(key: key);

  @override
  _ManagePhysiciansState createState() => _ManagePhysiciansState();
}

class _ManagePhysiciansState extends State<ManagePhysicians> {
  late List<Physician> physicians = [];
  late String dropdownValue = 'Filter';

  late List<Physician> filteredPhysicians;
  TextEditingController searchController = TextEditingController();

  int itemCountToShow = 6; // Number of items to show initially
  int currentItemCount = 0;
  late bool canLoadMore = true; // Flag to indicate if more items can be loaded

  // Added scroll controller to maintain scroll position
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(); // Initialize scroll controller
    fetchPhysicians();
    _getUserData();
    filteredPhysicians = List.from(physicians); // Initialize with all physicians
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose scroll controller
    super.dispose();
  }

  Future<void> fetchPhysicians() async {
    try {
      final apiUrl = dotenv.env['API_URL']; // Retrieve API URL from .env file
      if (apiUrl == null) {
        throw Exception('API_URL environment variable is not defined');
      }
      var url = Uri.parse('$apiUrl/med/physicians');
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token'); // Assuming you saved the token with this key

      if (token == null) {
        throw Exception('Token not found.');
      }
      var response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token', // Include the token in the Authorization header
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        List<Physician> fetchedPhysicians = List.generate(data['data'].length, (index) {
          return Physician.fromJson(data['data'][index]);
        });

        setState(() {
          physicians = fetchedPhysicians;
          // Update the filtered list with initial items
          filteredPhysicians = physicians.take(itemCountToShow).toList();
          currentItemCount = itemCountToShow;
          canLoadMore = true; // Reset canLoadMore flag
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


  // Change this to Display all the Specialty in the dropdown and when selected only the selected specialty will be displayed in the listview.
  void applySorting(String selectedSpecialty) {
    if (selectedSpecialty == 'Filter') {
      // If 'Specialty' is selected, show all physicians
      setState(() {
        physicians.sort((a, b) => a.doctorName.compareTo(b.doctorName));
      });
    } else {
      // Filter physicians by the selected specialty
      List<Physician> specialtyFiltered = physicians.where((physician) {
        return physician.specialty == selectedSpecialty;
      }).toList();

      setState(() {
        filteredPhysicians = specialtyFiltered;
      });
    }
  }

  String avatarUrl = '';
  String username = '';
  Future<void> _getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username') ?? '';

    // Fetch the avatar URL
    final apiUrl = dotenv.env['API_URL']; // Retrieve API URL from .env file
    if (apiUrl == null) {
      throw Exception('API_URL environment variable is not defined');
    }
    var url = Uri.parse('$apiUrl/med/hospital/me');
    final token = prefs.getString('token'); // Assuming you saved the token with this key

    if (token == null) {
      throw Exception('Token not found.');
    }
    var response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token', // Include the token in the Authorization header
      },
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        avatarUrl = data['avatar']; // Store the avatar URL
      });
    } else {
      print('Failed to load user data');
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    double baseWidth = 375;
    double sizeAxis = MediaQuery.of(context).size.width / baseWidth;
    double size = sizeAxis * 0.97;

    physicians.sort((a, b) => a.doctorName.compareTo(b.doctorName));

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
        leading: IconButton(
          icon: Icon(Icons.menu, color: Theme.of(context).colorScheme.tertiary),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          GestureDetector(
            onTap: () async {
              if (avatarUrl.isNotEmpty) {
                await showDialog(
                  context: context,
                  builder: (_) => Dialog(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                icon: Icon(Icons.close_rounded),
                                color: Colors.redAccent,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 220,
                          height: 200,
                          child: Image.network(
                            avatarUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white, // Border color
                  width: 2, // Border width
                ),
              ),
              child: ClipOval(
                child: avatarUrl.isNotEmpty
                    ? Image.network(
                  avatarUrl,
                  height: 40,
                  width: 40,
                  fit: BoxFit.cover,
                )
                    : Container(), // Removed the fallback to RandomAvatar
              ),
            ),
          ),
          SizedBox(width: 20),
        ],
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
                    'These are the list of Physicians in the database.',
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
            SizedBox(height: 15),
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
                          applySorting(newValue); // Apply sorting when dropdown value changes
                        });
                      },
                      items: <String>['Filter', ...physicians.map((physician) => physician.specialty).toSet().toList()]
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
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                    // Reached the bottom of the ListView
                    loadMoreItems();
                  }
                  return true;
                },
                child: ListView.builder(
                  itemCount: filteredPhysicians.length + (isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == filteredPhysicians.length) {
                      return _buildLoadingIndicator(); // Show loading indicator at the end
                    } else {
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 3,
                          color: Theme.of(context).colorScheme.secondary,
                          child: ListTile(
                            leading: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white, // Border color
                                  width: 2, // Border width
                                ),
                              ),
                              child: ClipOval(
                                child: RandomAvatar(
                                  physician.doctorName,
                                  height: 50,
                                  width: 50,
                                ),
                              ),
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
                              physician.isActive == 1 ? Icons.check_circle : Icons.cancel, // Update the comparison here
                              color: physician.isActive == 1 ? Colors.green : Colors.red, // Update the comparison here
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),

              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: CircularProgressIndicator(color: Theme.of(context).colorScheme.tertiary,), // Show CircularProgressIndicator while loading
      ),
    );
  }

  bool isLoading = false; // Add isLoading flag

  void loadMoreItems() {
    setState(() {
      isLoading = true; // Set isLoading flag to true
    });

    if (currentItemCount < physicians.length) {
      int itemsToAdd = itemCountToShow;
      if (currentItemCount + itemCountToShow > physicians.length) {
        itemsToAdd = physicians.length - currentItemCount;
      }
      // Simulate a delay for loading more items
      Future.delayed(Duration(seconds: 3), () {
        setState(() {
          filteredPhysicians.addAll(physicians.getRange(currentItemCount, currentItemCount + itemsToAdd));
          currentItemCount += itemsToAdd;
          isLoading = false; // Set isLoading flag to false after loading
        });
      });
    } else {
      setState(() {
        isLoading = false; // Set isLoading flag to false if no more items to load
      });
    }
  }

}

class Physician {
  final String id;
  final int pin;
  final String doctorName;
  final String specialty;
  final int isActive; // Change the type to int

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
      isActive: json['is_active'], // Update the type here
    );
  }
}
