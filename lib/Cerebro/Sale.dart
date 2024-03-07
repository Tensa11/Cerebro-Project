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
  late double totalCash = 0;
  late double totalCheque = 0;
  late double totalSales = 0;
  late double totalExpense = 0;
  late double totalDisbursement = 0;
  late int ipd = 0;
  late int opd = 0;
  late int consultation = 0;

  @override
  void initState() {
    super.initState();
    fetchTotalSales();
    fetchTotalExpense();
    fetchTotalCollection();
    fetchTotalDisbursement();
    fetchPatients();
  }

  Future<void> fetchTotalSales() async {
    try {
      var url = Uri.parse('https://00bf-103-62-152-132.ngrok-free.app/sales/list?total=true');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        totalSales = double.parse(data['data'][0]['total']);
        setState(() {
          // Update the state with the fetched totalCash and totalCheque
        });
      } else {
        setState(() {
          // Handle error state if needed
        });
      }
    } catch (e) {
      setState(() {
        // Handle error state if needed
      });
    }
  }

  Future<void> fetchTotalCollection() async {
    try {
      var url = Uri.parse('https://00bf-103-62-152-132.ngrok-free.app/cashier/list?collection=true');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        totalCash = double.parse(data['data']['cash'][0]['total']);
        totalCheque = double.parse(data['data']['cheque'][0]['total']);
        setState(() {
          // Update the state with the fetched totalCash and totalCheque
        });
      } else {
        setState(() {
          // Handle error state if needed
        });
      }
    } catch (e) {
      setState(() {
        // Handle error state if needed
      });
    }
  }

  Future<void> fetchTotalExpense() async {
    try {
      var url = Uri.parse('https://00bf-103-62-152-132.ngrok-free.app/acc/expense');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        totalExpense = double.parse(data['data'][0]['expense']);
        setState(() {
          // Update the state with the fetched totalCash and totalCheque
        });
      } else {
        setState(() {
          // Handle error state if needed
        });
      }
    } catch (e) {
      setState(() {
        // Handle error state if needed
      });
    }
  }

  Future<void> fetchTotalDisbursement() async {
    try {
      var url = Uri.parse('https://00bf-103-62-152-132.ngrok-free.app/acc/expense');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        totalDisbursement = double.parse(data['data'][0]['expense']);
        setState(() {
          // Update the state with the fetched totalCash and totalCheque
        });
      } else {
        setState(() {
          // Handle error state if needed
        });
      }
    } catch (e) {
      setState(() {
        // Handle error state if needed
      });
    }
  }

  Future<void> fetchPatients() async {
    var url = Uri.parse('https://00bf-103-62-152-132.ngrok-free.app/patients');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['data'].length > 0) {
        setState(() {
          ipd = data['data'][0]['ipd'];
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
                0 * sizeAxis, 20 * sizeAxis, 0 * sizeAxis, 0 * sizeAxis),
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
                child: SingleChildScrollView(
                  // Wrap the Column with SingleChildScrollView
                  child: Column(
                    children: [
                      // 1st Row Card (1st and 2nd Card)
                      Row(
                        children: [
                          Expanded(
                            child: Card(
                              elevation: 5,
                              child: Stack(children: [
                                // Image.asset(
                                //   'assets/images/bgg1.jpg',
                                //   fit: BoxFit.cover,
                                //   width: 160,
                                //   height: 115,
                                // ),
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Sales',
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        '₱ ${totalSales.toStringAsFixed(2)}',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      // To provide spacing
                                      Text(
                                        '',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ]),
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
                                    SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Icon(Icons.attach_money),
                                        // Icon for the first collection
                                        SizedBox(width: 10),
                                        // Adjust spacing between icon and text
                                        Expanded(
                                          child: Text(
                                            '₱ ${totalCash.toStringAsFixed(2)}',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Icon(Icons.payment),
                                        // Icon for the second collection
                                        SizedBox(width: 10),
                                        // Adjust spacing between icon and text
                                        Expanded(
                                          child: Text(
                                            '₱ ${totalCheque.toStringAsFixed(2)}',
                                            style: TextStyle(fontSize: 14),
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
                                      '₱ ${totalExpense.toStringAsFixed(2)}',
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
                                'assets/images/bgg4.jpg',
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
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    // BarChart
                                    SfCartesianChart(
                                      primaryXAxis: CategoryAxis(
                                        labelStyle: TextStyle(
                                            color: Colors
                                                .black), // Set text color to white
                                      ),
                                      series: <ChartSeries>[
                                        ColumnSeries<SalesData, String>(
                                          dataSource: [
                                            SalesData('Jan', 213),
                                            SalesData('Feb', 54),
                                            SalesData('Mar', 213),
                                            SalesData('Apr', 54),
                                            SalesData('May', 250),
                                            SalesData('Jun', 32),
                                            SalesData('Jul', 879),
                                            SalesData('Aug', 45),
                                            SalesData('Sep', 876),
                                            SalesData('Oct', 453),
                                            SalesData('Nov', 12),
                                            SalesData('Dec', 42),
                                          ],
                                          xValueMapper: (SalesData sales, _) =>
                                              sales.year,
                                          yValueMapper: (SalesData sales, _) =>
                                              sales.sales,
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
