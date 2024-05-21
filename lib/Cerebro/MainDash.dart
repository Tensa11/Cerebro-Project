import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import '../util/utils.dart';
import 'Drawer.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class MainDash extends StatefulWidget {
  const MainDash({Key? key}) : super(key: key);

  @override
  _MainDashState createState() => _MainDashState();
}

class _MainDashState extends State<MainDash> {
  final StreamController<bool> _streamController = StreamController<bool>();
  bool isLoading = false;
  bool _isQuickAlertShown = false;

  @override
  void initState() {
    super.initState();
    _getUserData();
    _getHospitalNameData();
    _getAvatarData();
    fetchTodaySales();
    fetchTodayCash();
    fetchTodayCheque();
    fetchMonthSalesChart();
    fetchTodayExpense();
    fetchExpenseMONTH();
    fetchTodayDisbursement();
    fetchYearSalesChart();
    fetchToday_IPD();
    fetchToday_OPD();
    fetchToday_PHIC();
    fetchToday_HMO();
    fetchToday_COMPANY();
    fetchToday_SENIOR();
    fetchInsuranceTODAY();
    fetchInsuranceMONTH();
    fetchClaimAmountToday();
    fetchTodayPF();
    fetchPHICTransmittalMONTH_Chart();
    fetchKPI();
    // -----------------------------------------------------------------------
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool hasShownAlert = prefs.getBool('hasShownQuickAlert') ?? false;

      if (!hasShownAlert && !_isQuickAlertShown) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: "Welcome back $username",
          text: "This are the Data for today. If nothing is loading-in try to Refresh the screen by holding the screen downwards or re-login.",
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

  late double todaySales = 0;
  Future<void> fetchTodaySales() async {
    try {
      final apiUrl = dotenv.env['API_URL']; // Retrieve API URL from .env file
      if (apiUrl == null) {
        throw Exception('API_URL environment variable is not defined');
      }
      var url = Uri.parse('$apiUrl/fin/sales?date=$_selectedDate&period=today');

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
          todaySales = saleTotal.toDouble();
        } else {
          todaySales = 0.00; // Set to 0.00 if cashTotal is null or not a number
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

  late double todayCash = 0;
  Future<void> fetchTodayCash() async {
    try {
      final apiUrl = dotenv.env['API_URL']; // Retrieve API URL from .env file
      if (apiUrl == null) {
        throw Exception('API_URL environment variable is not defined');
      }

      var url = Uri.parse('$apiUrl/fin/cashier?date=$_selectedDate&period=today');

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
          todayCash = cashTotal.toDouble();
        } else {
          todayCash = 0.00; // Set to 0.00 if cashTotal is null or not a number
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

  late double todayCheque = 0;
  Future<void> fetchTodayCheque() async {
    try {
      final apiUrl = dotenv.env['API_URL']; // Retrieve API URL from .env file
      if (apiUrl == null) {
        throw Exception('API_URL environment variable is not defined');
      }

      var url = Uri.parse('$apiUrl/fin/cashier?date=$_selectedDate&period=today');

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
          todayCheque = chequeTotal.toDouble();
        } else {
          todayCheque = 0.00; // Set to 0.00 if cashTotal is null or not a number
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

  List<SalesMonthData> _chartMonthData = [];
  final List<String> dayNames = List.generate(31, (index) => (index + 1).toString());
  Future<void> fetchMonthSalesChart() async {
    try {
      final apiUrl = dotenv.env['API_URL']; // Retrieve API URL from .env file
      if (apiUrl == null) {
        throw Exception('API_URL environment variable is not defined');
      }
      var url = Uri.parse('$apiUrl/fin/sales?date=$_selectedDate&period=month');

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

  late double todayExpense = 0;
  Future<void> fetchTodayExpense() async {
    try {
      final apiUrl = dotenv.env['API_URL']; // Retrieve API URL from .env file
      if (apiUrl == null) {
        throw Exception('API_URL environment variable is not defined');
      }
      var url = Uri.parse('$apiUrl/inv/items/expense?date=$_selectedDate&period=today');

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
          todayExpense = expenseTotal.toDouble();
        } else {
          todayExpense = 0.00; // Set to 0.00 if cashTotal is null or not a number
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

  List<ExpenMonthData> _chartMonthExpenseData = [];
  Future<void> fetchExpenseMONTH() async {
    try {
      final apiUrl = dotenv.env['API_URL'];
      if (apiUrl == null) {
        throw Exception('API_URL environment variable is not defined');
      }
      var url = Uri.parse('$apiUrl/fin/sales?date=$_selectedDate&period=month');
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
        var data = json.decode(response.body)['data'];
        List<ExpenMonthData> expensMonthData = [];
        for (var dayData in data) {
          String dayName = dayNames[dayData['day'] - 1];
          expensMonthData.add(ExpenMonthData(
            dayName,
            double.parse(dayData['amount'].toString()),
          ));
        }
        setState(() {
          _chartMonthExpenseData = expensMonthData;
        });
      } else {
        throw Exception('Failed to load fetchPHICTransmittalMONTH');
      }
    } catch (e) {
      print('Error fetching fetchPHICTransmittalMONTH: $e');
      setState(() {});
    }
  }

  late double todayDisbursement = 0;
  Future<void> fetchTodayDisbursement() async {
    try {
      final apiUrl = dotenv.env['API_URL']; // Retrieve API URL from .env file
      if (apiUrl == null) {
        throw Exception('API_URL environment variable is not defined');
      }
      var url = Uri.parse('$apiUrl/inv/items/disbursement/history?date=$_selectedDate&period=today');

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
        var expenseTotal = data['data'][0]['disbursement'];
        if (expenseTotal is int || expenseTotal is double) {
          todayDisbursement = expenseTotal.toDouble();
        } else {
          todayDisbursement = 0.00; // Set to 0.00 if cashTotal is null or not a number
          throw Exception('totalSales value is neither int nor double');
        }
        setState(() {});
      } else {
        throw Exception('Failed to load fetchTodayDisbursement');
      }
    } catch (e) {
      print('Error fetching fetchTodayDisbursement: $e');
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
  Future<void> fetchYearSalesChart() async {
    try {
      final apiUrl = dotenv.env['API_URL'];
      if (apiUrl == null) {
        throw Exception('API_URL environment variable is not defined');
      }
      var url = Uri.parse('$apiUrl/fin/sales?date=$_selectedDate&period=year');

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

  late int totalIPD = 0;
  Future<void> fetchToday_IPD() async {
    try {
      final apiUrl = dotenv.env['API_URL']; // Retrieve API URL from .env file
      if (apiUrl == null) {
        throw Exception('API_URL environment variable is not defined');
      }
      var url = Uri.parse('$apiUrl/med/patients/ipd?date=$_selectedDate&period=day');

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
        throw Exception('Failed to load fetchToday_IPD');
      }
    } catch (e) {
      print('Error fetching fetchToday_IPD: $e');
      setState(() {});
    }
  }

  late int totalOPD = 0;
  Future<void> fetchToday_OPD() async {
    try {
      final apiUrl = dotenv.env['API_URL']; // Retrieve API URL from .env file
      if (apiUrl == null) {
        throw Exception('API_URL environment variable is not defined');
      }
      var url = Uri.parse('$apiUrl/med/patients/opd?date=$_selectedDate&period=day');

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

  late int totalPHIC = 0;
  Future<void> fetchToday_PHIC() async {
    try {
      final apiUrl = dotenv.env['API_URL']; // Retrieve API URL from .env file
      if (apiUrl == null) {
        throw Exception('API_URL environment variable is not defined');
      }
      var url = Uri.parse('$apiUrl/med/patients/phic?date=$_selectedDate&period=day');
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

  late int totalHMO = 0;
  Future<void> fetchToday_HMO() async {
    try {
      final apiUrl = dotenv.env['API_URL']; // Retrieve API URL from .env file
      if (apiUrl == null) {
        throw Exception('API_URL environment variable is not defined');
      }
      var url = Uri.parse('$apiUrl/med/patients/hmo?date=$_selectedDate&period=day');
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

  late int totalCOMPANY = 0;
  Future<void> fetchToday_COMPANY() async {
    try {
      final apiUrl = dotenv.env['API_URL']; // Retrieve API URL from .env file
      if (apiUrl == null) {
        throw Exception('API_URL environment variable is not defined');
      }
      var url = Uri.parse('$apiUrl/med/patients/company?date=$_selectedDate&period=day');
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

  late int totalSENIOR = 0;
  Future<void> fetchToday_SENIOR() async {
    try {
      final apiUrl = dotenv.env['API_URL']; // Retrieve API URL from .env file
      if (apiUrl == null) {
        throw Exception('API_URL environment variable is not defined');
      }
      var url = Uri.parse('$apiUrl/med/patients/srpwd?date=$_selectedDate&period=day');
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

  late List<Insurance> insuranceTODAY = [];
  Future<void> fetchInsuranceTODAY() async {
    try {
      final apiUrl = dotenv.env['API_URL']; // Retrieve API URL from .env file
      if (apiUrl == null) {
        throw Exception('API_URL environment variable is not defined');
      }
      var url = Uri.parse('$apiUrl/fin/insurance?date=$_selectedDate&period=day');
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

  late double totalInsuranceMONTH = 0;
  Future<void> fetchInsuranceMONTH() async {
    try {
      final apiUrl = dotenv.env['API_URL']; // Retrieve API URL from .env file
      if (apiUrl == null) {
        throw Exception('API_URL environment variable is not defined');
      }
      var url = Uri.parse('$apiUrl/fin/insurance?date=$_selectedDate&period=month');
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
        if (insuranceMonthTotal is int || insuranceMonthTotal is double) {
          totalInsuranceMONTH = insuranceMonthTotal.toDouble();
        } else {
          totalInsuranceMONTH = 0.00; // Set to 0.00 if cashTotal is null or not a number
          throw Exception('totalInsuranceMONTH value is neither int nor double');
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

  late int todayClaimCount = 0;
  late double todayClaimAmount = 0;
  Future<void> fetchClaimAmountToday() async {
    try {
      final apiUrl = dotenv.env['API_URL']; // Retrieve API URL from .env file
      if (apiUrl == null) {
        throw Exception('API_URL environment variable is not defined');
      }

      var url = Uri.parse('$apiUrl/fin/phic_transmittal?date=$_selectedDate&period=today&type=claim_amount');

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
        todayClaimCount = (data['data'][0]['count'] == null || data['data'][0]['count'] == 0) ? 0 : data['data'][0]['count'] as int;

        var claimTotal = data['data'][0]['amount'];
        if (claimTotal is int || claimTotal is double) {
          todayClaimAmount = claimTotal.toDouble();
        } else {
          todayClaimAmount = 0.00; // Set to 0.00 if cashTotal is null or not a number
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

  double calculateMaxValue(List<PHIC_ChartData> dataSource) {
    return dataSource.map((data) => data.value).reduce(max);
  }

  late double todayPF = 0;
  Future<void> fetchTodayPF() async {
    try {
      final apiUrl = dotenv.env['API_URL']; // Retrieve API URL from .env file
      if (apiUrl == null) {
        throw Exception('API_URL environment variable is not defined');
      }

      var url = Uri.parse('$apiUrl/fin/phic_transmittal?date=$_selectedDate&type=pf_amount');

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
          todayPF = pfTotal.toDouble();
        } else {
          todayPF = 0.00; // Set to 0.00 if cashTotal is null or not a number
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

  List<TransMonthData> _chartMonthTransData = [];
  Future<void> fetchPHICTransmittalMONTH_Chart() async {
    try {
      final apiUrl = dotenv.env['API_URL'];
      if (apiUrl == null) {
        throw Exception('API_URL environment variable is not defined');
      }
      var url = Uri.parse('$apiUrl/fin/phic_transmittal?date=$_selectedDate&period=month&type=claim_amount');
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
        var data = json.decode(response.body)['data'];
        List<TransMonthData> transMonthData = [];
        for (var dayData in data) {
          String dayName = dayNames[dayData['day'] - 1];
          transMonthData.add(TransMonthData(
            dayName,
            double.parse(dayData['amount'].toString()),
          ));
        }
        setState(() {
          _chartMonthTransData = transMonthData;
        });
      } else {
        throw Exception('Failed to load fetchPHICTransmittalMONTH');
      }
    } catch (e) {
      print('Error fetching fetchPHICTransmittalMONTH: $e');
      setState(() {});
    }
  }

  late List<KPI> kpiData  = [];
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
  late String _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now()); // Set initial value to current date

  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF1497E8), // Header and selected day background color
              onPrimary: Color(0xFF000000), // Titles and selected day text color
              onSurface: Color(0xFF000000), // Month days and years text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.redAccent, // OK and Cancel buttons text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
        _selectedDate = DateFormat('yyyy-MM-dd').format(pickedDate); // Update selected date
      });
      fetchTodaySales();
      fetchTodayCash();
      fetchTodayCheque();
      fetchMonthSalesChart();
      fetchTodayExpense();
      fetchExpenseMONTH();
      fetchTodayDisbursement();
      fetchYearSalesChart();
      fetchToday_IPD();
      fetchToday_OPD();
      fetchToday_PHIC();
      fetchToday_HMO();
      fetchToday_COMPANY();
      fetchToday_SENIOR();
      fetchInsuranceTODAY();
      fetchInsuranceMONTH();
      fetchClaimAmountToday();
      fetchTodayPF();
      fetchPHICTransmittalMONTH_Chart();
      fetchKPI();
    }
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
        // Set a custom height for the app bar
        toolbarHeight: 80,
        // Transparent background with gradient in flexible space
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
                color: Colors.white,
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
                      errorWidget: (context, url, error) => Icon(Icons.local_hospital_rounded, size: 40, color: Colors.grey[300]),
                    ): Icon(Icons.broken_image, size: 40, color: Colors.grey[300]),
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
        child: ListView(
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
                          '$hospitalName: $username',
                          style: SafeGoogleFont(
                            'Urbanist',
                            fontSize: 20 * size,
                            fontWeight: FontWeight.bold,
                            height: 1.2 * size / sizeAxis,
                            color: const Color(0xFFFFFFFF),
                          ),
                        ),
                        // SizedBox(height: 5),
                        Row(
                          children: [
                            Text(
                              'latest update of',
                              style: SafeGoogleFont(
                                'Urbanist',
                                fontSize: 14 * size,
                                height: 1.2 * size / sizeAxis,
                                color: Colors.white,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                _selectDate();
                              },
                              // style: TextButton.styleFrom(
                              //   backgroundColor: Colors.redAccent, // Set the text color to pink
                              // ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min, // Ensure the row takes only the minimum required space
                                children: [
                                  Text(
                                    '$formattedCurrentDate ',
                                    style: SafeGoogleFont(
                                      'Urbanist',
                                      fontSize: 11 * size,
                                      height: 1.2 * size / sizeAxis,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                  Icon(
                                    Icons.calendar_month_outlined,
                                    color: Colors.redAccent,
                                      size: 14,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'If nothing is loading in try to Refresh the screen by holding the screen downwards.',
                          style: SafeGoogleFont(
                            'Urbanist',
                            fontSize: 12 * size,
                            height: 1.2 * size / sizeAxis,
                            color: const Color(0xFFFFFFFF),
                          ),
                        ),
                        SizedBox(height: 10),
                        // Container(
                        //   margin: EdgeInsets.fromLTRB(1 * sizeAxis, 0 * sizeAxis,
                        //       0 * sizeAxis, 15 * sizeAxis),
                        //   width: 331 * sizeAxis,
                        //   decoration: BoxDecoration(
                        //     borderRadius: BorderRadius.circular(30),
                        //     color: Colors.white,
                        //   ),
                        //   child: TextField(
                        //     controller: _dateController,
                        //     decoration: InputDecoration(
                        //       labelText: "Select a Date",
                        //       labelStyle: TextStyle(color: Colors.black),
                        //       hintStyle: TextStyle(color: Colors.black),
                        //       prefixIcon: Icon(Icons.calendar_month, color: Colors.black,),
                        //       border: InputBorder.none,
                        //     ),
                        //     readOnly: true,
                        //     onTap: (){
                        //       _selectDate();
                        //     },
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5.0),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(75.0)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(left: 30.0, right: 30.0),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(height: 30),
                            // Sales of the day-----------------------------------------------
                            Row(
                              children: [
                                Expanded(
                                  child: Card(
                                    elevation: 5,
                                    color: Color(0xFF1497E8),
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
                                                    '₱ ${NumberFormat('#,##0.00').format(todaySales)}',
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
                            // Cash and Cheque------------------------------------------------
                            Row(
                              children: [
                                Expanded(
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    elevation: 5,
                                    color: Color(0xFF1497E8),
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
                                                      '₱ ${NumberFormat('#,##0.00').format(todayCash)}',
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
                                    color: Color(0xFF1497E8),
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
                                                      '₱ ${NumberFormat('#,##0.00').format(todayCheque)}',
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
                            // Sales BarChart Month-------------------------------------------
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(40),
                                      topLeft: Radius.circular(40)
                                  ),
                                ),
                                elevation: 5,
                                color: Color(0xFF1497E8),
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
                                              isVisible: false,
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
                                                dataLabelSettings: DataLabelSettings(
                                                  color: Colors.white,
                                                  isVisible: true,
                                                  textStyle: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 8,
                                                  ),
                                                ),
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
                            // Expenses
                            Row(
                              children: [
                                Expanded(
                                  child: Card(
                                    elevation: 5,
                                    color: Color(0xFF1497E8),
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
                                                    '₱ ${NumberFormat('#,##0.00').format(todayExpense)}',
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
                            // Expenses Month----------------------------------------------
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(40),
                                      topLeft: Radius.circular(40)
                                  ),
                                ),
                                elevation: 5,
                                color: Color(0xFF1497E8),
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
                                            "Expenses of $formattedCurrentMonth",
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
                                              isVisible: false,
                                              labelStyle: TextStyle(
                                                color: Colors.white, // Set the color of the labels to white
                                              ),
                                            ),
                                            series: <CartesianSeries>[ // Corrected type here
                                              ColumnSeries<ExpenMonthData, String>(
                                                dataSource: _chartMonthExpenseData,
                                                xValueMapper: (ExpenMonthData exp, _) => exp.dayName,
                                                yValueMapper: (ExpenMonthData exp, _) => exp.amount,
                                                color: Colors.white,
                                                dataLabelSettings: DataLabelSettings(
                                                  color: Colors.white,
                                                  isVisible: true,
                                                  textStyle: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 8,
                                                  ),
                                                ),
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
                            // Disbursement
                            Row(
                              children: [
                                Expanded(
                                  child: Card(
                                    elevation: 5,
                                    color: Color(0xFF1497E8),
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
                                              "Disbursement",
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
                                                    '₱ ${NumberFormat('#,##0.00').format(todayDisbursement)}',
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
                            // Sales of the year----------------------------------------------
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(40),
                                      topLeft: Radius.circular(40)
                                  ),
                                ),
                                elevation: 5,
                                color: Color(0xFF1497E8),
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
                                              numberFormat: NumberFormat.currency(locale: 'en_PH', symbol: '₱ '), // Set currency format
                                            ),
                                            series: <CartesianSeries>[
                                              ColumnSeries<SalesYearData, String>(
                                                dataSource: _chartYearData,
                                                xValueMapper: (SalesYearData sales, _) => sales.monthName,
                                                yValueMapper: (SalesYearData sales, _) => sales.amount,
                                                color: Colors.white,
                                                dataLabelSettings: DataLabelSettings(
                                                  color: Colors.white,
                                                  isVisible: true,
                                                  textStyle: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 8,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              SizedBox(width: 5),
                                              Text(
                                                'Months',
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
                            SizedBox(height: 20),
                            // Patients Data--------------------------------------------------
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
                            // IPD and OPD----------------------------------------------------
                            Row(
                              children: [
                                Expanded(
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    elevation: 5,
                                    color: Color(0xFFFFFFFF),
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
                                                      color: Colors.black,
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
                                                    color: Colors.black,
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
                                    color: Color(0xFFFFFFFF),
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
                                                      color: Colors.black,
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
                                                    color: Colors.black,
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
                            // PHIC and HMO---------------------------------------------------
                            Row(
                              children: [
                                Expanded(
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    elevation: 5,
                                    color: Color(0xFFFFFFFF),
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
                                                      color: Colors.black,
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
                                                    color: Colors.black,
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
                                    color: Color(0xFFFFFFFF),
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
                                                      color: Colors.black,
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
                                                    color: Colors.black,
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
                            // Company and Senior---------------------------------------------
                            Row(
                              children: [
                                Expanded(
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    elevation: 5,
                                    color: Color(0xFFFFFFFF),
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
                                                      color: Colors.black,
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
                                                    color: Colors.black,
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
                                    color: Color(0xFFFFFFFF),
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
                                                      color: Colors.black,
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
                                                    color: Colors.black,
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
                            // Insurance of the Day and Month---------------------------------
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(40),
                                      topLeft: Radius.circular(40)
                                  ),
                                ),
                                elevation: 0,
                                color: Color(0xFF1497E8),
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
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          Container(
                                            height: 320, // Adjust the height as needed
                                            child: ListView.separated(
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
                                                    color: Color(0xFFFFFFFF),
                                                    child: ListTile(
                                                      title: Text(
                                                        todayInsurance.name,
                                                        style: SafeGoogleFont(
                                                          'Urbanist',
                                                          fontSize: 15 * size,
                                                          height: 1.2 * size / sizeAxis,
                                                          color: Colors.black,
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
                                              separatorBuilder: (context, index) {
                                                return SizedBox(height: 10); // Adjust the height as needed
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
                                                    borderRadius: BorderRadius.only(
                                                        bottomRight: Radius.circular(40),
                                                        topLeft: Radius.circular(40)
                                                    ),
                                                  ),
                                                  color: Color(0xFFFFFFFF),
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
                                                                  color: Color(0xFF000000),
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
                                                                        color: Colors.black,
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
                            SizedBox(height: 20),
                            // PHIC Trans
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
                                    color: Color(0xFF1497E8),
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
                                                    PieSeries<PHIC_ChartData, String>(
                                                      strokeWidth: 5,
                                                      strokeColor: Colors.white,
                                                      dataSource: <PHIC_ChartData>[
                                                        PHIC_ChartData('Total Claim Amount', todayClaimAmount),
                                                        PHIC_ChartData('PF', todayPF),
                                                      ],
                                                      xValueMapper: (PHIC_ChartData data, _) => data.name,
                                                      yValueMapper: (PHIC_ChartData data, _) => data.value,
                                                      pointRadiusMapper: (PHIC_ChartData data, _) {
                                                        double maxValue = calculateMaxValue([
                                                          PHIC_ChartData('Total Claim Amount', todayClaimAmount),
                                                          PHIC_ChartData('PF', todayPF),
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
                                                      dataLabelMapper: (PHIC_ChartData data, _) {
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
                                                  '$todayClaimCount',
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
                                                  '₱ ${NumberFormat('#,##0.00').format(todayClaimAmount)}',
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
                                                  '₱ ${NumberFormat('#,##0.00').format(todayPF)}',
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
                            // Transmittal Month----------------------------------------------
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(40),
                                      topLeft: Radius.circular(40)
                                  ),
                                ),
                                elevation: 5,
                                color: Color(0xFF1497E8),
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
                                              isVisible: false,
                                              labelStyle: TextStyle(
                                                color: Colors.white, // Set the color of the labels to white
                                              ),
                                            ),
                                            series: <CartesianSeries>[ // Corrected type here
                                              ColumnSeries<TransMonthData, String>(
                                                dataSource: _chartMonthTransData,
                                                xValueMapper: (TransMonthData trans, _) => trans.dayName,
                                                yValueMapper: (TransMonthData trans, _) => trans.amount,
                                                color: Colors.white,
                                                dataLabelSettings: DataLabelSettings(
                                                  color: Colors.white,
                                                  isVisible: true,
                                                  textStyle: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 8,
                                                  ),
                                                ),
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
                            // KPI -----------------------------------------------------------
                            Container(
                              margin: EdgeInsets.fromLTRB(
                                  5 * sizeAxis, 10 * sizeAxis, 0 * sizeAxis, 0 * sizeAxis),
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Key Performance Indicator",
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
                            ListView.separated(
                              shrinkWrap: true,
                              itemCount: kpiData.length,
                              physics: NeverScrollableScrollPhysics(), // Disable scrolling

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
                                      borderRadius: BorderRadius.only(
                                          bottomRight: Radius.circular(40),
                                          topLeft: Radius.circular(40)
                                      ),
                                    ),
                                    elevation: 5,
                                    color: Color(0xFFFFFFFF),
                                    child: ListTile(
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 10),
                                          Text(
                                            kpi.statusType,
                                            style: SafeGoogleFont(
                                              'Urbanist',
                                              fontSize: 15 * size,
                                              height: 1.2 * size / sizeAxis,
                                              color: Colors.black,
                                            ),
                                          ),
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
                                                      color: Colors.black,
                                                      thicknessUnit: GaugeSizeUnit.factor,
                                                    ),
                                                    ranges: <GaugeRange>[
                                                      GaugeRange(
                                                        startValue: 0,
                                                        endValue: 150,
                                                        color: Color(0xFF64B5F6), // 60% - Light Blue
                                                        startWidth: 5,
                                                        endWidth: 30,
                                                      ),
                                                      GaugeRange(
                                                        startValue: 150,
                                                        endValue: 350,
                                                        color: Color(0xFF1976D2), // 30% - Dark Blue
                                                        startWidth: 5,
                                                        endWidth: 30,
                                                      ),
                                                      GaugeRange(
                                                        startValue: 350,
                                                        endValue: 500,
                                                        color: Color(0xFF0D47A1), // 10% - Deep Blue
                                                        startWidth: 5,
                                                        endWidth: 30,
                                                      ),
                                                    ],
                                                    pointers: <GaugePointer>[
                                                      NeedlePointer(
                                                        value: kpi.value.toDouble(), // Assuming kpi.value is accessible here
                                                        needleColor: Colors.black, // Use the defined color
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
                                                            color: Colors.black,
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
                              separatorBuilder: (context, index) {
                                return SizedBox(height: 10); // Adjust the height as needed
                              },
                            ),
                            SizedBox(height: 20),
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
      ),
    );
  }

  Future<void> _handleRefresh() async {
    await _getUserData();
    await _getHospitalNameData();
    await _getAvatarData();
    await fetchTodaySales();
    await fetchTodayCash();
    await fetchTodayCheque();
    // await fetchMonthSalesChart();
    await fetchTodayExpense();
    // await fetchExpenseMONTH();
    await fetchTodayDisbursement();
    // await fetchYearSalesChart();
    await fetchToday_IPD();
    await fetchToday_OPD();
    await fetchToday_PHIC();
    await fetchToday_HMO();
    await fetchToday_COMPANY();
    await fetchToday_SENIOR();
    await fetchInsuranceTODAY();
    await fetchInsuranceMONTH();
    await fetchClaimAmountToday();
    await fetchTodayPF();
    // await fetchPHICTransmittalMONTH_Chart();
    await fetchKPI();
    setState(() {});
    return await Future.delayed(Duration(seconds: 2));
  }
}

class PHIC_ChartData {
  PHIC_ChartData(this.name, this.value);

  final String name;
  final double value;
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

class ExpenMonthData {
  ExpenMonthData(this.dayName, this.amount);

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
      name: json['name'] ?? 'No Name',
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