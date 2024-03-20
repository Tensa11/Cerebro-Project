import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../util/utils.dart';
import 'Drawer.dart';
import 'package:http/http.dart' as http;

class SaleDash extends StatefulWidget {
  const SaleDash({Key? key}) : super(key: key);

  @override
  _SaleDashState createState() => _SaleDashState();
}

class _SaleDashState extends State<SaleDash> {
  late double totalCash = 0;
  late double totalCheque = 0;
  late double totalSales = 0;
  late double totalExpense = 0;
  late double totalDisbursement = 0;
  late int totalIPD = 0;
  late int totalOPD = 0;
  late int totalPHIC = 0;
  late int totalHMO = 0;
  late int totalCOMPANY = 0;
  late int totalSENIOR = 0;
  late List<Insurance> insuranceTODAY = [];
  late double totalInsuranceMONTH = 0;
  late int totalClaimCount = 0;
  late double totalClaimAmount = 0;
  late int percentSales = 0;
  late int percentCheque = 0;
  late int percentCash = 0;
  late int percentInsurance = 0;

  final StreamController<bool> _streamController = StreamController<bool>();
  bool _isQuickAlertShown = false;

  @override
  void initState() {
    super.initState();
    fetchTotalSalesToday();
    fetchTotalExpense();
    fetchTotalCollection();
    fetchTotalDisbursement();
    fetchSalesMonthChart();
    fetchSalesYearChart();
    fetchTotalIPD();
    fetchTotalOPD();
    fetchTotalPHIC();
    fetchTotalHMO();
    fetchTotalCOMPANY();
    fetchTotalSENIOR();
    fetchInsuranceTODAY();
    fetchInsuranceMONTH();
    startListeningToChanges();
    fetchPHICTransmittalTODAY();
    fetchPHICTransmittalMONTH();
    _getUserData();
    fetchPercentSalesToday();
    fetchPercentCollection();
    fetchPercentInsuranceTODAY();
    // ----------------------------------------------------
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool hasShownAlert = prefs.getBool('hasShownQuickAlert') ?? false;

      if (!hasShownAlert && !_isQuickAlertShown) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: "Welcome $username",
          text: "This are the Data's for today.",
          confirmBtnColor: Color(0xFF13A4FF),
          headerBackgroundColor: Color(0xFF13A4FF),
        );
        setState(() {
          _isQuickAlertShown = true;
        });
        await prefs.setBool('hasShownQuickAlert', true);
      }
    });
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
      await fetchTotalSalesToday();
      await fetchTotalExpense();
      await fetchTotalCollection();
      await fetchTotalDisbursement();
      await fetchSalesMonthChart();
      await fetchSalesYearChart();
      await fetchTotalIPD();
      await fetchTotalOPD();
      await fetchTotalPHIC();
      await fetchTotalHMO();
      await fetchTotalCOMPANY();
      await fetchTotalSENIOR();
      await fetchInsuranceTODAY();
      await fetchInsuranceMONTH();
      await fetchPHICTransmittalTODAY();
      await fetchPHICTransmittalMONTH();
      await fetchPercentSalesToday();
      await fetchPercentCollection();
      await fetchPercentInsuranceTODAY(); // Fetch total sales data
      _streamController.add(true); // Notify listeners about the change
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> fetchTotalSalesToday() async {
    try {
      final apiUrl = dotenv.env['API_URL']; // Retrieve API URL from .env file
      if (apiUrl == null) {
        throw Exception('API_URL environment variable is not defined');
      }
      var url = Uri.parse('$apiUrl/fin/sales/total/today');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        totalSales = double.parse(data['data'][0]['total'].toString());
        // Update the UI to reflect the fetched total sales
        setState(() {});
      } else {
        throw Exception('Failed to load fetchTotalSalesToday');
      }
    } catch (e) {
      print('Error fetching fetchTotalSalesToday: $e');
      // Handle the error, for example, show an error message to the user
      setState(() {});
    }
  }

  Future<void> fetchPercentSalesToday() async {
    try {
      final apiUrl = dotenv.env['API_URL']; // Retrieve API URL from .env file
      if (apiUrl == null) {
        throw Exception('API_URL environment variable is not defined');
      }
      var url = Uri.parse('$apiUrl/fin/sales/total/today/percentage');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        percentSales = int.parse(data['data'][0]['amount']);
        setState(() {});
      } else {
        throw Exception('Failed to load fetchPercentSalesToday');
      }
    } catch (e) {
      print('Error fetching total fetchPercentSalesToday: $e');
      setState(() {});
    }
  }

  Future<void> fetchTotalCollection() async {
    try {
      final apiUrl = dotenv.env['API_URL']; // Retrieve API URL from .env file
      if (apiUrl == null) {
        throw Exception('API_URL environment variable is not defined');
      }
      var url = Uri.parse('$apiUrl/fin/cashier/collection/today');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        totalCash = double.parse(data['data']['cash'][0]['total']);
        totalCheque = double.parse(data['data']['cheque'][0]['total']);
        setState(() {});
      } else {
        throw Exception('Failed to load fetchTotalCollection');
      }
    } catch (e) {
      print('Error fetching fetchTotalCollection: $e');
      setState(() {});
    }
  }

  Future<void> fetchPercentCollection() async {
    try {
      final apiUrl = dotenv.env['API_URL']; // Retrieve API URL from .env file
      if (apiUrl == null) {
        throw Exception('API_URL environment variable is not defined');
      }
      var url = Uri.parse('$apiUrl/fin/cashier/collection/percentage');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        percentCash = data['data']['percentageCash'];
        percentCheque = data['data']['percentageCheque'];
        setState(() {});
      } else {
        throw Exception('Failed to load fetchPercentCollection');
      }
    } catch (e) {
      print('Error fetching fetchPercentCollection: $e');
      setState(() {});
    }
  }

  List<SalesMonthData> _chartMonthData = [];
  final List<String> dayNames =
      List.generate(31, (index) => (index + 1).toString());

  Future<void> fetchSalesMonthChart() async {
    try {
      final apiUrl = dotenv.env['API_URL']; // Retrieve API URL from .env file
      if (apiUrl == null) {
        throw Exception('API_URL environment variable is not defined');
      }
      var url = Uri.parse('$apiUrl/fin/sales/total/month');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        List<SalesMonthData> salesMonthData =
            List.generate(data['data'].length, (index) {
          String dayName = dayNames[data['data'][index]['day'] - 1];
          return SalesMonthData(
            dayName,
            double.parse(data['data'][index]['amount']),
          );
        });

        salesMonthData.sort(
            (a, b) => int.parse(a.dayName).compareTo(int.parse(b.dayName)));

        setState(() {
          _chartMonthData = salesMonthData;
        });
      } else {
        throw Exception('Failed to load fetchSalesMonthChart');
      }
    } catch (e) {
      print('Error fetching fetchSalesMonthChart: $e');
      setState(() {
        // Handle error state if needed
      });
    }
  }

  Future<void> fetchTotalExpense() async {
    try {
      final apiUrl = dotenv.env['API_URL']; // Retrieve API URL from .env file
      if (apiUrl == null) {
        throw Exception('API_URL environment variable is not defined');
      }
      var url = Uri.parse('$apiUrl/inv/items/expense/today');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        totalExpense = double.parse(data['data'][0]['expense']);
        setState(() {});
      } else {
        throw Exception('Failed to load fetchTotalExpense');
      }
    } catch (e) {
      print('Error fetching fetchTotalExpense: $e');
      setState(() {});
    }
  }

  Future<void> fetchTotalDisbursement() async {
    try {
      final apiUrl = dotenv.env['API_URL']; // Retrieve API URL from .env file
      if (apiUrl == null) {
        throw Exception('API_URL environment variable is not defined');
      }
      var url = Uri.parse('$apiUrl/fin/disbursement/total');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        totalDisbursement = double.parse(data['data'][0]['total']);
        setState(() {});
      } else {
        throw Exception('Failed to load fetchTotalDisbursement');
      }
    } catch (e) {
      print('Error fetching fetchTotalDisbursement: $e');
      setState(() {});
    }
  }

  List<SalesYearData> _chartYearData = [];
  final List<String> monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  Future<void> fetchSalesYearChart() async {
    try {
      final apiUrl = dotenv.env['API_URL']; // Retrieve API URL from .env file
      if (apiUrl == null) {
        throw Exception('API_URL environment variable is not defined');
      }
      var url = Uri.parse('$apiUrl/fin/sales/total/year');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        List<SalesYearData> salesYearData =
            List.generate(data['data'].length, (index) {
          String monthName = monthNames[data['data'][index]['month'] - 1];
          return SalesYearData(
            monthName,
            double.parse(data['data'][index]['amount']),
          );
        });

        setState(() {
          // Update the state with the fetched salesData
          _chartYearData = salesYearData;
        });
      } else {
        throw Exception('Failed to load fetchSalesYearChart');
      }
    } catch (e) {
      print('Error fetching fetchSalesYearChart: $e');
      setState(() {
        // Handle error state if needed
      });
    }
  }

  Future<void> fetchTotalIPD() async {
    try {
      final apiUrl = dotenv.env['API_URL']; // Retrieve API URL from .env file
      if (apiUrl == null) {
        throw Exception('API_URL environment variable is not defined');
      }
      var url = Uri.parse('$apiUrl/med/patients/ipd');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        totalIPD = int.parse(data['data'][0]['count']);
        setState(() {});
      } else {
        throw Exception('Failed to load fetchTotalIPD');
      }
    } catch (e) {
      print('Error fetching fetchTotalIPD: $e');
      setState(() {});
    }
  }

  Future<void> fetchTotalOPD() async {
    try {
      final apiUrl = dotenv.env['API_URL']; // Retrieve API URL from .env file
      if (apiUrl == null) {
        throw Exception('API_URL environment variable is not defined');
      }
      var url = Uri.parse('$apiUrl/med/patients/opd');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        totalOPD = int.parse(data['data'][0]['count']);
        setState(() {});
      } else {
        throw Exception('Failed to load fetchTotalOPD');
      }
    } catch (e) {
      print('Error fetching fetchTotalOPD: $e');
      setState(() {});
    }
  }

  Future<void> fetchTotalPHIC() async {
    try {
      final apiUrl = dotenv.env['API_URL']; // Retrieve API URL from .env file
      if (apiUrl == null) {
        throw Exception('API_URL environment variable is not defined');
      }
      var url = Uri.parse('$apiUrl/med/patients/phic');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        totalPHIC = int.parse(data['data'][0]['count']);
        setState(() {});
      } else {
        throw Exception('Failed to load fetchTotalPHIC');
      }
    } catch (e) {
      print('Error fetching fetchTotalPHIC: $e');
      setState(() {});
    }
  }

  Future<void> fetchTotalHMO() async {
    try {
      final apiUrl = dotenv.env['API_URL']; // Retrieve API URL from .env file
      if (apiUrl == null) {
        throw Exception('API_URL environment variable is not defined');
      }
      var url = Uri.parse('$apiUrl/med/patients/hmo');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        totalHMO = int.parse(data['data'][0]['count']);
        setState(() {});
      } else {
        throw Exception('Failed to load fetchTotalHMO');
      }
    } catch (e) {
      print('Error fetching fetchTotalHMO: $e');
      setState(() {});
    }
  }

  Future<void> fetchTotalCOMPANY() async {
    try {
      final apiUrl = dotenv.env['API_URL']; // Retrieve API URL from .env file
      if (apiUrl == null) {
        throw Exception('API_URL environment variable is not defined');
      }
      var url = Uri.parse('$apiUrl/med/patients/company');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        totalCOMPANY = int.parse(data['data'][0]['count']);
        setState(() {});
      } else {
        throw Exception('Failed to load fetchTotalCOMPANY');
      }
    } catch (e) {
      print('Error fetching fetchTotalCOMPANY: $e');
      setState(() {});
    }
  }

  Future<void> fetchTotalSENIOR() async {
    try {
      final apiUrl = dotenv.env['API_URL']; // Retrieve API URL from .env file
      if (apiUrl == null) {
        throw Exception('API_URL environment variable is not defined');
      }
      var url = Uri.parse('$apiUrl/med/patients/srpwd');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        totalSENIOR = int.parse(data['data'][0]['count']);
        setState(() {});
      } else {
        throw Exception('Failed to load fetchTotalSENIOR');
      }
    } catch (e) {
      print('Error fetching fetchTotalSENIOR: $e');
      setState(() {});
    }
  }

  Future<void> fetchInsuranceTODAY() async {
    try {
      final apiUrl = dotenv.env['API_URL']; // Retrieve API URL from .env file
      if (apiUrl == null) {
        throw Exception('API_URL environment variable is not defined');
      }
      var url = Uri.parse('$apiUrl/fin/insurance/today');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        List<Insurance> fetchedInsuranceToday =
            List.generate(data['data'].length, (index) {
          return Insurance.fromJson(data['data'][index]);
        });

        setState(() {
          insuranceTODAY = fetchedInsuranceToday;
        });
      } else {
        throw Exception('Failed to load fetchInsuranceTODAY');
      }
    } catch (e) {
      print('Error fetching fetchInsuranceTODAY: $e');
    }
  }

  Future<void> fetchPercentInsuranceTODAY() async {
    try {
      final apiUrl = dotenv.env['API_URL']; // Retrieve API URL from .env file
      if (apiUrl == null) {
        throw Exception('API_URL environment variable is not defined');
      }
      var url = Uri.parse('$apiUrl/fin/insurance/today/percentage');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        percentInsurance = data['data']['today'];
        setState(() {});
      } else {
        throw Exception('Failed to load fetchPercentInsuranceTODAY');
      }
    } catch (e) {
      print('Error fetching fetchPercentInsuranceTODAY: $e');
      setState(() {});
    }
  }

  Future<void> fetchInsuranceMONTH() async {
    try {
      final apiUrl = dotenv.env['API_URL']; // Retrieve API URL from .env file
      if (apiUrl == null) {
        throw Exception('API_URL environment variable is not defined');
      }
      var url = Uri.parse('$apiUrl/fin/insurance/month');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        totalInsuranceMONTH = double.parse(data['data'][0]['amount']);
        setState(() {});
      } else {
        throw Exception('Failed to load total fetchInsuranceMONTH');
      }
    } catch (e) {
      print('Error fetching total fetchInsuranceMONTH: $e');
      setState(() {});
    }
  }

  Future<void> fetchPHICTransmittalTODAY() async {
    try {
      final apiUrl = dotenv.env['API_URL']; // Retrieve API URL from .env file
      if (apiUrl == null) {
        throw Exception('API_URL environment variable is not defined');
      }
      var url = Uri.parse('$apiUrl/fin/phic_transmittal/today');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          totalClaimCount = data['data'][0]['claim_count'] as int;
          totalClaimAmount = double.parse(data['data'][0]['claim_amount']);
        });
      } else {
        throw Exception('Failed to load fetchPHICTransmittalTODAY');
      }
    } catch (e) {
      print('Error fetching fetchPHICTransmittalTODAY: $e');
    }
  }

  List<TransMonthData> _chartMonthTransData = [];
  final List<String> dayTransNames =
      List.generate(31, (index) => (index + 1).toString());

  Future<void> fetchPHICTransmittalMONTH() async {
    try {
      final apiUrl = dotenv.env['API_URL']; // Retrieve API URL from .env file
      if (apiUrl == null) {
        throw Exception('API_URL environment variable is not defined');
      }
      var url = Uri.parse('$apiUrl/fin/phic_transmittal/month');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        List<TransMonthData> transMonthData =
            List.generate(data['data'].length, (index) {
          int days = data['data'][index]['days'];
          String dayName = days.toString(); // Convert days to string
          return TransMonthData(
            dayName,
            double.parse(data['data'][index]['amount']),
          );
        });

        // Sort the list based on the dayName
        transMonthData.sort(
            (a, b) => int.parse(a.dayName).compareTo(int.parse(b.dayName)));

        setState(() {
          _chartMonthTransData = transMonthData;
        });
      } else {
        throw Exception('Failed to load fetchPHICTransmittalMONTH');
      }
    } catch (e) {
      print('Error fetching fetchPHICTransmittalMONTH: $e');
      setState(() {
        // Handle error state if needed
      });
    }
  }

  String formattedCurrentDate =
      DateFormat('MMM d, yyyy').format(DateTime.now()).toUpperCase();
  String formattedCurrentMonth =
      DateFormat('MMM yyyy').format(DateTime.now()).toUpperCase();
  String formattedCurrentYear =
      DateFormat('yyyy').format(DateTime.now()).toUpperCase();

  String username = '';

  Future<void> _getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username') ?? '';
    setState(() {}); // Update the UI with retrieved data
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    double baseWidth = 375;
    double sizeAxis = MediaQuery.of(context).size.width / baseWidth;
    double size = sizeAxis * 0.97;

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
            icon: Icon(Icons.search,
                color: Theme.of(context).colorScheme.tertiary),
            onPressed: () {
              // Add functionality for search button
            },
          ),
          IconButton(
            icon: Icon(Icons.account_circle,
                color: Theme.of(context).colorScheme.tertiary),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            children: [
              SizedBox(height: 20),
              // CustomAppBar(),
              // WELCOME Text
              Container(
                margin: EdgeInsets.fromLTRB(
                    0 * sizeAxis, 20 * sizeAxis, 0 * sizeAxis, 0 * sizeAxis),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back! $username',
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
                      'latest update for the last 7 days.',
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
              // Sales of the day
              Row(
                children: [
                  Expanded(
                    child: Card(
                      elevation: 5,
                      color: Theme.of(context).colorScheme.secondary,
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
                                "Today's Total Sales",
                                style: SafeGoogleFont(
                                  'Urbanist',
                                  fontSize: 15 * size,
                                  height: 1.2 * size / sizeAxis,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 15),
                              Text(
                                '₱ ${NumberFormat('#,##0.00').format(totalSales)}',
                                style: SafeGoogleFont(
                                  'Inter',
                                  fontSize: 17 * size,
                                  fontWeight: FontWeight.w600,
                                  height: 1.2 * size / sizeAxis,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                '$percentSales% Increase than before',
                                style: SafeGoogleFont(
                                  'Urbanist',
                                  fontSize: 11 * size,
                                  height: 1.2 * size / sizeAxis,
                                  color: Colors.white,
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
              // Cheque and Cash of the day
              Row(
                children: [
                  Expanded(
                    child: Card(
                      elevation: 5,
                      color: Theme.of(context).colorScheme.secondary,
                      child: Stack(children: [
                        // Image.asset(
                        //   'assets/images/bgg15.jpg',
                        //   fit: BoxFit.cover,
                        //   width: 360,
                        //   height: 190,
                        // ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Today's Collection",
                                style: SafeGoogleFont(
                                  'Urbanist',
                                  fontSize: 15 * size,
                                  height: 1.2 * size / sizeAxis,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 15),
                              Row(
                                children: [
                                  Icon(
                                    Icons.attach_money,
                                    color: Colors.white,
                                  ),
                                  // Icon for the first collection
                                  SizedBox(width: 10),
                                  // Adjust spacing between icon and text
                                  Expanded(
                                    child: Text(
                                      '₱ ${NumberFormat('#,##0.00').format(totalCash)}',
                                      style: SafeGoogleFont(
                                        'Inter',
                                        fontSize: 17 * size,
                                        fontWeight: FontWeight.w600,
                                        height: 1.2 * size / sizeAxis,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Text(
                                '$percentCash% Increase than before',
                                style: SafeGoogleFont(
                                  'Urbanist',
                                  fontSize: 11 * size,
                                  height: 1.2 * size / sizeAxis,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 15),
                              Row(
                                children: [
                                  Icon(
                                    Icons.payment,
                                    color: Colors.white,
                                  ),
                                  // Icon for the second collection
                                  SizedBox(width: 10),
                                  // Adjust spacing between icon and text
                                  Expanded(
                                    child: Text(
                                      '₱ ${NumberFormat('#,##0.00').format(totalCheque)}',
                                      style: SafeGoogleFont(
                                        'Inter',
                                        fontSize: 17 * size,
                                        fontWeight: FontWeight.w600,
                                        height: 1.2 * size / sizeAxis,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Text(
                                '$percentCheque% Increase than before',
                                style: SafeGoogleFont(
                                  'Urbanist',
                                  fontSize: 11 * size,
                                  height: 1.2 * size / sizeAxis,
                                  color: Colors.white,
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
              // Sales BarChart Month
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Card(
                  elevation: 5,
                  color: Theme.of(context).colorScheme.secondary,
                  child: Stack(
                    children: [
                      // Image.asset(
                      //   'assets/images/bgg16.jpg',
                      //   fit: BoxFit.cover,
                      //   width: 500,
                      //   height: 410,
                      // ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Sales of $formattedCurrentMonth",
                              style: SafeGoogleFont(
                                'Urbanist',
                                fontSize: 15 * size,
                                height: 1.2 * size / sizeAxis,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 20),
                            // BarChart
                            SfCartesianChart(
                              primaryXAxis: CategoryAxis(
                                labelStyle: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              primaryYAxis: NumericAxis(
                                labelStyle: TextStyle(
                                  color: Colors
                                      .white, // Set the color of the labels to white
                                ),
                              ),
                              series: <ChartSeries>[
                                ColumnSeries<SalesMonthData, String>(
                                  dataSource: _chartMonthData,
                                  xValueMapper: (SalesMonthData sales, _) =>
                                      sales.dayName,
                                  yValueMapper: (SalesMonthData sales, _) =>
                                      sales.amount,
                                  color: Colors.white,
                                ),
                              ],
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(width: 5),
                                Text(
                                  'Days',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              // Expense and Disbursement of the day
              Row(
                children: [
                  Expanded(
                    child: Card(
                      elevation: 5,
                      color: Theme.of(context).colorScheme.secondary,
                      child: Stack(
                        children: [
                          // Image.asset(
                          //   'assets/images/bgg15.jpg',
                          //   fit: BoxFit.cover,
                          //   width: 175,
                          //   height: 95,
                          // ),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Expense',
                                  style: SafeGoogleFont(
                                    'Urbanist',
                                    fontSize: 15 * size,
                                    height: 1.2 * size / sizeAxis,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  '₱ ${NumberFormat('#,##0.00').format(totalExpense)}',
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
                  ),
                  Expanded(
                    child: Card(
                      elevation: 5,
                      color: Theme.of(context).colorScheme.secondary,
                      child: Stack(
                        children: [
                          // Image.asset(
                          //   'assets/images/bgg15.jpg',
                          //   fit: BoxFit.cover,
                          //   width: 175,
                          //   height: 95,
                          // ),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              // Set horizontal scroll direction
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'DISBMT',
                                    style: SafeGoogleFont(
                                      'Urbanist',
                                      fontSize: 15 * size,
                                      height: 1.2 * size / sizeAxis,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    '₱ ${NumberFormat('#,##0.00').format(totalDisbursement)}',
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
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              // Sales of the year
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Card(
                  elevation: 5,
                  color: Theme.of(context).colorScheme.secondary,
                  child: Stack(
                    children: [
                      // Image.asset(
                      //   'assets/images/bgg16.jpg',
                      //   fit: BoxFit.cover,
                      //   width: 500,
                      //   height: 390,
                      // ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Sales of $formattedCurrentYear",
                              style: SafeGoogleFont(
                                'Urbanist',
                                fontSize: 15 * size,
                                height: 1.2 * size / sizeAxis,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 20),
                            // LineChart with curved line and data labels
                            SfCartesianChart(
                              primaryXAxis: CategoryAxis(
                                labelStyle: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              primaryYAxis: NumericAxis(
                                labelStyle: TextStyle(
                                  color: Colors
                                      .white, // Set the color of the labels to white
                                ),
                              ),
                              series: <ChartSeries>[
                                SplineSeries<SalesYearData, String>(
                                  dataSource: _chartYearData,
                                  xValueMapper: (SalesYearData sales, _) =>
                                      sales.monthName,
                                  yValueMapper: (SalesYearData sales, _) =>
                                      sales.amount,
                                  color: Colors.white,
                                  splineType: SplineType.monotonic,
                                  markerSettings: MarkerSettings(
                                    isVisible: true,
                                    color: Colors.white,
                                  ),
                                  dataLabelSettings: DataLabelSettings(
                                    color: Colors.white,
                                    isVisible: true,
                                    labelAlignment: ChartDataLabelAlignment.top,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              // IPD and OPD
              Row(
                children: [
                  Expanded(
                    child: Card(
                      elevation: 5,
                      color: Theme.of(context).colorScheme.secondary,
                      child: Stack(
                        children: [
                          // Image.asset(
                          //   'assets/images/bgg15.jpg',
                          //   fit: BoxFit.cover,
                          //   width: 175,
                          //   height: 95,
                          // ),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'IPD ',
                                      style: SafeGoogleFont(
                                        'Urbanist',
                                        fontSize: 15 * size,
                                        height: 1.2 * size / sizeAxis,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      formattedCurrentDate,
                                      style: SafeGoogleFont(
                                        'Urbanist',
                                        fontSize: 11 * size,
                                        height: 1.2 * size / sizeAxis,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                // Text Content
                                Text(
                                  '$totalIPD',
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
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Card(
                      elevation: 5,
                      color: Theme.of(context).colorScheme.secondary,
                      child: Stack(
                        children: [
                          // Image.asset(
                          //   'assets/images/bgg15.jpg',
                          //   fit: BoxFit.cover,
                          //   width: 175,
                          //   height: 95,
                          // ),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'OPD ',
                                      style: SafeGoogleFont(
                                        'Urbanist',
                                        fontSize: 15 * size,
                                        height: 1.2 * size / sizeAxis,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      formattedCurrentDate,
                                      style: SafeGoogleFont(
                                        'Urbanist',
                                        fontSize: 11 * size,
                                        height: 1.2 * size / sizeAxis,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 10),
                                // Text Content
                                Text(
                                  '$totalOPD',
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
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              // PHIC and HMO
              Row(
                children: [
                  Expanded(
                    child: Card(
                      elevation: 5,
                      color: Theme.of(context).colorScheme.secondary,
                      child: Stack(
                        children: [
                          // Image.asset(
                          //   'assets/images/bgg15.jpg',
                          //   fit: BoxFit.cover,
                          //   width: 175,
                          //   height: 95,
                          // ),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'PHIC ',
                                      style: SafeGoogleFont(
                                        'Urbanist',
                                        fontSize: 15 * size,
                                        height: 1.2 * size / sizeAxis,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      formattedCurrentDate,
                                      style: SafeGoogleFont(
                                        'Urbanist',
                                        fontSize: 11 * size,
                                        height: 1.2 * size / sizeAxis,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                // Text Content
                                Text(
                                  '$totalPHIC',
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
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Card(
                      elevation: 5,
                      color: Theme.of(context).colorScheme.secondary,
                      child: Stack(
                        children: [
                          // Image.asset(
                          //   'assets/images/bgg15.jpg',
                          //   fit: BoxFit.cover,
                          //   width: 175,
                          //   height: 95,
                          // ),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'HMO ',
                                      style: SafeGoogleFont(
                                        'Urbanist',
                                        fontSize: 15 * size,
                                        height: 1.2 * size / sizeAxis,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      formattedCurrentDate,
                                      style: SafeGoogleFont(
                                        'Urbanist',
                                        fontSize: 11 * size,
                                        height: 1.2 * size / sizeAxis,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 10),
                                // Text Content
                                Text(
                                  '$totalHMO',
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
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              // Company and Senior
              Row(
                children: [
                  Expanded(
                    child: Card(
                      elevation: 5,
                      color: Theme.of(context).colorScheme.secondary,
                      child: Stack(
                        children: [
                          // Image.asset(
                          //   'assets/images/bgg15.jpg',
                          //   fit: BoxFit.cover,
                          //   width: 175,
                          //   height: 95,
                          // ),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'CO. ',
                                      style: SafeGoogleFont(
                                        'Urbanist',
                                        fontSize: 15 * size,
                                        height: 1.2 * size / sizeAxis,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      formattedCurrentDate,
                                      style: SafeGoogleFont(
                                        'Urbanist',
                                        fontSize: 11 * size,
                                        height: 1.2 * size / sizeAxis,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                // Text Content
                                Text(
                                  '$totalCOMPANY',
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
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Card(
                      elevation: 5,
                      color: Theme.of(context).colorScheme.secondary,
                      child: Stack(
                        children: [
                          // Image.asset(
                          //   'assets/images/bgg15.jpg',
                          //   fit: BoxFit.cover,
                          //   width: 175,
                          //   height: 95,
                          // ),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'SNR ',
                                      style: SafeGoogleFont(
                                        'Urbanist',
                                        fontSize: 15 * size,
                                        height: 1.2 * size / sizeAxis,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      formattedCurrentDate,
                                      style: SafeGoogleFont(
                                        'Urbanist',
                                        fontSize: 11 * size,
                                        height: 1.2 * size / sizeAxis,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                // Text Content
                                Text(
                                  '$totalSENIOR',
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
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              // Insurance of the Day and Month
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Card(
                  elevation: 5,
                  color: Theme.of(context).colorScheme.secondary,
                  child: Stack(
                    children: [
                      // Image.asset(
                      //   'assets/images/bgg16.jpg',
                      //   fit: BoxFit.cover,
                      //   width: 500,
                      //   height: 600,
                      // ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Insurance of $formattedCurrentMonth',
                              style: SafeGoogleFont(
                                'Urbanist',
                                fontSize: 15 * size,
                                height: 1.2 * size / sizeAxis,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 10),
                            Container(
                              height: 320, // Adjust the height as needed
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: insuranceTODAY.length,
                                itemBuilder: (context, index) {
                                  Insurance todayInsurance =
                                      insuranceTODAY[index];
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
                                        title: Text(
                                          todayInsurance.name,
                                          style: SafeGoogleFont(
                                            'Urbanist',
                                            fontSize: 15 * size,
                                            height: 1.2 * size / sizeAxis,
                                            color: const Color(0xff0272bc),
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: 5),
                                            Text(
                                              '\₱ ${double.parse(todayInsurance.amount).toStringAsFixed(2)}',
                                              style: SafeGoogleFont(
                                                'Inter',
                                                fontSize: 17 * size,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                                height: 1.2 * size / sizeAxis,
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
                            SizedBox(height: 10),
                            // Divider(),
                            // Insurance of the Month
                            Row(
                              children: [
                                Expanded(
                                  child: Card(
                                    elevation: 10,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    child: Stack(children: [
                                      // Image.asset(
                                      //   'assets/images/bgg15.jpg',
                                      //   fit: BoxFit.cover,
                                      //   width: 360,
                                      //   height: 125,
                                      // ),
                                      Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Insurance Month',
                                              style: SafeGoogleFont(
                                                'Urbanist',
                                                fontSize: 15 * size,
                                                height: 1.2 * size / sizeAxis,
                                                color: Colors.white,
                                              ),
                                            ),
                                            SizedBox(height: 15),
                                            // Text Content
                                            Text(
                                              '₱ ${NumberFormat('#,##0.00').format(totalInsuranceMONTH)}',
                                              style: SafeGoogleFont(
                                                'Inter',
                                                fontSize: 17 * size,
                                                fontWeight: FontWeight.bold,
                                                height: 1.2 * size / sizeAxis,
                                                color: Colors.white,
                                              ),
                                            ),
                                            SizedBox(height: 10),
                                            Text(
                                              '$percentInsurance% than before',
                                              style: SafeGoogleFont(
                                                'Inter',
                                                fontSize: 11 * size,
                                                fontWeight: FontWeight.bold,
                                                height: 1.2 * size / sizeAxis,
                                                color: Colors.white,
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
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              // Transmittal of the day
              Row(
                children: [
                  Expanded(
                    child: Card(
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
                                'PHIC Transmittal of $formattedCurrentDate',
                                style: SafeGoogleFont(
                                  'Urbanist',
                                  fontSize: 15 * size,
                                  height: 1.2 * size / sizeAxis,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Count: $totalClaimCount',
                                style: SafeGoogleFont(
                                  'Inter',
                                  fontSize: 17 * size,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2 * size / sizeAxis,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Amount: ₱ ${NumberFormat('#,##0.00').format(totalClaimAmount)}',
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
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              // Transmittal Month
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Card(
                  elevation: 5,
                  color: Theme.of(context).colorScheme.secondary,
                  child: Stack(
                    children: [
                      // Image.asset(
                      //   'assets/images/bgg16.jpg',
                      //   fit: BoxFit.cover,
                      //   width: 500,
                      //   height: 410,
                      // ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "PHIC Transmittal of $formattedCurrentMonth",
                              style: SafeGoogleFont(
                                'Urbanist',
                                fontSize: 15 * size,
                                height: 1.2 * size / sizeAxis,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 20),
                            // BarChart
                            SfCartesianChart(
                              primaryXAxis: CategoryAxis(
                                labelStyle: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              primaryYAxis: NumericAxis(
                                labelStyle: TextStyle(
                                  color: Colors
                                      .white, // Set the color of the labels to white
                                ),
                              ),
                              series: <ChartSeries>[
                                ColumnSeries<TransMonthData, String>(
                                  dataSource: _chartMonthTransData,
                                  xValueMapper: (TransMonthData sales, _) =>
                                      sales.dayName,
                                  yValueMapper: (TransMonthData sales, _) =>
                                      sales.amount,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(width: 5),
                                Text(
                                  'Days',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class SalesYearData {
  SalesYearData(this.monthName, this.amount);

  final String monthName;
  final double amount;
}

class SalesMonthData {
  SalesMonthData(this.dayName, this.amount);

  final String dayName;
  final double amount;
}

class TransMonthData {
  TransMonthData(this.dayName, this.amount);

  final String dayName;
  final double amount;
}

class Insurance {
  final String name;
  final String amount;

  Insurance({
    required this.name,
    required this.amount,
  });

  factory Insurance.fromJson(Map<String, dynamic> json) {
    return Insurance(
      name: json['name'],
      amount: json['amount'].toString(), // Parse the amount as a string
    );
  }
}
