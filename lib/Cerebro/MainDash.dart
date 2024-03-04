import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../util/utils.dart';
import 'Drawer.dart';
import 'appbar.dart';

class MainDash extends StatefulWidget {
  const MainDash({Key? key}) : super(key: key);

  @override
  _MainDashState createState() => _MainDashState();
}

class _MainDashState extends State<MainDash> {
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
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          children: [
            CustomAppBar(), // Replace the AppBar with the CustomAppBar
            Container(
              margin: EdgeInsets.fromLTRB(0 * sizeAxis, 40 * sizeAxis, 0 * sizeAxis, 0 * sizeAxis),
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
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 2,
                itemBuilder: (context, index) {
                  // Determine whether to render content for 3D or STL
                  bool is3D = index % 2 == 0;

                  String draw = _generateDraw(); // Generate a random draw
                  List<double> chartData = _generateChartData(draw);

                  return Card(
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                is3D ? 'Admins' : 'Hospitals', // Display 3D or STL
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _generateNumbersFinal(is3D),
                                style: const TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                            Text(
                            is3D ? '20% Increased \nSince last 30 Days' : '30% Increased \nSince last 30 Days', // Display 3D or STL
                            style: const TextStyle(fontSize: 13),
                          ),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded( // Wrap LineChart with Expanded
                                child: SizedBox(
                                  height: 70,
                                  child: LineChart(
                                    LineChartData(
                                      gridData: FlGridData(show: false),
                                      titlesData: FlTitlesData(show: false),
                                      borderData: FlBorderData(show: false),
                                      lineBarsData: [
                                        LineChartBarData(
                                          spots: List.generate(
                                            chartData.length,
                                                (index) => FlSpot(index.toDouble(), chartData[index]),
                                          ),
                                          isCurved: true,
                                          curveSmoothness: 0.5,
                                          colors: [Colors.blue],
                                          barWidth: 3,
                                          isStrokeCapRound: true,
                                          belowBarData: BarAreaData(show: false),
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<double> _generateChartData(String draw) {
    // Generate chart data based on the draw numbers
    List<double> data = [];
    for (int i = 0; i < draw.length; i++) {
      data.add(draw.codeUnitAt(i).toDouble());
    }
    return data;
  }

  // Function to generate numbers of admins or patients
  String _generateNumbersFinal(bool is3D) {
    int count = Random().nextInt(100) + 1; // Generate a random number between 1 and 100
    return is3D ? '$count' : '$count'; // Return count with appropriate label
  }

  // Function to generate random draw numbers
  String _generateDraw() {
    return '${_generateRandomNumber()}-${_generateRandomNumber()}-${_generateRandomNumber()}';
  }

  // Function to generate random number between 0 and 9
  int _generateRandomNumber() {
    return DateTime.now().microsecondsSinceEpoch % 10;
  }
}
