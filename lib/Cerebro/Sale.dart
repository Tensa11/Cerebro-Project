import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../util/utils.dart';
import 'Drawer.dart';
import 'appbar.dart';
import 'package:http/http.dart' as http;

class SaleDash extends StatefulWidget {
  const SaleDash({Key? key}) : super(key: key);

  @override
  _SaleDashState createState() => _SaleDashState();
}

class _SaleDashState extends State<SaleDash> {
  late double totalSales;
  late double totalDisbursement;
  late int ipd = 0;
  late int opd = 0;
  late int consultation = 0;

  @override
  void initState() {
    super.initState();
    totalSales = 0;
    totalDisbursement = 0;
    fetchSales();
    fetchDisbursement();
    fetchPatients();
  }

  Future<void> fetchSales() async {
    var url = Uri.parse('https://b54e-103-62-152-132.ngrok-free.app/sales/list');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      double total = 0;
      for (var item in data['data']) {
        total += double.parse(item['amount']);
      }
      setState(() {
        totalSales = total;
      });
    } else {
      setState(() {
        totalSales = 0;
      });
    }
  }

  Future<void> fetchDisbursement() async {
    var url = Uri.parse('https://b54e-103-62-152-132.ngrok-free.app/disbursement/list');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      double total = 0;
      for (var item in data['data']) {
        total += double.parse(item['amount']);
      }
      setState(() {
        totalDisbursement = total;
      });
    } else {
      setState(() {
        totalDisbursement = 0;
      });
    }
  }

  Future<void> fetchPatients() async {
    var url = Uri.parse('https://b54e-103-62-152-132.ngrok-free.app/patients/');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['data'].length > 0) {
        setState(() {
          ipd = data['data'][0]['idd'];
          opd = data['data'][0]['opd'];
          consultation = data['data'][0]['consultation'];
        });
      }
    } else {
      setState(() {
        ipd = 0;
        opd = 0;
      });
    }
  }

  String formattedDate = DateFormat('MMM dd yyyy').format(DateTime.now()).toUpperCase();

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
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          children: [
            CustomAppBar(), // Replace the AppBar with the CustomAppBar
            Container(
              margin: EdgeInsets.fromLTRB(
                0 * sizeAxis,
                40 * sizeAxis,
                0 * sizeAxis,
                0 * sizeAxis,
              ),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sale Dashboard',
                    style: SafeGoogleFont(
                      'Urbanist',
                      fontSize: 18 * size,
                      fontWeight: FontWeight.w500,
                      height: 1.2 * size / sizeAxis,
                      color: const Color(0xff0272bc),
                      decoration: TextDecoration.none,
                    ),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                child: SingleChildScrollView( // Wrap the Column with SingleChildScrollView
                  child: Column(
                    children: [
                      // 1st Row Card (1st and 2nd Card)
                      Row(
                        children: [
                          Expanded(
                            child: Card(
                              elevation: 5,
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Sales',
                                      style: SafeGoogleFont(
                                        'Urbanist',
                                        fontSize: 16 * size,
                                        fontWeight: FontWeight.bold,
                                        height: 1.2 * size / sizeAxis,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    // Text Content
                                    Text(
                                      '₱ ${totalSales.toStringAsFixed(2)}',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: Card(
                              elevation: 5,
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Collection',
                                      style: SafeGoogleFont(
                                        'Urbanist',
                                        fontSize: 16 * size,
                                        fontWeight: FontWeight.bold,
                                        height: 1.2 * size / sizeAxis,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    // Text Content
                                    Text(
                                      generateCollection(),
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      // 2nd Row Card (3rd and 4th Card)
                      Row(
                        children: [
                          Expanded(
                            child: Card(
                              elevation: 5,
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Expense',
                                      style: SafeGoogleFont(
                                        'Urbanist',
                                        fontSize: 16 * size,
                                        fontWeight: FontWeight.bold,
                                        height: 1.2 * size / sizeAxis,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    // Text Content
                                    Text(
                                      generateExpense(),
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: Card(
                              elevation: 5,
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Disbursement',
                                      style: SafeGoogleFont(
                                        'Urbanist',
                                        fontSize: 16 * size,
                                        fontWeight: FontWeight.bold,
                                        height: 1.2 * size / sizeAxis,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    // Text Content
                                    Text(
                                      '₱ ${totalDisbursement.toStringAsFixed(2)}',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        // Add padding between the cards
                        child: Card(
                          elevation: 5,
                          child: Stack(
                            children: [
                              Image.asset(
                                'assets/images/bgg11.jpg',
                                fit: BoxFit.cover,
                                width: 500,
                                height: 380,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      formattedDate,
                                      style: SafeGoogleFont(
                                        'Urbanist',
                                        fontSize: 14 * size,
                                        fontWeight: FontWeight.bold,
                                        height: 1.2 * size / sizeAxis,
                                        decoration: TextDecoration.none,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    // BarChart
                                    SfCartesianChart(
                                      primaryXAxis: CategoryAxis(
                                        labelStyle: TextStyle(color: Colors.white), // Set text color to white
                                      ),
                                      series: <ChartSeries>[
                                        ColumnSeries<SalesData, String>(
                                          dataSource: [
                                            SalesData('Jan', 200),
                                            SalesData('Feb', 300),
                                            SalesData('Mar', 150),
                                            SalesData('Apr', 32),
                                            SalesData('May', 250),
                                            SalesData('Jun', 32),
                                            SalesData('Jul', 223),
                                            SalesData('Aug', 250),
                                            SalesData('Sep', 250),
                                            SalesData('Oct', 123),
                                            SalesData('Nov', 532),
                                            SalesData('Dec', 42),
                                          ],
                                          xValueMapper: (SalesData sales, _) => sales.year,
                                          yValueMapper: (SalesData sales, _) => sales.sales,
                                          color: Colors.red,
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
                      Row(
                        children: [
                          Expanded(
                            child: Card(
                              elevation: 5,
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'IPD',
                                      style: SafeGoogleFont(
                                        'Urbanist',
                                        fontSize: 16 * size,
                                        fontWeight: FontWeight.bold,
                                        height: 1.2 * size / sizeAxis,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    // Text Content
                                    Text(
                                      '$ipd',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Card(
                              elevation: 5,
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'OPD',
                                      style: SafeGoogleFont(
                                        'Urbanist',
                                        fontSize: 16 * size,
                                        fontWeight: FontWeight.bold,
                                        height: 1.2 * size / sizeAxis,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    // Text Content
                                    Text(
                                      '$opd',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Card(
                              elevation: 5,
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Consults',
                                      style: SafeGoogleFont(
                                        'Urbanist',
                                        fontSize: 14 * size,
                                        fontWeight: FontWeight.bold,
                                        height: 1.2 * size / sizeAxis,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    // Text Content
                                    Text(
                                      '$consultation',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String generateCollection() {
    // Generate a random value between 1000 and 5000
    Random random = Random();
    int value = random.nextInt(4001) + 1000;

    // Format the value to include commas for thousands
    NumberFormat format = NumberFormat("#,##0", "en_US");
    String formattedValue = format.format(value);

    return '₱ $formattedValue';
  }

  String generateExpense() {
    // Generate a random value between 1000 and 5000
    Random random = Random();
    int value = random.nextInt(4001) + 1000;

    // Format the value to include commas for thousands
    NumberFormat format = NumberFormat("#,##0", "en_US");
    String formattedValue = format.format(value);

    return '₱ $formattedValue';
  }
}

class SalesData {
  SalesData(this.year, this.sales);

  final String year;
  final int sales;
}
