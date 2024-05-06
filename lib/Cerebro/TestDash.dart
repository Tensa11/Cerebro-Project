// import 'dart:math';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../util/utils.dart';
// import 'Drawer.dart';
// import 'appbar.dart';
//
// class TestDash extends StatefulWidget {
//   const TestDash({Key? key}) : super(key: key);
//
//   @override
//   _TestDashState createState() => _TestDashState();
// }
//
// class _TestDashState extends State<TestDash> {
//   int touchedIndex = -1;
//
//   @override
//   Widget build(BuildContext context) {
//     double baseWidth = 375;
//     double sizeAxis = MediaQuery.of(context).size.width / baseWidth;
//     double size = sizeAxis * 0.97;
//
//     return Scaffold(
//       // endDrawer: Drawer(
//       //   child: CereDrawer(),
//       // ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 30.0),
//         child: Column(
//           children: [
//             CustomAppBar(), // Replace the AppBar with the CustomAppBar
//             Container(
//               margin: EdgeInsets.fromLTRB(
//                   0 * sizeAxis, 40 * sizeAxis, 0 * sizeAxis, 0 * sizeAxis),
//               width: double.infinity,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Dashboard',
//                     style: SafeGoogleFont(
//                       'Urbanist',
//                       fontSize: 18 * size,
//                       fontWeight: FontWeight.w500,
//                       height: 1.2 * size / sizeAxis,
//                       color: const Color(0xff0272bc),
//                       decoration: TextDecoration.none,
//                     ),
//                   ),
//                   // const SizedBox(height: 10), // Add some space between the cards
//                 ],
//               ),
//             ),
//             // ListView Card with PieChart
//             Expanded(
//               child: ListView.builder(
//                 itemCount: 3,
//                 itemBuilder: (context, index) {
//                   if (index == 0) {
//                     return Card(
//                       elevation: 5,
//                       child: Stack(
//                         children: [
//                           // Image.asset(
//                           //   'assets/images/bgg2.jpg',
//                           //   fit: BoxFit.cover,
//                           //   width: 500,
//                           //   height: 295,
//                           // ),
//                           Padding(
//                             padding: const EdgeInsets.all(20.0),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'Pie Chart', // Add title for the PieChart
//                                   style: const TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 20),
//                                 AspectRatio(
//                                   aspectRatio: 1.5,
//                                   child: PieChart(
//                                     PieChartData(
//                                       pieTouchData: PieTouchData(
//                                         touchCallback: (FlTouchEvent event,
//                                             pieTouchResponse) {
//                                           setState(() {
//                                             if (!event
//                                                     .isInterestedForInteractions ||
//                                                 pieTouchResponse == null ||
//                                                 pieTouchResponse
//                                                         .touchedSection ==
//                                                     null) {
//                                               touchedIndex = -1;
//                                               return;
//                                             }
//                                             touchedIndex = pieTouchResponse
//                                                 .touchedSection!
//                                                 .touchedSectionIndex;
//                                           });
//                                         },
//                                       ),
//                                       sections: _generatePieChartData(),
//                                       // Generate data for the PieChart
//                                       borderData: FlBorderData(show: false),
//                                       sectionsSpace: 0,
//                                       centerSpaceRadius: 40,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }
//
//                   // Subtract 1 to adjust for the added PieChart card
//                   int adjustedIndex = index - 1;
//
//                   bool is3D = adjustedIndex % 2 == 0;
//
//                   String total = _generateTotal();
//                   List<double> chartData = _generateChartData(total);
//
//                   // Card for Total Registered
//                   return Padding(
//                     padding: const EdgeInsets.only(top: 20.0),
//                     // Add padding between the cards
//                     child: Card(
//                       elevation: 5,
//                       child: Stack(
//                         children: [
//                           // Image.asset(
//                           //   'assets/images/bgg2.jpg',
//                           //   fit: BoxFit.cover,
//                           //   width: 500,
//                           //   height: 210,
//                           // ),
//                           Padding(
//                             padding: const EdgeInsets.all(20.0),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text(
//                                       is3D ? 'Admins' : 'Patient',
//                                       style: const TextStyle(
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                     Text(
//                                       _totalAccData(is3D),
//                                       style: const TextStyle(
//                                         fontSize: 25,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 Text(
//                                   is3D
//                                       ? '20% Increased \nSince last 30 Days'
//                                       : '30% Increased \nSince last 30 Days',
//                                   style: const TextStyle(fontSize: 13),
//                                 ),
//                                 const SizedBox(height: 30),
//                                 Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Expanded(
//                                       child: SizedBox(
//                                         height: 70,
//                                         child: LineChart(
//                                           LineChartData(
//                                             gridData: FlGridData(show: false),
//                                             titlesData:
//                                                 FlTitlesData(show: false),
//                                             borderData:
//                                                 FlBorderData(show: false),
//                                             lineBarsData: [
//                                               LineChartBarData(
//                                                 spots: List.generate(
//                                                   chartData.length,
//                                                   (index) => FlSpot(
//                                                       index.toDouble(),
//                                                       chartData[index]),
//                                                 ),
//                                                 isCurved: true,
//                                                 curveSmoothness: 0.5,
//                                                 color: Colors.blue,
//                                                 barWidth: 3,
//                                                 isStrokeCapRound: true,
//                                                 belowBarData:
//                                                     BarAreaData(show: false),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   List<PieChartSectionData> _generatePieChartData() {
//     // Get the total data from _totalAccData
//     int totalAdmins = int.parse(_totalAccData(true));
//     int totalEmployee = int.parse(_totalAccData(false));
//     int total = totalAdmins + totalEmployee;
//
//     // Calculate percentages for each section
//     double adminsPercentage = totalAdmins / total * 100;
//     double EmployeePercentage = totalEmployee / total * 100;
//
//     // Define custom text style for the percentage labels
//     final TextStyle percentageTextStyle = SafeGoogleFont(
//       'Urbanist',
//       fontSize: 12,
//       fontWeight: FontWeight.bold,
//       decoration: TextDecoration.none,
//     );
//
//     // Generate PieChart data based on the total data
//     return [
//       PieChartSectionData(
//         color: Colors.blue,
//         value: adminsPercentage,
//         title: '${adminsPercentage.toStringAsFixed(0)}%',
//         // Round to nearest integer
//         radius: touchedIndex == 0 ? 60 : 50,
//         // Increase radius if touched
//         titlePositionPercentageOffset: 0.4,
//         // Adjusted position for admin percentage label
//         badgeWidget: _generateBadge('Admins'),
//         badgePositionPercentageOffset: 1,
//         titleStyle: percentageTextStyle, // Apply custom text style
//       ),
//       PieChartSectionData(
//         color: Colors.green,
//         value: EmployeePercentage,
//         title: '${EmployeePercentage.toStringAsFixed(0)}%',
//         // Round to nearest integer
//         radius: touchedIndex == 1 ? 60 : 50,
//         // Increase radius if touched
//         titlePositionPercentageOffset: 0.4,
//         // Adjusted position for hospital percentage label
//         badgeWidget: _generateBadge('Employee'),
//         badgePositionPercentageOffset: 1,
//         titleStyle: percentageTextStyle, // Apply custom text style
//       ),
//     ];
//   }
//
//   Widget _generateBadge(String type) {
//     IconData iconData = type == 'Admins' ? Icons.person : Icons.work;
//     Color iconColor = type == 'Admins' ? Colors.blue : Colors.green;
//     Color borderColor = Colors.white; // Border color
//
//     return Container(
//       padding: EdgeInsets.all(6),
//       decoration: BoxDecoration(
//         color: iconColor.withOpacity(1),
//         shape: BoxShape.circle,
//         border: Border.all(color: borderColor, width: 3), // Border decoration
//       ),
//       child: Icon(
//         iconData,
//         size: 18,
//         color: Colors.white,
//       ),
//     );
//   }
//
//   List<double> _generateChartData(String draw) {
//     // Generate chart data based on the draw numbers
//     List<double> data = [];
//     for (int i = 0; i < draw.length; i++) {
//       data.add(draw.codeUnitAt(i).toDouble());
//     }
//     return data;
//   }
//
//   String _totalAccData(bool is3D) {
//     int count = Random().nextInt(100) + 1;
//     return is3D ? '$count' : '$count';
//   }
//
//   String _generateTotal() {
//     return '${_generateRandomNumber()}-${_generateRandomNumber()}-${_generateRandomNumber()}';
//   }
//
//   int _generateRandomNumber() {
//     return DateTime.now().microsecondsSinceEpoch % 10;
//   }
// }
