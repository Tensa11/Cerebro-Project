import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../util/utils.dart';
import 'AddPatient.dart';
import 'Details.dart';
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
  late int totalIPD = 0;
  late int totalOPD = 0;
  late int totalPHCC = 0;
  late int totalHMO = 0;
  late int totalCOMPANY = 0;
  late int totalSENIOR = 0;
  late List<Insurance> insuranceTODAY = [];
  late double totalInsuranceMONTH = 0;

  @override
  void initState() {
    super.initState();
    fetchTotalSales();
    fetchTotalExpense();
    fetchTotalCollection();
    fetchTotalDisbursement();
    fetchSalesMonthChart();
    fetchSalesYearChart();
    fetchTotalIPD();
    fetchTotalOPD();
    fetchTotalPHCC();
    fetchTotalHMO();
    fetchTotalCOMPANY();
    fetchTotalSENIOR();
    fetchInsuranceTODAY();
    fetchInsuranceMONTH();
  }

  Future<void> fetchTotalSales() async {
    try {
      var url = Uri.parse('https://dea3-103-62-152-132.ngrok-free.app/sales/list?today=true');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        totalSales = double.parse(data['data'][0]['total']);
        setState(() {});
      } else {
        throw Exception('Failed to load total sales');
      }
    } catch (e) {
      print('Error fetching total sales: $e');
      setState(() {});
    }
  }

  Future<void> fetchTotalCollection() async {
    try {
      var url = Uri.parse('https://dea3-103-62-152-132.ngrok-free.app/cashier/list?today=true');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        totalCash = double.parse(data['data']['cash'][0]['total']);
        totalCheque = double.parse(data['data']['cheque'][0]['total']);
        setState(() {});
      } else {
        throw Exception('Failed to load total collection');
      }
    } catch (e) {
      print('Error fetching total collection: $e');
      setState(() {});
    }
  }

  List<SalesMonthData> _chartMonthData = [];
  final List<String> dayNames = List.generate(31, (index) => (index + 1).toString());

  Future<void> fetchSalesMonthChart() async {
    try {
      var url = Uri.parse('https://dea3-103-62-152-132.ngrok-free.app/sales/list?month=true');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        List<SalesMonthData> salesMonthData = List.generate(data['data'].length, (index) {
          String dayName = dayNames[data['data'][index]['day'] - 1];
          return SalesMonthData(
            dayName,
            double.parse(data['data'][index]['amount']),
          );
        });

        setState(() {
          _chartMonthData = salesMonthData;
        });
      } else {
        throw Exception('Failed to load monthly sales');
      }
    } catch (e) {
      print('Error fetching monthly sales: $e');
      setState(() {
        // Handle error state if needed
      });
    }
  }

  Future<void> fetchTotalExpense() async {
    try {
      var url = Uri.parse('https://dea3-103-62-152-132.ngrok-free.app/acc/expense/today');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        totalExpense = double.parse(data['data'][0]['expense']);
        setState(() {});
      } else {
        throw Exception('Failed to load total expense');
      }
    } catch (e) {
      print('Error fetching total expense: $e');
      setState(() {});
    }
  }

  Future<void> fetchTotalDisbursement() async {
    try {
      var url = Uri.parse('https://dea3-103-62-152-132.ngrok-free.app/disbursement/list?total=true');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        totalDisbursement = double.parse(data['data'][0]['total']);
        setState(() {});
      } else {
        throw Exception('Failed to load total disbursement');
      }
    } catch (e) {
      print('Error fetching total disbursement: $e');
      setState(() {});
    }
  }

  List<SalesYearData> _chartYearData = [];
  final List<String> monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  Future<void> fetchSalesYearChart() async {
    try {
      var url = Uri.parse('https://dea3-103-62-152-132.ngrok-free.app/sales/list?year=true');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        List<SalesYearData> salesYearData = List.generate(data['data'].length, (index) {
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
        throw Exception('Failed to load total sales');
      }
    } catch (e) {
      print('Error fetching total sales: $e');
      setState(() {
        // Handle error state if needed
      });
    }
  }

  Future<void> fetchTotalIPD() async {
    try {
      var url = Uri.parse('https://dea3-103-62-152-132.ngrok-free.app/stats/ipd');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        totalIPD = int.parse(data['data'][0]['count']);
        setState(() {});
      } else {
        throw Exception('Failed to load total disbursement');
      }
    } catch (e) {
      print('Error fetching total disbursement: $e');
      setState(() {});
    }
  }

  Future<void> fetchTotalOPD() async {
    try {
      var url = Uri.parse('https://dea3-103-62-152-132.ngrok-free.app/stats/opd');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        totalOPD = int.parse(data['data'][0]['count']);
        setState(() {});
      } else {
        throw Exception('Failed to load total disbursement');
      }
    } catch (e) {
      print('Error fetching total disbursement: $e');
      setState(() {});
    }
  }

  Future<void> fetchTotalPHCC() async {
    try {
      var url = Uri.parse('https://dea3-103-62-152-132.ngrok-free.app/stats/phic');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        totalPHCC = int.parse(data['data'][0]['count']);
        setState(() {});
      } else {
        throw Exception('Failed to load total disbursement');
      }
    } catch (e) {
      print('Error fetching total disbursement: $e');
      setState(() {});
    }
  }

  Future<void> fetchTotalHMO() async {
    try {
      var url = Uri.parse('https://dea3-103-62-152-132.ngrok-free.app/stats/hmo');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        totalHMO = int.parse(data['data'][0]['count']);
        setState(() {});
      } else {
        throw Exception('Failed to load total disbursement');
      }
    } catch (e) {
      print('Error fetching total disbursement: $e');
      setState(() {});
    }
  }

  Future<void> fetchTotalCOMPANY() async {
    try {
      var url = Uri.parse('https://dea3-103-62-152-132.ngrok-free.app/stats/company');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        totalCOMPANY = int.parse(data['data'][0]['count']);
        setState(() {});
      } else {
        throw Exception('Failed to load total disbursement');
      }
    } catch (e) {
      print('Error fetching total disbursement: $e');
      setState(() {});
    }
  }

  Future<void> fetchTotalSENIOR() async {
    try {
      var url = Uri.parse('https://dea3-103-62-152-132.ngrok-free.app/stats/senior_pwd');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        totalSENIOR = int.parse(data['data'][0]['count']);
        setState(() {});
      } else {
        throw Exception('Failed to load total disbursement');
      }
    } catch (e) {
      print('Error fetching total disbursement: $e');
      setState(() {});
    }
  }

  Future<void> fetchInsuranceTODAY() async {
    try {
      var url = Uri.parse('https://dea3-103-62-152-132.ngrok-free.app/fin/insurance');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        List<Insurance> fetchedInsuranceToday = List.generate(data['data'].length, (index) {
          return Insurance.fromJson(data['data'][index]);
        });

        setState(() {
          insuranceTODAY = fetchedInsuranceToday;
        });
      } else {
        throw Exception('Failed to load physicians');
      }
    } catch (e) {
      print('Error fetching physicians: $e');
    }
  }

  Future<void> fetchInsuranceMONTH() async {
    try {
      var url = Uri.parse('https://dea3-103-62-152-132.ngrok-free.app/fin/insurance?month=true');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        totalInsuranceMONTH = double.parse(data['data'][0]['amount']);
        setState(() {});
      } else {
        throw Exception('Failed to load total disbursement');
      }
    } catch (e) {
      print('Error fetching total disbursement: $e');
      setState(() {});
    }
  }

  String formattedCurrentDate = DateFormat('MMM yyyy').format(DateTime.now()).toUpperCase();
  String formattedCurrentYear = DateFormat('yyyy').format(DateTime.now()).toUpperCase();

  @override
  Widget build(BuildContext context) {
    double baseWidth = 375;
    double sizeAxis = MediaQuery.of(context).size.width / baseWidth;
    double size = sizeAxis * 0.97;

    return Scaffold(
      endDrawer: const Drawer(
        child: CereDrawer(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
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
                      'Dashboard',
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
              // Content 1
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
                ],
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
              // Sales BarChart Month
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Card(
                  elevation: 5,
                  child: Stack(
                    children: [
                      Image.asset(
                        'assets/images/bgg4.jpg',
                        fit: BoxFit.cover,
                        width: 500,
                        height: 410,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              formattedCurrentDate,
                              style: SafeGoogleFont(
                                'Urbanist',
                                fontSize: 16 * size,
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
                                  color: Colors.black,
                                ),
                              ),
                              series: <ChartSeries>[
                                ColumnSeries<SalesMonthData, String>(
                                  dataSource: _chartMonthData,
                                  xValueMapper: (SalesMonthData sales, _) => sales.dayName,
                                  yValueMapper: (SalesMonthData sales, _) => sales.amount,
                                  color: Colors.red,
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
                                    color: Colors.black,
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
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Card(
                  elevation: 5,
                  child: Stack(
                    children: [
                      Image.asset(
                        'assets/images/bgg4.jpg',
                        fit: BoxFit.cover,
                        width: 500,
                        height: 390,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Sales of $formattedCurrentYear",
                              style: SafeGoogleFont(
                                'Urbanist',
                                fontSize: 16 * size,
                                fontWeight: FontWeight.bold,
                                height: 1.2 * size / sizeAxis,
                                decoration: TextDecoration.none,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 20),
                            // LineChart with curved line and data labels
                            SfCartesianChart(
                              primaryXAxis: CategoryAxis(
                                labelStyle: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                              series: <ChartSeries>[
                                SplineSeries<SalesYearData, String>(
                                  dataSource: _chartYearData,
                                  xValueMapper: (SalesYearData sales, _) => sales.monthName,
                                  yValueMapper: (SalesYearData sales, _) => sales.amount,
                                  color: Colors.red,
                                  splineType: SplineType.monotonic,
                                  markerSettings: MarkerSettings(
                                    isVisible: true,
                                    color: Colors.red,
                                  ),
                                  dataLabelSettings: DataLabelSettings(
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
                              '$totalIPD',
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
                              '$totalOPD',
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
                              'PHCC',
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
                              '$totalPHCC',
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
                              'HMO',
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
                              '$totalHMO',
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
                              'Company',
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
                              '$totalCOMPANY',
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
                              'Senior',
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
                              '$totalSENIOR',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Content 2
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Card(
                  elevation: 5,
                  child: Stack(
                    children: [
                      Image.asset(
                        'assets/images/bgg4.jpg',
                        fit: BoxFit.cover,
                        width: 500,
                        height: 540,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Insurance of $formattedCurrentDate',
                              style: SafeGoogleFont(
                                'Urbanist',
                                fontSize: 16 * size,
                                fontWeight: FontWeight.bold,
                                height: 1.2 * size / sizeAxis,
                                decoration: TextDecoration.none,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 10),
                            Container(
                              height: 370, // Adjust the height as needed
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: insuranceTODAY.length,
                                itemBuilder: (context, index) {
                                  Insurance todayInsurance = insuranceTODAY[index];
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
                                        leading: const CircleAvatar(
                                          backgroundImage: AssetImage('assets/images/userCartoon.png'),
                                        ),
                                        title: Text(
                                          todayInsurance.name,
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xffe33924),
                                            decoration: TextDecoration.none,
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: 5),
                                            Text(
                                              todayInsurance.amount,
                                              style: TextStyle(
                                                fontFamily: 'Urbanist',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: const Color(0xff0272bc),
                                                decoration: TextDecoration.none,
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
                            Divider(),
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
                                            'Insurance Month',
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
                                            '₱ ${totalInsuranceMONTH.toStringAsFixed(2)}',
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
                    ],
                  ),
                ),
              ),

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
