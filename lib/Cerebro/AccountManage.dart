// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../util/utils.dart';
// import 'Drawer.dart';
// import 'appbar.dart'; // Import the custom app bar
//
// class ManageAdmin extends StatefulWidget {
//   const ManageAdmin({Key? key}) : super(key: key);
//
//   @override
//   _ManageAdminState createState() => _ManageAdminState();
// }
//
// class _ManageAdminState extends State<ManageAdmin> {
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
//         padding: const EdgeInsets.symmetric(horizontal: 25.0),
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
//                     'Admin Management',
//                     style: SafeGoogleFont(
//                       'Urbanist',
//                       fontSize: 18 * size,
//                       fontWeight: FontWeight.w500,
//                       height: 1.2 * size / sizeAxis,
//                       color: const Color(0xff0272bc),
//                       decoration: TextDecoration.none,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Expanded(
//               child: ListView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount: 4,
//                 itemBuilder: (BuildContext context, int index) {
//                   return Card(
//                     elevation: 3,
//                     child: ListTile(
//                       leading: const CircleAvatar(
//                         backgroundImage:
//                             AssetImage('assets/images/userCartoon.png'),
//                       ),
//                       title: Text(
//                         'Admin: Yusef',
//                         style: TextStyle(
//                           fontFamily: 'Inter',
//                           fontSize: 16,
//                           fontWeight: FontWeight.w700,
//                           color: const Color(0xffe33924),
//                           decoration: TextDecoration.none,
//                         ),
//                       ),
//                       subtitle: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           SizedBox(height: 5),
//                           Text(
//                             'Hospital: Maria Reyna',
//                             style: TextStyle(
//                               fontFamily: 'Urbanist',
//                               fontSize: 14,
//                               fontWeight: FontWeight.w500,
//                               color: const Color(0xff0272bc),
//                               decoration: TextDecoration.none,
//                             ),
//                           ),
//                           Text(
//                             'Address: Hayes St, CDO, Mis Or.',
//                             style: TextStyle(
//                               fontFamily: 'Urbanist',
//                               fontSize: 14,
//                               fontWeight: FontWeight.w500,
//                               color: const Color(0xff0272bc),
//                               decoration: TextDecoration.none,
//                             ),
//                           ),
//                           Text(
//                             'Contact: 09361247859',
//                             style: TextStyle(
//                               fontFamily: 'Urbanist',
//                               fontSize: 14,
//                               fontWeight: FontWeight.w500,
//                               color: const Color(0xff0272bc),
//                               decoration: TextDecoration.none,
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
// }
