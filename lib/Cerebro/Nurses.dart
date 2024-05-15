import 'dart:convert';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:random_avatar/random_avatar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../util/utils.dart';
import 'Drawer.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:cryptography/cryptography.dart' as cryptography;
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class NursesPage extends StatefulWidget {
  const NursesPage({Key? key}) : super(key: key);

  @override
  _NursesPageState createState() => _NursesPageState();
}

class _NursesPageState extends State<NursesPage> {
  late List<Nurse> nurses = [];
  TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  final _pagingController = PagingController<int, Nurse>(
    firstPageKey: 1,
  );

  @override
  void initState() {
    super.initState();
    _getAvatarData();
    _getHospitalNameData();
    _getUserData();
    _pagingController.addPageRequestListener((pageKey) {
      if (searchController.text.isEmpty) {
        fetchNurses(page: pageKey);
      } else {
        searchNursesWithQuery(page: pageKey, query: searchController.text);
      }
    });
  }

  @override
  void dispose() {
    _pagingController.dispose();
    _debounce?.cancel();
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
  late String hospitalName = '';
  Future<void> _getHospitalNameData() async {
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
        String? hospital = data['data'][0]['hospital_name']; // Store the hospital name

        setState(() {
          hospitalName = hospital ?? ''; // If hospital name is null, assign an empty string
        });
      } else {
        throw Exception('Failed to load total _getHospitalData');
      }
    } catch (e) {
      print('Error fetching total _getHospitalData: $e');
      setState(() {});
    }
  }
  Future<void> _getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username') ?? '';
    setState(() {}); // Update the UI with retrieved data
  }

  Future<String> decryptData(String encryptedData) async {
    try {
      await dotenv.load();

      final String aesKey = dotenv.env['AES_KEY']!;

      List<int> buffer = base64.decode(encryptedData);

      List<int> salt = buffer.sublist(0, 64);
      List<int> iv = buffer.sublist(64, 80);
      List<int> data = buffer.sublist(96);
      cryptography.Mac tag = new cryptography.Mac(buffer.sublist(80, 96));

      cryptography.Pbkdf2 pbkdf2 = cryptography.Pbkdf2(
        macAlgorithm: cryptography.Hmac.sha512(),
        iterations:2122,
        bits: 256,
      );

      final KEY = crypto.sha512.convert(utf8.encode(aesKey)).toString().substring(0, 32);

      cryptography.SecretKey key = await pbkdf2.deriveKeyFromPassword(password: KEY, nonce: salt);

      List<int> decrypted = await cryptography.AesGcm.with256bits().decrypt(
          cryptography.SecretBox(data, nonce: iv, mac: tag), secretKey: new cryptography.SecretKey(await key.extractBytes())
      );

      return utf8.decode(decrypted);
    } catch (e) {
      print('Error decrypting data: $e');
      throw Exception('Error decrypting data');
    }
  }

  int page = 1; // Initialize page number

  Future<void> fetchNurses({int page = 1, String? query}) async {
    try {
      final apiUrl = dotenv.env['API_URL'];
      if (apiUrl == null) {
        throw Exception('API_URL environment variable is not defined');
      }
      var url = Uri.parse('$apiUrl/med/nurses?page=$page');

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final refreshToken = prefs.getString('refreshToken');

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
        var encryptedData = jsonDecode(response.body)['data'];
        var decryptedData = await decryptData(encryptedData);

        var data = json.decode(decryptedData);
        print('Nurses List Result: $data');

        List<Nurse> fetchedNurses = List.generate(data.length, (index) {
          return Nurse.fromJson(data[index]);
        });

        final isLastPage = fetchedNurses.isEmpty;
        if (isLastPage) {
          _pagingController.appendLastPage(fetchedNurses);
        } else {
          final nextPageKey = page + 1;
          _pagingController.appendPage(fetchedNurses, nextPageKey);
        }
      } else {
        _pagingController.error = Exception('Failed to load nurses');
      }
    } catch (e) {
      _pagingController.error = e;
    }
  }

  Future<void> searchNursesWithQuery({int page = 1, required String query}) async {
    try {
      final apiUrl = dotenv.env['API_URL'];
      if (apiUrl == null) {
        throw Exception('API_URL environment variable is not defined');
      }
      var url = Uri.parse('$apiUrl/med/nurses/search?page=$page&name=$query');

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final refreshToken = prefs.getString('refreshToken');

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
        var encryptedData = jsonDecode(response.body)['data'];
        var decryptedData = await decryptData(encryptedData);

        var data = json.decode(decryptedData);
        print('Nurses Search Result: $data');

        List<Nurse> fetchedNurses = List.generate(data.length, (index) {
          return Nurse.fromJson(data[index]);
        });

        final isLastPage = fetchedNurses.isEmpty;
        if (isLastPage) {
          _pagingController.appendLastPage(fetchedNurses);
        } else {
          final nextPageKey = page + 1;
          _pagingController.appendPage(fetchedNurses, nextPageKey);
        }
      } else {
        _pagingController.error = Exception('Failed to load nurses');
      }
    } catch (e) {
      _pagingController.error = e;
    }
  }

  Future<void> searchNurseResult(String query) async {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 2000), () {
      // Call the actual search function after a delay of 500 milliseconds
      _pagingController.refresh();
    });
  }


  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    double baseWidth = 375;
    double sizeAxis = MediaQuery.of(context).size.width / baseWidth;
    double size = sizeAxis * 0.97;

    return Scaffold(
      backgroundColor: Color(0xFF1497E8),
      key: _scaffoldKey,
      drawer: CereDrawer(),
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.transparent,
        elevation: 15,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white),
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
            color: Color(0xFF1497E8),
          ),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: LiquidPullToRefresh(
        onRefresh: _handleRefresh,
        color: Color(0xFF1497E8),
        height: 150,
        backgroundColor: Colors.redAccent,
        animSpeedFactor: 2,
        showChildOpacityTransition: false,
        child: Column(
          children: [
            SizedBox(height: 10,),
            // WELCOME! ----------------------------------------------------
            Padding(
              padding: EdgeInsets.only(right: 20.0, left: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nurses',
                    style: SafeGoogleFont(
                      'Urbanist',
                      fontSize: 20 * size,
                      fontWeight: FontWeight.bold,
                      height: 1.2 * size / sizeAxis,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'These are the list of Nurses in the $hospitalName',
                    style: SafeGoogleFont(
                      'Urbanist',
                      fontSize: 13 * size,
                      height: 1.2 * size / sizeAxis,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30.0),
            Container(
              margin: EdgeInsets.fromLTRB(1 * sizeAxis, 0 * sizeAxis,
                  0 * sizeAxis, 15 * sizeAxis),
              width: 325 * sizeAxis,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.white,
              ),
              child: TextField(
                controller: searchController,
                onChanged: (value) => searchNurseResult(value),
                style: TextStyle(
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  labelText: "Search",
                  labelStyle: SafeGoogleFont(
                    'Urbanist',
                    fontSize: 16 * size,
                    height: 1.2 * size / sizeAxis,
                    color: Colors.black,
                    fontStyle: FontStyle.italic,
                  ),
                  hintText: "Search for Nurses",
                  hintStyle: SafeGoogleFont(
                    'Urbanist',
                    fontSize: 16 * size,
                    height: 1.2 * size / sizeAxis,
                    color: Colors.black,
                    fontStyle: FontStyle.italic,
                  ),
                  prefixIcon: Icon(Icons.search, color: Colors.black,),
                  border: InputBorder.none,
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide.none),
                ),

              ),
            ),
            SizedBox(height: 10.0),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 30.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(75.0),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 25),
                    Expanded(
                      child: PagedListView<int, Nurse>(
                        pagingController: _pagingController,
                        builderDelegate: PagedChildBuilderDelegate<Nurse>(
                          itemBuilder: (context, nurse, index) => Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 3,
                            color: nurse.isActive == 1 ? Color(0xFF1497E8) : Color(0xFF858585),
                            child: ListTile(
                              // leading: Container(
                              //   decoration: BoxDecoration(
                              //     shape: BoxShape.circle,
                              //     border: Border.all(
                              //       color: Colors.white, // Border color
                              //       width: 2, // Border width
                              //     ),
                              //   ),
                              //   child: ClipOval(
                              //     child: RandomAvatar(
                              //       physician.doctorName,
                              //       height: 50,
                              //       width: 50,
                              //     ),
                              //   ),
                              // ),
                              leading: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white, // Border color
                                    width: 3, // Border width
                                  ),
                                ),
                                child: ClipOval(
                                  child: CircleAvatar(
                                    backgroundColor: Color(0xFF1497E8),
                                    radius: 23,
                                    child: Text(
                                      _getInitials(nurse.nurseName),
                                      style: SafeGoogleFont(
                                        'Urbanist',
                                        fontSize: 16 * size,
                                        height: 1.2 * size / sizeAxis,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(
                                nurse.nurseName,
                                style: SafeGoogleFont(
                                  'Urbanist',
                                  fontSize: 13 * size,
                                  height: 1.2 * size / sizeAxis,
                                  fontWeight: FontWeight.bold,
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
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          noItemsFoundIndicatorBuilder: (context) => Center(
                            child: Text('No nurses found.'),
                          ),
                          firstPageErrorIndicatorBuilder: (context) => Center(
                            child: Text('Error loading nurses.'),
                          ),
                          newPageErrorIndicatorBuilder: (context) => Center(
                            child: Text('Error loading more nurses.'),
                          ),
                          firstPageProgressIndicatorBuilder: (context) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: CircularProgressIndicator(color: Colors.black),
                            ),
                          ),
                          newPageProgressIndicatorBuilder: (context) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: CircularProgressIndicator(color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )


            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    await _getAvatarData();
    await _getHospitalNameData();
    await _getUserData();
    _pagingController.refresh();
    return await Future.delayed(Duration(seconds: 2));
  }

  String _getInitials(String name) {
    List<String> nameSplit = name.split(" ");
    String initials = "";
    for (var part in nameSplit) {
      if (part.isNotEmpty) {
        initials += part.substring(0, 1).toUpperCase();
      }
      if (initials.length == 2) {
        break;
      }
    }
    return initials;
  }
}

class Nurse {
  final String id;
  final int token;
  final String nurseName;
  final String license_number;
  final int isActive; // Change the type to int

  Nurse({
    required this.id,
    required this.token,
    required this.nurseName,
    required this.license_number,
    required this.isActive,
  });

  factory Nurse.fromJson(Map<String, dynamic> json) {
    return Nurse(
      id: json['id'] ?? '',
      token: json['token'] ?? 0,
      nurseName: json['nurse_name'],
      license_number: json['license_number'] ?? 'N/A',
      isActive: json['is_active'], // Update the type here
    );
  }
}