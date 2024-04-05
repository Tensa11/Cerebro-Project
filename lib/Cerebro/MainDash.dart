import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../util/utils.dart';
import 'Drawer.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_gauges/gauges.dart';

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
  late List<KPI> kpiData  = [];

  final StreamController<bool> _streamController = StreamController<bool>();
  bool _isQuickAlertShown = false;

  @override
  void initState() {
    super.initState();
    _getUserData();
    // startListeningToChanges();
    //-----------------------------------------------------------------------
    fetchTotalSalesToday();
    fetchCashCollection();
    fetchChequeCollection();
    fetchTotalExpense();
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
    fetchPHICTransmittalTODAY();
    fetchPHICTransmittalMONTH();
    fetchKPI();
    //-----------------------------------------------------------------------
    // fetchPercentSalesToday();
    // fetchPercentCollection();
    // fetchPercentInsuranceTODAY();
    // -----------------------------------------------------------------------
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

  // void startListeningToChanges() {
  //   Timer.periodic(Duration(seconds: 50.0), (timer) {
  //     // Check for database changes periodically
  //     fetchDataAndNotify(); // Fetch data and notify listeners
  //   });
  // }

  // void fetchDataAndNotify() async {
  //   try {
  //     await fetchTotalSalesToday();
  //     await fetchTotalExpense();
  //     await fetchTotalCollection();
  //     await fetchTotalDisbursement();
  //     await fetchSalesMonthChart();
  //     await fetchSalesYearChart();
  //     await fetchTotalIPD();
  //     await fetchTotalOPD();
  //     await fetchTotalPHIC();
  //     await fetchTotalHMO();
  //     await fetchTotalCOMPANY();
  //     await fetchTotalSENIOR();
  //     await fetchInsuranceTODAY();
  //     await fetchInsuranceMONTH();
  //     await fetchPHICTransmittalTODAY();
  //     await fetchPHICTransmittalMONTH();
  //     await fetchPercentSalesToday();
  //     await fetchPercentCollection();
  //     await fetchPercentInsuranceTODAY();
  //     _streamController.add(true); // Notify listeners about the change
  //   } catch (e) {
  //     print('Error fetching data: $e');
  //   }
  // }

  Future<void> fetchTotalSalesToday() async {
    try {
      final apiUrl = dotenv.env['API_URL']; // Retrieve API URL from .env file
      if (apiUrl == null) {
        throw Exception('API_URL environment variable is not defined');
      }
      var url = Uri.parse('$apiUrl/fin/sales/total/today');

      // Retrieve the token and refresh token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token'); // Assuming you saved the token with this key
      final refreshToken = prefs.getString('refreshToken'); // Assuming refresh token is stored separately

      if (token == null || refreshToken == null) {
        throw Exception('Token or refresh token not found.');
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
        var totalValue = data['data'][0]['total'];
        if (totalValue is int) {
          totalSales = totalValue.toDouble();
        } else if (totalValue is double) {
          totalSales = totalValue;
        } else {
          throw Exception('Total value is neither int nor double');
        }
        setState(() {});
      } else if (response.statusCode == 401 && response.body.contains('You are not logged in')) {
        // Handle expired token scenario
        print('Your access token might be expired. Trying to refresh.');

        // Implement logic to refresh token using the refresh token here (replace with your API call)
        // This is a placeholder, replace with your actual refresh API call
        final refreshResponse = await http.post(
            Uri.parse('$apiUrl/auth/refresh'),
            body: jsonEncode({'refreshToken': refreshToken}));

        if (refreshResponse.statusCode == 200) {
          final refreshedData = json.decode(refreshResponse.body);
          final newToken = refreshedData['token'];
          // Update the access token in SharedPreferences
          await prefs.setString('token', newToken);

          // Retry the original API call with the new token
          print('Access token refreshed. Retrying fetchTotalSalesToday.');
          return fetchTotalSalesToday(); // Recursive call to retry
        } else {
          // Handle refresh token failure
          print('Failed to refresh token. Login required.');
          throw Exception('Failed to refresh token. Login required.');
        }
      } else {
        // Handle other errors (e.g., server error)
        print('Failed to load fetchTotalSalesToday. Status code: ${response.statusCode}, Response body: ${response.body}');
        throw Exception('Failed to load fetchTotalSalesToday');
      }
    } catch (e) {
      // Print the error message
      print('Error fetching fetchTotalSalesToday: $e');
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

  Future<void> fetchCashCollection() async {
    try {
      final apiUrl = dotenv.env['API_URL']; // Retrieve API URL from .env file
      if (apiUrl == null) {
        throw Exception('API_URL environment variable is not defined');
      }

      var url = Uri.parse('$apiUrl/fin/cashier/collection/today');

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
        if (cashTotal is int) {
          totalCash = cashTotal.toDouble();
        } else if (cashTotal is double) {
          totalCash = cashTotal;
        } else {
          throw Exception('totalCash value is neither int nor double');
        }
        setState(() {});
      } else {
        print('Failed to load fetchCashCollection. Status code: ${response.statusCode}, Response body: ${response.body}');
        throw Exception('Failed to load fetchCashCollection');
      }
    } catch (e) {
      print('Error fetching fetchCashCollection: $e');
      setState(() {});
    }
  }

  Future<void> fetchChequeCollection() async {
    try {
      final apiUrl = dotenv.env['API_URL']; // Retrieve API URL from .env file
      if (apiUrl == null) {
        throw Exception('API_URL environment variable is not defined');
      }

      var url = Uri.parse('$apiUrl/fin/cashier/collection/today');

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
        var chequeTotal = data['data'][0]['cheque'];
        if (chequeTotal is int) {
          totalCheque = chequeTotal.toDouble();
        } else if (chequeTotal is double) {
          totalCheque = chequeTotal;
        } else {
          throw Exception('totalCheque value is neither int nor double');
        }
        setState(() {});
      } else {
        throw Exception('Failed to load fetchChequeCollection');
      }
    } catch (e) {
      print('Error fetching fetchChequeCollection: $e');
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
  final List<String> dayNames = List.generate(31, (index) => (index + 1).toString());

  Future<void> fetchSalesMonthChart() async {
    try {
      final apiUrl = dotenv.env['API_URL']; // Retrieve API URL from .env file
      if (apiUrl == null) {
        throw Exception('API_URL environment variable is not defined');
      }
      var url = Uri.parse('$apiUrl/fin/sales/total/month');


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
          'Cookie': 'refreshToken=$refreshToken', // Include the token in the Authorization header
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        List<SalesMonthData> salesMonthData = List.generate(data['data'].length, (index) {
          String dayName = dayNames[data['data'][index]['day'] - 1];
          return SalesMonthData(
            dayName,
            double.parse(data['data'][index]['amount'].toString()),
          );
        });
        salesMonthData.sort((a, b) => int.parse(a.dayName).compareTo(int.parse(b.dayName)));

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
        if (expenseTotal is int) {
          totalExpense = expenseTotal.toDouble();
        } else if (expenseTotal is double) {
          totalExpense = expenseTotal;
        } else {
          throw Exception('Total value is neither int nor double');
        }

        // totalExpense = double.parse(data['data'][0]['expense']);
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
        var disbursTotal = data['data'][0]['total'];
        if (disbursTotal is int) {
          totalDisbursement = disbursTotal.toDouble();
        } else if (disbursTotal is double) {
          totalDisbursement = disbursTotal;
        } else {
          throw Exception('Total value is neither int nor double');
        }

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
      final apiUrl = dotenv.env['API_URL'];
      if (apiUrl == null) {
        throw Exception('API_URL environment variable is not defined');
      }
      var url = Uri.parse('$apiUrl/fin/sales/total/year');

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
        List<SalesYearData> salesYearData = List.generate(data['data'].length, (index) {
          String monthName = monthNames[data['data'][index]['month'] - 1];
          return SalesYearData(
            monthName,
            double.parse(data['data'][index]['amount'].toString()), // Parse amount as double
          );
        });

        setState(() {
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
        var insuranceMonthTotal = data['data'][0]['amount'];
        if (insuranceMonthTotal is int) {
          totalInsuranceMONTH = insuranceMonthTotal.toDouble();
        } else if (insuranceMonthTotal is double) {
          totalInsuranceMONTH = insuranceMonthTotal;
        } else {
          throw Exception('Total value is neither int nor double');
        }
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
        totalClaimCount = data['data'][0]['claim_count'] as int;

        var claimAmountTotal = data['data'][0]['claim_amount'];
        if (claimAmountTotal is int) {
          totalClaimAmount = claimAmountTotal.toDouble();
        } else if (claimAmountTotal is double) {
          totalClaimAmount = claimAmountTotal;
        } else {
          throw Exception('Total value is neither int nor double');
        }
        setState(() {
        });
      } else {
        throw Exception('Failed to load fetchPHICTransmittalTODAY');
      }
    } catch (e) {
      print('Error fetching fetchPHICTransmittalTODAY: $e');
    }
  }

  List<TransMonthData> _chartMonthTransData = [];
  final List<String> dayTransNames = List.generate(31, (index) => (index + 1).toString());

  Future<void> fetchPHICTransmittalMONTH() async {
    try {
      final apiUrl = dotenv.env['API_URL'];
      if (apiUrl == null) {
        throw Exception('API_URL environment variable is not defined');
      }
      var url = Uri.parse('$apiUrl/fin/phic_transmittal/month');
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
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
        List<TransMonthData> transMonthData = [];
        for (var dayData in data['data'][0]) {
          String dayName = dayNames[dayData['day'] - 1];
          transMonthData.add(TransMonthData(
            dayName,
            double.parse(dayData['amount'].toString()),
          ));
        }
        transMonthData.sort((a, b) => int.parse(a.dayName).compareTo(int.parse(b.dayName)));

        setState(() {
          _chartMonthTransData = transMonthData;
        });
      } else {
        throw Exception('Failed to load fetchPHICTransmittalMONTH');
      }
    } catch (e) {
      print('Error fetching fetchPHICTransmittalMONTH: $e');
      setState(() {
      });
    }
  }

  Future<void> fetchKPI() async {
    try {
      final apiUrl = dotenv.env['API_URL']; // Retrieve API URL from .env file
      if (apiUrl == null) {
        throw Exception('API_URL environment variable is not defined');
      }
      var url = Uri.parse('$apiUrl/med/hospital/kpi');
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
        List<KPI> fetchedKPIs = List.generate(data['data'].length, (index) {
          return KPI.fromJson(data['data'][index]);
        });

        setState(() {
          kpiData = fetchedKPIs; // Assuming kpiData is a state variable to store the KPI data
        });
      } else {
        throw Exception('Failed to load KPI data');
      }
    } catch (e) {
      print('Error fetching KPI data: $e');
    }
  }

  String formattedCurrentDate = DateFormat('MMM d, yyyy').format(DateTime.now()).toUpperCase();
  String formattedCurrentMonth = DateFormat('MMM yyyy').format(DateTime.now()).toUpperCase();
  String formattedCurrentYear = DateFormat('yyyy').format(DateTime.now()).toUpperCase();

  String avatarUrl = '';
  String username = '';
  String hospitalName = '';

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
      setState(() {
        avatarUrl = data['avatar']; // Store the avatar URL
        hospitalName = data['data'][0]['hospital_name']; // Store the hospital name

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
                      'latest update of $hospitalName | $formattedCurrentDate',
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
              Divider(color: Theme.of(context).colorScheme.secondary,),
              SizedBox(height: 15),
              // Sales of the day--------------------------
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
                              Align(
                                alignment: Alignment.centerRight,
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
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
              // -------------------------------------
              Container(
                margin: EdgeInsets.fromLTRB(
                    5 * sizeAxis, 10 * sizeAxis, 0 * sizeAxis, 0 * sizeAxis),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Today's Collection",
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
              // Cash and Cheque--------------------------
              Row(
                children: [
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 0,
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
                                          '₱ ${NumberFormat('#,##0.00').format(totalCash)}',
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
                                  // SizedBox(height: 10),
                                  // Text Content
                                  // Text(
                                  //   '$percentCash% Increase than before',
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
                  ),
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
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
                                        Align(
                                          alignment: Alignment.centerRight,
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
                                  ),

                                  // SizedBox(height: 10),
                                  // Text Content
                                  // Text(
                                  //   '$percentCheque% Increase than before',
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
                  ),
                ],
              ),
              SizedBox(height: 10),
              // Sales BarChart Month--------------------------
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
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
                                  color: Colors.white,
                                ),
                              ),
                              series: <CartesianSeries>[
                                ColumnSeries<SalesMonthData, String>(
                                  dataSource: _chartMonthData,
                                  xValueMapper: (SalesMonthData sales, _) => sales.dayName,
                                  yValueMapper: (SalesMonthData sales, _) => sales.amount,
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
              // Expense and Disbursement of the day--------------------------
              Container(
                margin: EdgeInsets.fromLTRB(
                    5 * sizeAxis, 10 * sizeAxis, 0 * sizeAxis, 0 * sizeAxis),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Today's Expense and Disbursement",
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
                  // Expense
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
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
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
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
                        ],
                      ),
                    ),
                  ),
                  // Disbursement
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
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
                                  'Disbursement',
                                  style: SafeGoogleFont(
                                    'Urbanist',
                                    fontSize: 15 * size,
                                    height: 1.2 * size / sizeAxis,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '₱ ${NumberFormat('#,##0.00').format(totalDisbursement)}',
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
              // Sales of the year--------------------------
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
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
                                isVisible: false, // This line hides the YAxis label
                                labelStyle: TextStyle(
                                  color: Colors.white, // Set the color of the labels to white
                                ),
                                numberFormat: NumberFormat.currency(locale: 'en_US', symbol: '₱ '), // Set currency format
                              ),
                              series: <CartesianSeries>[
                                SplineSeries<SalesYearData, String>(
                                  dataSource: _chartYearData,
                                  xValueMapper: (SalesYearData sales, _) => sales.monthName,
                                  yValueMapper: (SalesYearData sales, _) => sales.amount,
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
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              // --------------------------------------
              Container(
                margin: EdgeInsets.fromLTRB(
                    5 * sizeAxis, 10 * sizeAxis, 0 * sizeAxis, 0 * sizeAxis),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Today's Patient Data",
                      style: SafeGoogleFont(
                        'Urbanist',
                        fontSize: 15 * size,
                        fontWeight: FontWeight.bold,
                        height: 1.2 * size / sizeAxis,
                        color: const Color(0xFF13A4FF),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              // IPD and OPD--------------------------
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
                                  ],
                                ),
                                SizedBox(height: 10),
                                // Centered Text Content
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    '$totalIPD',
                                    style: SafeGoogleFont(
                                      'Inter',
                                      fontSize: 17 * size,
                                      fontWeight: FontWeight.bold,
                                      height: 1.2 * size / sizeAxis,
                                      color: Colors.white,
                                    ),
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
                                  ],
                                ),
                                SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    '$totalOPD',
                                    style: SafeGoogleFont(
                                      'Inter',
                                      fontSize: 17 * size,
                                      fontWeight: FontWeight.bold,
                                      height: 1.2 * size / sizeAxis,
                                      color: Colors.white,
                                    ),
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
              // PHIC and HMO--------------------------
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
                                  ],
                                ),
                                SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    '$totalPHIC',
                                    style: SafeGoogleFont(
                                      'Inter',
                                      fontSize: 17 * size,
                                      fontWeight: FontWeight.bold,
                                      height: 1.2 * size / sizeAxis,
                                      color: Colors.white,
                                    ),
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
                                  ],
                                ),

                                SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    '$totalHMO',
                                    style: SafeGoogleFont(
                                      'Inter',
                                      fontSize: 17 * size,
                                      fontWeight: FontWeight.bold,
                                      height: 1.2 * size / sizeAxis,
                                      color: Colors.white,
                                    ),
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
              // Company and Senior--------------------------
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
                                      'Company',
                                      style: SafeGoogleFont(
                                        'Urbanist',
                                        fontSize: 15 * size,
                                        height: 1.2 * size / sizeAxis,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    '$totalCOMPANY',
                                    style: SafeGoogleFont(
                                      'Inter',
                                      fontSize: 17 * size,
                                      fontWeight: FontWeight.bold,
                                      height: 1.2 * size / sizeAxis,
                                      color: Colors.white,
                                    ),
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
                                      'Senior PWD',
                                      style: SafeGoogleFont(
                                        'Urbanist',
                                        fontSize: 15 * size,
                                        height: 1.2 * size / sizeAxis,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    '$totalSENIOR',
                                    style: SafeGoogleFont(
                                      'Inter',
                                      fontSize: 17 * size,
                                      fontWeight: FontWeight.bold,
                                      height: 1.2 * size / sizeAxis,
                                      color: Colors.white,
                                    ),
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
              // Insurance of the Day and Month--------------------------
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
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
                              'Insurance of The Day',
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
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      elevation: 3,
                                      color: Theme.of(context).colorScheme.primary,
                                      child: ListTile(
                                        title: Text(
                                          todayInsurance.name,
                                          style: SafeGoogleFont(
                                            'Urbanist',
                                            fontSize: 15 * size,
                                            height: 1.2 * size / sizeAxis,
                                            color: Theme.of(context).colorScheme.tertiary,
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
                                                color: Theme.of(context).colorScheme.tertiary,
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
                            // New Content
                            SizedBox(height: 10),
                            // Insurance of the Month
                            Row(
                              children: [
                                Expanded(
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    color: Theme.of(context).colorScheme.primary,
                                    child: Stack(
                                        children: [
                                          // Image.asset(
                                          //   'assets/images/bgg15.jpg',
                                          //   fit: BoxFit.cover,
                                          //   width: 360,
                                          //   height: 125,
                                          // ),
                                          Padding(
                                            padding: const EdgeInsets.all(15.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Insurance of $formattedCurrentMonth',
                                                  style: SafeGoogleFont(
                                                    'Urbanist',
                                                    fontSize: 15 * size,
                                                    height: 1.2 * size / sizeAxis,
                                                    color: Theme.of(context).colorScheme.tertiary,
                                                  ),
                                                ),
                                                SizedBox(height: 15),
                                                Align(
                                                  alignment: Alignment.centerRight,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        '₱ ${NumberFormat('#,##0.00').format(totalInsuranceMONTH)}',
                                                        style: SafeGoogleFont(
                                                          'Inter',
                                                          fontSize: 17 * size,
                                                          fontWeight: FontWeight.bold,
                                                          height: 1.2 * size / sizeAxis,
                                                          color: Theme.of(context).colorScheme.tertiary,
                                                        ),
                                                      ),
                                                      SizedBox(height: 10),
                                                      // Text(
                                                      //   '$percentInsurance% than before',
                                                      //   style: SafeGoogleFont(
                                                      //     'Inter',
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
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              // Transmittal of the day--------------------------
              Row(
                children: [
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
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
                              SizedBox(height: 15),
                              Row(
                                children: [
                                  Text(
                                    'Total Claims: ',
                                    style: SafeGoogleFont(
                                      'Urbanist',
                                      fontSize: 15 * size,
                                      height: 1.2 * size / sizeAxis,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '$totalClaimCount',
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
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Text(
                                    'Amount: ',
                                    style: SafeGoogleFont(
                                      'Urbanist',
                                      fontSize: 15 * size,
                                      height: 1.2 * size / sizeAxis,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '₱ ${NumberFormat('#,##0.00').format(totalClaimAmount)}',
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
              SizedBox(height: 5),
              // Transmittal Month--------------------------
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
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
                                  color: Colors.white, // Set the color of the labels to white
                                ),
                              ),
                              series: <CartesianSeries>[ // Corrected type here
                                ColumnSeries<TransMonthData, String>(
                                  dataSource: _chartMonthTransData,
                                  xValueMapper: (TransMonthData sales, _) => sales.dayName,
                                  yValueMapper: (TransMonthData sales, _) => sales.amount,
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
              // KPI --------------------------
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                  color: Theme.of(context).colorScheme.secondary,
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Key Performance Indicator',
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
                              height: 450, // Adjust the height as needed
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: kpiData.length,
                                itemBuilder: (context, index) {
                                  KPI kpi = kpiData[index];
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
                                      elevation: 5,
                                      color: Theme.of(context).colorScheme.primary,
                                      child: ListTile(
                                        title: Text(
                                          kpi.statusType,
                                          style: SafeGoogleFont(
                                            'Urbanist',
                                            fontSize: 15 * size,
                                            height: 1.2 * size / sizeAxis,
                                            color: Theme.of(context).colorScheme.tertiary,
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: 10),
                                            // Text(
                                            //   '${kpi.value}',
                                            //   style: SafeGoogleFont(
                                            //     'Inter',
                                            //     fontSize: 17 * size,
                                            //     fontWeight: FontWeight.bold,
                                            //     color: Theme.of(context).colorScheme.tertiary,
                                            //     height: 1.2 * size / sizeAxis,
                                            //   ),
                                            // ),
                                            Center(
                                              child: Container(
                                                width: 260,
                                                height: 260,
                                                child: SfRadialGauge(
                                                  axes: <RadialAxis>[
                                                    RadialAxis(
                                                      minimum: 0,
                                                      maximum: 500, // Adjust the maximum value as needed
                                                      showLabels: true,
                                                      showTicks: true,
                                                      ticksPosition: ElementsPosition.outside,
                                                      labelsPosition: ElementsPosition.outside, // Move labels outside the axis line
                                                      axisLineStyle: AxisLineStyle(
                                                        thickness: 0.0,
                                                        color: Theme.of(context).colorScheme.tertiary,
                                                        thicknessUnit: GaugeSizeUnit.factor,
                                                      ),
                                                      ranges: <GaugeRange>[
                                                        GaugeRange(
                                                            startValue: 0,
                                                            endValue: 150,
                                                            color: Colors.greenAccent,
                                                            startWidth: 5,
                                                            endWidth:30
                                                        ),
                                                        GaugeRange(
                                                            startValue: 150,
                                                            endValue: 350,
                                                            color: Colors.orangeAccent,
                                                            startWidth: 5,
                                                            endWidth:30
                                                        ),
                                                        GaugeRange(
                                                            startValue: 350,
                                                            endValue: 500,
                                                            color: Colors.redAccent,
                                                            startWidth: 5,
                                                            endWidth:30
                                                        ),
                                                      ],
                                                      pointers: <GaugePointer>[
                                                        NeedlePointer(
                                                          value: kpi.value.toDouble(), // Assuming kpi.value is accessible here
                                                          needleColor: Theme.of(context).colorScheme.tertiary, // Use the defined color
                                                          lengthUnit: GaugeSizeUnit.factor,
                                                          needleStartWidth: 0.1,
                                                          needleEndWidth: 7,
                                                          needleLength: 0.7,
                                                        ),
                                                      ],
                                                      annotations: <GaugeAnnotation>[
                                                        GaugeAnnotation(
                                                          positionFactor: 0.5,
                                                          angle: 90,
                                                          widget: Text(
                                                            '${kpi.value} ${kpi.units}',
                                                            style: TextStyle(
                                                              fontSize: 13,
                                                              fontWeight: FontWeight.bold,
                                                              color: Theme.of(context).colorScheme.tertiary,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
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
                            // Additional content can be added here
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


