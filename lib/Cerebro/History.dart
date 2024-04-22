import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../util/utils.dart';
import 'Drawer.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final StreamController<bool> _streamController = StreamController<bool>();

  @override
  void initState() {
    super.initState();
    _getUserData();
    _getHospitalNameData();
    _getAvatarData();
    startListeningToChanges();
    fetchHistorySales();
    fetchHistoryCash();
    fetchHistoryCheque();
    fetchHistoryExpense();
    fetchHistoryClaimAmount();
    fetchHistoryPF();
    //-----------------------------------------------------------------------
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }


  void startListeningToChanges() {
    Timer.periodic(Duration(seconds: 3), (timer) {
      // Check for database changes periodically
      fetchDataAndNotify(); // Fetch data and notify listeners
    });
  }

  void fetchDataAndNotify() async {
    try {
      await _getUserData();
      _getHospitalNameData();
      _getAvatarData();
      fetchHistorySales();
      fetchHistoryCash();
      fetchHistoryCheque();
      fetchHistoryExpense();
      fetchHistoryClaimAmount();
      fetchHistoryPF();
      _streamController.add(true); // Notify listeners about the change
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  late double historySales = 0;
  Future<void> fetchHistorySales() async {
    try {
      final apiUrl = dotenv.env['API_URL']; // Retrieve API URL from .env file
      if (apiUrl == null) {
        throw Exception('API_URL environment variable is not defined');
      }

      var url = Uri.parse('$apiUrl/fin/sales/history?date=$_selectedDate');

      // Retrieve the token from SharedPreferences
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
        var saleTotal = data['data'][0]['amount'];
        if (saleTotal is int || saleTotal is double) {
          historySales = saleTotal.toDouble();
        } else {
          historySales = 0.00; // Set to 0.00 if cashTotal is null or not a number
          throw Exception('totalSales value is neither int nor double');
        }
        setState(() {});
      } else {
        print('Failed to load fetchTotalSalesToday. Status code: ${response.statusCode}, Response body: ${response.body}');
        throw Exception('Failed to load fetchTotalSalesToday');
      }
    } catch (e) {
      print('Error fetching fetchTotalSalesToday: $e');
      setState(() {});
    }
  }

  late double historyCash = 0;
  Future<void> fetchHistoryCash() async {
    try {
      final apiUrl = dotenv.env['API_URL']; // Retrieve API URL from .env file
      if (apiUrl == null) {
        throw Exception('API_URL environment variable is not defined');
      }

      var url = Uri.parse('$apiUrl/fin/cashier/history?date=$_selectedDate');

      // Retrieve the token from SharedPreferences
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
        var cashTotal = data['data'][0]['cash'];
        if (cashTotal is int || cashTotal is double) {
          historyCash = cashTotal.toDouble();
        } else {
          historyCash = 0.00; // Set to 0.00 if cashTotal is null or not a number
          throw Exception('totalSales value is neither int nor double');
        }
        setState(() {});
      } else {
        print('Failed to load fetchHistoryCash. Status code: ${response.statusCode}, Response body: ${response.body}');
        throw Exception('Failed to load fetchHistoryCash');
      }
    } catch (e) {
      print('Error fetching fetchHistoryCash: $e');
      setState(() {});
    }
  }

  late double historyCheque = 0;
  Future<void> fetchHistoryCheque() async {
    try {
      final apiUrl = dotenv.env['API_URL']; // Retrieve API URL from .env file
      if (apiUrl == null) {
        throw Exception('API_URL environment variable is not defined');
      }

      var url = Uri.parse('$apiUrl/fin/cashier/history?date=$_selectedDate');

      // Retrieve the token from SharedPreferences
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
        var chequeTotal = data['data'][0]['cheque']; // Fetch cheque total
        if (chequeTotal is int || chequeTotal is double) {
          historyCheque = chequeTotal.toDouble();
        } else {
          historyCheque = 0.00; // Set to 0.00 if cashTotal is null or not a number
          throw Exception('totalSales value is neither int nor double');
        }
        setState(() {});
      } else {
        print('Failed to load fetchHistoryCheque. Status code: ${response.statusCode}, Response body: ${response.body}');
        throw Exception('Failed to load fetchHistoryCheque');
      }
    } catch (e) {
      print('Error fetching fetchHistoryCheque: $e');
      setState(() {});
    }
  }

  late double historyExpense = 0;
  Future<void> fetchHistoryExpense() async {
    try {
      final apiUrl = dotenv.env['API_URL']; // Retrieve API URL from .env file
      if (apiUrl == null) {
        throw Exception('API_URL environment variable is not defined');
      }
      var url = Uri.parse('$apiUrl/inv/items/expense/history?date=$_selectedDate');

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
          'Cookie': 'refreshToken=$refreshToken', // Include the token in the Authorization header
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        var expenseTotal = data['data'][0]['expense'];
        if (expenseTotal is int || expenseTotal is double) {
          historyExpense = expenseTotal.toDouble();
        } else {
          historyExpense = 0.00; // Set to 0.00 if cashTotal is null or not a number
          throw Exception('totalSales value is neither int nor double');
        }
        setState(() {});
      } else {
        throw Exception('Failed to load fetchTotalExpense');
      }
    } catch (e) {
      print('Error fetching fetchTotalExpense: $e');
      setState(() {});
    }
  }

  late int historyClaimCount = 0;
  late double historyClaimAmount = 0;
  Future<void> fetchHistoryClaimAmount() async {
    try {
      final apiUrl = dotenv.env['API_URL']; // Retrieve API URL from .env file
      if (apiUrl == null) {
        throw Exception('API_URL environment variable is not defined');
      }

      var url = Uri.parse('$apiUrl/fin/phic_transmittal/history?date=$_selectedDate&type=claim_amount');

      // Retrieve the token from SharedPreferences
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
        historyClaimCount = (data['data'][0]['count'] == null || data['data'][0]['count'] == 0) ? 0 : data['data'][0]['count'] as int;

        var claimTotal = data['data'][0]['amount'];
        if (claimTotal is int || claimTotal is double) {
          historyClaimAmount = claimTotal.toDouble();
        } else {
          historyClaimAmount = 0.00; // Set to 0.00 if cashTotal is null or not a number
          throw Exception('totalSales value is neither int nor double');
        }
        setState(() {});
      } else {
        print('Failed to load fetchTotalSalesToday. Status code: ${response.statusCode}, Response body: ${response.body}');
        throw Exception('Failed to load fetchTotalSalesToday');
      }
    } catch (e) {
      print('Error fetching fetchTotalSalesToday: $e');
      setState(() {});
    }
  }

  double calculateMaxValue(List<ChartData> dataSource) {
    return dataSource.map((data) => data.value).reduce(max);
  }

  late double historyPF = 0;
  Future<void> fetchHistoryPF() async {
    try {
      final apiUrl = dotenv.env['API_URL']; // Retrieve API URL from .env file
      if (apiUrl == null) {
        throw Exception('API_URL environment variable is not defined');
      }

      var url = Uri.parse('$apiUrl/fin/phic_transmittal/history?date=$_selectedDate&type=pf_amount');

      // Retrieve the token from SharedPreferences
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
        var pfTotal = data['data'][0]['amount'];
        if (pfTotal is int || pfTotal is double) {
          historyPF = pfTotal.toDouble();
        } else {
          historyPF = 0.00; // Set to 0.00 if cashTotal is null or not a number
          throw Exception('totalSales value is neither int nor double');
        }
        setState(() {});
      } else {
        print('Failed to load fetchTotalSalesToday. Status code: ${response.statusCode}, Response body: ${response.body}');
        throw Exception('Failed to load fetchTotalSalesToday');
      }
    } catch (e) {
      print('Error fetching fetchTotalSalesToday: $e');
      setState(() {});
    }
  }

  String formattedCurrentDate = DateFormat('MMM d, yyyy').format(DateTime.now()).toUpperCase();
  String formattedCurrentMonth = DateFormat('MMM yyyy').format(DateTime.now()).toUpperCase();
  String formattedCurrentYear = DateFormat('yyyy').format(DateTime.now()).toUpperCase();

  late String avatarUrl = '';
  late String username = '';
  late String hospitalName = '';
  Future<void> _getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username') ?? '';
    setState(() {}); // Update the UI with retrieved data
  }
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

  TextEditingController _dateController = TextEditingController();
  late String _selectedDate = "";
  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      _selectedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      fetchHistorySales(); // Fetch data with the new date
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    double baseWidth = 375;
    double sizeAxis = MediaQuery.of(context).size.width / baseWidth;
    double size = sizeAxis * 0.97;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      key: _scaffoldKey,
      drawer: CereDrawer(),
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
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Column(
              children: [
                SizedBox(height: 10,),
                // WELCOME! ----------------------------------------------------
                Padding(
                  padding: EdgeInsets.only(left: 30.0, right: 30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "History of $hospitalName",
                        style: SafeGoogleFont(
                          'Urbanist',
                          fontSize: 18 * size,
                          fontWeight: FontWeight.bold,
                          height: 1.2 * size / sizeAxis,
                          color: const Color(0xFFFFFFFF),
                        ),
                      ),
                      SizedBox(height: 30),
                      Container(
                        margin: EdgeInsets.fromLTRB(1 * sizeAxis, 0 * sizeAxis,
                            0 * sizeAxis, 15 * sizeAxis),
                        width: 331 * sizeAxis,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Theme.of(context).colorScheme.background,
                        ),
                        child: TextField(
                          controller: _dateController,
                          decoration: InputDecoration(
                            labelText: "Date",
                            labelStyle: TextStyle(color: Colors.white),
                            hintStyle: TextStyle(color: Colors.white),
                            prefixIcon: Icon(Icons.calendar_month, color: Colors.white,),
                            border: InputBorder.none,
                          ),
                          readOnly: true,
                          onTap: (){
                            _selectDate();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5.0),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(75.0)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(left: 30.0, right: 30.0),
                    child: SingleChildScrollView( // Wrap the Column in a SingleChildScrollView
                      child: Column(
                        children: [
                          SizedBox(height: 30),
                          Row(
                            children: [
                              Expanded(
                                child: Card(
                                  elevation: 5,
                                  color: Theme.of(context).colorScheme.secondary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        bottomRight: Radius.circular(40),
                                        topLeft: Radius.circular(40)
                                    ),
                                  ),
                                  child: Stack(children: [
                                    // Image.asset(
                                    //   'assets/images/bgg15.jpg',
                                    //   fit: BoxFit.cover,
                                    //   width: 360,
                                    //   height: 123,
                                    // ),
                                    Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Sales",
                                            style: SafeGoogleFont(
                                              'Urbanist',
                                              fontSize: 15 * size,
                                              height: 1.2 * size / sizeAxis,
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(height: 15),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '₱ ${NumberFormat('#,##0.00').format(historySales)}',
                                                  style: SafeGoogleFont(
                                                    'Inter',
                                                    fontSize: 17 * size,
                                                    fontWeight: FontWeight.w600,
                                                    height: 1.2 * size / sizeAxis,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                // SizedBox(height: 10),
                                                // Text(
                                                //   '$percentSales% Increase than before',
                                                //   style: SafeGoogleFont(
                                                //     'Urbanist',
                                                //     fontSize: 11 * size,
                                                //     height: 1.2 * size / sizeAxis,
                                                //     color: Colors.white,
                                                //   ),
                                                // ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ]),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Container(
                            margin: EdgeInsets.fromLTRB(
                                5 * sizeAxis, 10 * sizeAxis, 0 * sizeAxis, 0 * sizeAxis),
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Cashier Collection",
                                  style: SafeGoogleFont(
                                    'Urbanist',
                                    fontSize: 15 * size,
                                    fontWeight: FontWeight.bold,
                                    height: 1.2 * size / sizeAxis,
                                    color: const Color(0xFF13A4FF),
                                  ),
                                ),
                                SizedBox(height: 10),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 5,
                                  color: Theme.of(context).colorScheme.secondary,
                                  child: Stack(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Cash',
                                              style: SafeGoogleFont(
                                                'Urbanist',
                                                fontSize: 15 * size,
                                                height: 1.2 * size / sizeAxis,
                                                color: Colors.white,
                                              ),
                                            ),
                                            SizedBox(height: 10),
                                            SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '₱ ${NumberFormat('#,##0.00').format(historyCash)}',
                                                    style: SafeGoogleFont(
                                                      'Inter',
                                                      fontSize: 17 * size,
                                                      fontWeight: FontWeight.w600,
                                                      height: 1.2 * size / sizeAxis,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 5,
                                  color: Theme.of(context).colorScheme.secondary,
                                  child: Stack(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Cheque',
                                              style: SafeGoogleFont(
                                                'Urbanist',
                                                fontSize: 15 * size,
                                                height: 1.2 * size / sizeAxis,
                                                color: Colors.white,
                                              ),
                                            ),
                                            SizedBox(height: 10),
                                            SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '₱ ${NumberFormat('#,##0.00').format(historyCheque)}',
                                                    style: SafeGoogleFont(
                                                      'Inter',
                                                      fontSize: 17 * size,
                                                      fontWeight: FontWeight.w600,
                                                      height: 1.2 * size / sizeAxis,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Card(
                                  elevation: 5,
                                  color: Theme.of(context).colorScheme.secondary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        bottomRight: Radius.circular(40),
                                        topLeft: Radius.circular(40)
                                    ),
                                  ),
                                  child: Stack(children: [
                                    // Image.asset(
                                    //   'assets/images/bgg15.jpg',
                                    //   fit: BoxFit.cover,
                                    //   width: 360,
                                    //   height: 123,
                                    // ),
                                    Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Expense",
                                            style: SafeGoogleFont(
                                              'Urbanist',
                                              fontSize: 15 * size,
                                              height: 1.2 * size / sizeAxis,
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(height: 15),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '₱ ${NumberFormat('#,##0.00').format(historyExpense)}',
                                                  style: SafeGoogleFont(
                                                    'Inter',
                                                    fontSize: 17 * size,
                                                    fontWeight: FontWeight.w600,
                                                    height: 1.2 * size / sizeAxis,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                // SizedBox(height: 10),
                                                // Text(
                                                //   '$percentSales% Increase than before',
                                                //   style: SafeGoogleFont(
                                                //     'Urbanist',
                                                //     fontSize: 11 * size,
                                                //     height: 1.2 * size / sizeAxis,
                                                //     color: Colors.white,
                                                //   ),
                                                // ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ]),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        bottomRight: Radius.circular(40),
                                        topLeft: Radius.circular(40)
                                    ),
                                  ),
                                  elevation: 5,
                                  color: Theme.of(context).colorScheme.secondary,
                                  child: Stack(children: [
                                    // Image.asset(
                                    //   'assets/images/bgg15.jpg',
                                    //   fit: BoxFit.cover,
                                    //   width: 360,
                                    //   height: 117,
                                    // ),
                                    Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Today's PHIC Transmittal",
                                            style: SafeGoogleFont(
                                              'Urbanist',
                                              fontSize: 15 * size,
                                              height: 1.2 * size / sizeAxis,
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(height: 12),
                                          Divider(color: Colors.white),
                                          SizedBox(height: 12),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.square,
                                                color: Color(0xFF64B5F6),
                                                size: 15 * size,
                                              ),
                                              Text(
                                                ' Claim Amount',
                                                style: SafeGoogleFont(
                                                  'Urbanist',
                                                  fontSize: 15 * size,
                                                  height: 1.2 * size / sizeAxis,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.square,
                                                color: Color(0xFF1976D2),
                                                size: 15 * size,
                                              ),
                                              Text(
                                                ' PF',
                                                style: SafeGoogleFont(
                                                  'Urbanist',
                                                  fontSize: 15 * size,
                                                  height: 1.2 * size / sizeAxis,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Center(
                                            child: Container(
                                              width: 250,
                                              height: 250,
                                              child: SfCircularChart(
                                            palette: <Color>[Color(0xFF64B5F6), Color(0xFF1976D2)],
                                            series: <CircularSeries>[
                                              PieSeries<ChartData, String>(
                                                strokeWidth: 5,
                                                strokeColor: Colors.white,
                                                dataSource: <ChartData>[
                                                  ChartData('Total Claim Amount', historyClaimAmount),
                                                  ChartData('PF', historyPF),
                                                ],
                                                xValueMapper: (ChartData data, _) => data.name,
                                                yValueMapper: (ChartData data, _) => data.value,
                                                pointRadiusMapper: (ChartData data, _) {
                                                  double maxValue = calculateMaxValue([
                                                    ChartData('Total Claim Amount', historyClaimAmount),
                                                    ChartData('PF', historyPF),
                                                  ]);
                                                  double radiusPercentage = 40 + ((data.value / maxValue) * 40);
                                                  return radiusPercentage.toString() + '%';
                                                },
                                                dataLabelSettings: DataLabelSettings(
                                                  isVisible: true,
                                                  textStyle: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12 * size,
                                                    height: 1.2 * size / sizeAxis,
                                                    fontFamily: 'Urbanist',
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                dataLabelMapper: (ChartData data, _) {
                                                  // Format the value as currency
                                                  final NumberFormat currencyFormat = NumberFormat.currency(locale: 'en_PH', symbol: '₱');
                                                  return '${currencyFormat.format(data.value)}';
                                                },
                                                enableTooltip: true,
                                              ),
                                            ],
                                          ),

                                ),
                                          ),
                                          SizedBox(height: 13),
                                          SizedBox(height: 5),
                                          Row(
                                            children: [
                                              Text(
                                                'Total Claim Count: ',
                                                style: SafeGoogleFont(
                                                  'Urbanist',
                                                  fontSize: 15 * size,
                                                  height: 1.2 * size / sizeAxis,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              Text(
                                                '$historyClaimCount',
                                                style: SafeGoogleFont(
                                                  'Inter',
                                                  fontSize: 17 * size,
                                                  fontWeight: FontWeight.bold,
                                                  height: 1.2 * size / sizeAxis,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                'Total Claim Amount: ',
                                                style: SafeGoogleFont(
                                                  'Urbanist',
                                                  fontSize: 15 * size,
                                                  height: 1.2 * size / sizeAxis,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              Text(
                                                '₱ ${NumberFormat('#,##0.00').format(historyClaimAmount)}',
                                                style: SafeGoogleFont(
                                                  'Inter',
                                                  fontSize: 17 * size,
                                                  fontWeight: FontWeight.bold,
                                                  height: 1.2 * size / sizeAxis,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 10),
                                          Row(
                                            children: [
                                              Text(
                                                'PF: ',
                                                style: SafeGoogleFont(
                                                  'Urbanist',
                                                  fontSize: 15 * size,
                                                  height: 1.2 * size / sizeAxis,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              Text(
                                                '₱ ${NumberFormat('#,##0.00').format(historyPF)}',
                                                style: SafeGoogleFont(
                                                  'Inter',
                                                  fontSize: 17 * size,
                                                  fontWeight: FontWeight.bold,
                                                  height: 1.2 * size / sizeAxis,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ]),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChartData {
  ChartData(this.name, this.value);

  final String name;
  final double value;
}

class KPI {
  final int value; // Change the type to int
  final String statusType;
  final String units;

  KPI({
    required this.value,
    required this.statusType,
    required this.units
  });

  factory KPI.fromJson(Map<String, dynamic> json) {
    int value = json['value'];
    return KPI(
      value: value,
      statusType: json['status_type'],
      units: json['unit'],
    );
  }
}