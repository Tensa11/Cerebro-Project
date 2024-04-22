import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
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

class ManageNurses extends StatefulWidget {
  const ManageNurses({Key? key}) : super(key: key);

  @override
  _ManageNursesState createState() => _ManageNursesState();
}

class _ManageNursesState extends State<ManageNurses> {
  late List<Nurse> nurses = [];
  late String dropdownValue = 'Filter';

  late List<Nurse> filteredNurses;
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
    fetchNurses();
    _getAvatarData();
    filteredNurses = List.from(nurses); // Initialize with all nurses
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose scroll controller
    super.dispose();
  }

  String avatarUrl = '';
  String username = '';
  Future<void> _getAvatarData() async {
    try {
      final apiUrl = dotenv.env['API_URL']; // Retrieve API URL from .env file
      if (apiUrl == null) {
        throw Exception('API_URL environment variable is not defined');
      }
      var url = Uri.parse('$apiUrl/med/hospital/me');
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token'); // Assuming you saved the token with this key
      final refreshToken = prefs.getString('refreshToken'); // Assuming refresh token is stored separately

      if (token == null) {
        throw Exception('Token not found.');
      }
      var response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Cookie': 'refreshToken=$refreshToken',
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        String? avatar = data['avatar']; // Store the avatar URL

        setState(() {
          avatarUrl = avatar ?? ''; // If avatar is null, assign an empty string
        });
      } else {
        throw Exception('Failed to load total _getHospitalData');
      }
    } catch (e) {
      print('Error fetching total _getHospitalData: $e');
      setState(() {});
    }
  }

  Future<void> fetchNurses() async {
    try {
      final apiUrl = dotenv.env['API_URL']; // Retrieve API URL from .env file
      if (apiUrl == null) {
        throw Exception('API_URL environment variable is not defined');
      }
      var url = Uri.parse('$apiUrl/med/nurses');
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token'); // Assuming you saved the token with this key
      final refreshToken = prefs.getString('refreshToken'); // Assuming refresh token is stored separately

      if (token == null) {
        throw Exception('Token not found.');
      }
      var response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Cookie': 'refreshToken=$refreshToken',
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        List<Nurse> fetchedNurses = List.generate(data['data'].length, (index) {
          return Nurse.fromJson(data['data'][index]);
        });

        setState(() {
          nurses = fetchedNurses;
          // Update the filtered list with initial items
          filteredNurses = nurses.take(itemCountToShow).toList();
          currentItemCount = itemCountToShow;
          canLoadMore = true; // Reset canLoadMore flag
        });
      } else {
        throw Exception('Failed to load nurses');
      }
    } catch (e) {
      print('Error fetching nurses: $e');
    }
  }

  Future<void>  filterSearchResults(String query) async {
    List<Nurse> searchResults = nurses.where((nurse) {
      return nurse.nurseName.toLowerCase().contains(query.toLowerCase()) ||
          nurse.license_number.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredNurses = searchResults;
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    double baseWidth = 375;
    double sizeAxis = MediaQuery.of(context).size.width / baseWidth;
    double size = sizeAxis * 0.97;

    nurses.sort((a, b) => a.nurseName.compareTo(b.nurseName));

    if (nurses.isNotEmpty && filteredNurses.isEmpty) {
      filteredNurses = List.from(nurses); // Initialize with all nurses
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
                          child: Image.network(
                            avatarUrl,
                            fit: BoxFit.fill,
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
                    ? CachedNetworkImage(
                  imageUrl: avatarUrl,
                  height: 40,
                  width: 40,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Icon(Icons.local_hospital, size: 40), // Fallback icon when avatarUrl fails to load
                ) : Icon(Icons.local_hospital, size: 40), // Fallback icon when avatarUrl is empty
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
                    'Nurses',
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
                    'These are the list of Nurses in the database.',
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
                color: Theme.of(context).colorScheme.secondary,
              ),
              child: TextField(
                controller: searchController,
                onChanged: filterSearchResults,
                decoration: InputDecoration(
                  labelText: "Search",
                  hintText: "Search for Nurses",
                  labelStyle: TextStyle(color: Colors.white),
                  hintStyle: TextStyle(color: Colors.white),
                  prefixIcon: Icon(Icons.search, color: Colors.white,),
                  border: InputBorder.none, // Remove the underline
                ),
              ),
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
                  itemCount: filteredNurses.length + (isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == filteredNurses.length) {
                      return _buildLoadingIndicator(); // Show loading indicator at the end
                    } else {
                      Nurse nurse = filteredNurses[index];
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
                                  nurse.nurseName,
                                  height: 50,
                                  width: 50,
                                ),
                              ),
                            ),
                            title: Text(
                              nurse.nurseName,
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
                                  nurse.license_number,
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
                              nurse.isActive == 1 ? Icons.check_circle : Icons.cancel, // Update the comparison here
                              color: nurse.isActive == 1 ? Colors.green : Colors.red, // Update the comparison here
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
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

    if (currentItemCount < nurses.length) {
      int itemsToAdd = itemCountToShow;
      if (currentItemCount + itemCountToShow > nurses.length) {
        itemsToAdd = nurses.length - currentItemCount;
      }
      // Simulate a delay for loading more items
      Future.delayed(Duration(seconds: 3), () {
        setState(() {
          filteredNurses.addAll(nurses.getRange(currentItemCount, currentItemCount + itemsToAdd));
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

class Nurse {
  final String id;
  final int pin;
  final String nurseName;
  final String license_number;
  final int isActive; // Change the type to int

  Nurse({
    required this.id,
    required this.pin,
    required this.nurseName,
    required this.license_number,
    required this.isActive,
  });

  factory Nurse.fromJson(Map<String, dynamic> json) {
    return Nurse(
      id: json['id'] ?? '',
      pin: json['pin'] ?? 0,
      nurseName: json['nurse_name'],
      license_number: json['license_number'] ?? 'N/A',
      isActive: json['is_active'], // Update the type here
    );
  }
}
