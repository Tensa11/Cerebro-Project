// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';
//
// class AddPatient extends StatefulWidget {
//   const AddPatient({super.key});
//
//   @override
//   _AddPatientState createState() => _AddPatientState();
// }
//
// class _AddPatientState extends State<AddPatient> {
//   double baseWidth = 375;
//   double sizeAxis = 1.0;
//   double size = 1.0;
//
//   late TextEditingController dobController;
//   String? selectedGender;
//
//   TextEditingController firstNameController =
//       TextEditingController(); // Add a TextEditingController for the reference input
//   TextEditingController lastNameController = TextEditingController();
//   TextEditingController addressController = TextEditingController();
//   TextEditingController statusController = TextEditingController();
//   TextEditingController phoneController = TextEditingController();
//   TextEditingController emailController = TextEditingController();
//   TextEditingController emergencyController = TextEditingController();
//   TextEditingController docController = TextEditingController();
//   TextEditingController roomController = TextEditingController();
//
//   String getCurrentDateTime() {
//     DateTime now = DateTime.now();
//     String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
//     return formattedDate;
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     dobController = TextEditingController();
//   }
//
//   @override
//   void dispose() {
//     dobController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(1900),
//       lastDate: DateTime.now(),
//     );
//     if (picked != null && picked != DateTime.now()) {
//       setState(() {
//         dobController.text = picked.toString().substring(0, 10);
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     sizeAxis = MediaQuery.of(context).size.width / baseWidth;
//     size = sizeAxis * 0.97;
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: SizedBox(
//           width: double.infinity,
//           child: Container(
//             padding: EdgeInsets.fromLTRB(
//                 22 * sizeAxis, 28 * sizeAxis, 21 * sizeAxis, 180 * sizeAxis),
//             width: double.infinity,
//             decoration: const BoxDecoration(
//               color: Color(0xffffffff),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Container(
//                   margin: EdgeInsets.fromLTRB(
//                       10 * sizeAxis, 0 * sizeAxis, 3 * sizeAxis, 30 * sizeAxis),
//                   width: double.infinity,
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Container(
//                         margin: EdgeInsets.fromLTRB(0 * sizeAxis, 25 * sizeAxis,
//                             200 * sizeAxis, 0 * sizeAxis),
//                         child: TextButton(
//                           onPressed: () {
//                             Navigator.of(context).pop();
//                           },
//                           style: TextButton.styleFrom(
//                             padding: EdgeInsets.zero,
//                           ),
//                           child: Container(
//                             width: 48 * sizeAxis,
//                             height: 48 * sizeAxis,
//                             decoration: BoxDecoration(
//                               borderRadius:
//                                   BorderRadius.circular(24 * sizeAxis),
//                               image: const DecorationImage(
//                                 fit: BoxFit.cover,
//                                 image: AssetImage(
//                                   'assets/images/back.png',
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   margin: EdgeInsets.fromLTRB(
//                       0 * sizeAxis, 0 * sizeAxis, 150 * sizeAxis, 5 * sizeAxis),
//                   child: Text(
//                     'New Patient',
//                     style: GoogleFonts.urbanist(
//                       fontSize: 30 * size,
//                       fontWeight: FontWeight.w700,
//                       height: 1.3 * size / sizeAxis,
//                       letterSpacing: -0.3 * sizeAxis,
//                       color: const Color(0xff0272bc),
//                     ),
//                   ),
//                 ),
//                 Container(
//                   margin: EdgeInsets.fromLTRB(5 * sizeAxis, 0 * sizeAxis,
//                       150 * sizeAxis, 15 * sizeAxis),
//                   constraints: BoxConstraints(
//                     maxWidth: 330 * sizeAxis,
//                   ),
//                   child: Text(
//                     'Add Patients details to fill up the needed details',
//                     style: GoogleFonts.inter(
//                       fontSize: 13 * size,
//                       fontWeight: FontWeight.w400,
//                       height: 1.5384615385 * size / sizeAxis,
//                       color: const Color(0xff1e232c),
//                     ),
//                   ),
//                 ),
//                 Container(
//                   margin: EdgeInsets.fromLTRB(
//                       1 * sizeAxis, 0 * sizeAxis, 0 * sizeAxis, 15 * sizeAxis),
//                   width: double.infinity,
//                   height: 56 * sizeAxis,
//                   decoration: BoxDecoration(
//                     border: Border.all(color: const Color(0xffe8ecf4)),
//                     color: const Color(0xfff7f7f8),
//                     borderRadius: BorderRadius.circular(8 * sizeAxis),
//                   ),
//                   child: TextField(
//                     controller: firstNameController,
//                     decoration: InputDecoration(
//                       border: InputBorder.none,
//                       focusedBorder: InputBorder.none,
//                       enabledBorder: InputBorder.none,
//                       errorBorder: InputBorder.none,
//                       disabledBorder: InputBorder.none,
//                       contentPadding: EdgeInsets.fromLTRB(18 * sizeAxis,
//                           17 * sizeAxis, 16 * sizeAxis, 17 * sizeAxis),
//                       hintText: 'First Name',
//                       hintStyle: const TextStyle(color: Color(0xff8390a1)),
//                     ),
//                     style: GoogleFonts.urbanist(
//                       fontSize: 15 * size,
//                       fontWeight: FontWeight.w500,
//                       height: 1.25 * size / sizeAxis,
//                       color: const Color(0xffef3924),
//                     ),
//                   ),
//                 ),
//                 Container(
//                   margin: EdgeInsets.fromLTRB(
//                       1 * sizeAxis, 0 * sizeAxis, 0 * sizeAxis, 15 * sizeAxis),
//                   width: double.infinity,
//                   height: 56 * sizeAxis,
//                   decoration: BoxDecoration(
//                     border: Border.all(color: const Color(0xffe8ecf4)),
//                     color: const Color(0xfff7f7f8),
//                     borderRadius: BorderRadius.circular(8 * sizeAxis),
//                   ),
//                   child: TextField(
//                     controller: lastNameController,
//                     decoration: InputDecoration(
//                       border: InputBorder.none,
//                       focusedBorder: InputBorder.none,
//                       enabledBorder: InputBorder.none,
//                       errorBorder: InputBorder.none,
//                       disabledBorder: InputBorder.none,
//                       contentPadding: EdgeInsets.fromLTRB(18 * sizeAxis,
//                           17 * sizeAxis, 16 * sizeAxis, 17 * sizeAxis),
//                       hintText: 'Last Name',
//                       hintStyle: const TextStyle(color: Color(0xff8390a1)),
//                     ),
//                     style: GoogleFonts.urbanist(
//                       fontSize: 15 * size,
//                       fontWeight: FontWeight.w500,
//                       height: 1.25 * size / sizeAxis,
//                       color: const Color(0xffef3924),
//                     ),
//                   ),
//                 ),
//                 // Date of Birth Field
//                 GestureDetector(
//                   onTap: () => _selectDate(context),
//                   child: Container(
//                     margin: EdgeInsets.fromLTRB(1 * sizeAxis, 0 * sizeAxis,
//                         0 * sizeAxis, 15 * sizeAxis),
//                     width: double.infinity,
//                     height: 56 * sizeAxis,
//                     decoration: BoxDecoration(
//                       border: Border.all(color: const Color(0xffe8ecf4)),
//                       color: const Color(0xfff7f7f8),
//                       borderRadius: BorderRadius.circular(8 * sizeAxis),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Padding(
//                           padding: EdgeInsets.only(left: 18 * sizeAxis),
//                           child: Text(
//                             dobController.text.isEmpty
//                                 ? 'Date of Birth'
//                                 : dobController.text,
//                             style: TextStyle(
//                               fontSize: 15 * sizeAxis,
//                               height: 1.25 * sizeAxis,
//                               color: dobController.text.isEmpty
//                                   ? const Color(0xff8390a1)
//                                   : const Color(0xffef3924),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 // Gender Field
//                 Container(
//                   margin: EdgeInsets.fromLTRB(
//                       1 * sizeAxis, 0 * sizeAxis, 0 * sizeAxis, 15 * sizeAxis),
//                   width: double.infinity,
//                   height: 56 * sizeAxis,
//                   decoration: BoxDecoration(
//                     border: Border.all(color: const Color(0xffe8ecf4)),
//                     color: const Color(0xfff7f7f8),
//                     borderRadius: BorderRadius.circular(8 * sizeAxis),
//                   ),
//                   child: DropdownButtonFormField<String>(
//                     decoration: InputDecoration(
//                       border: InputBorder.none,
//                       contentPadding: EdgeInsets.fromLTRB(18 * sizeAxis,
//                           17 * sizeAxis, 16 * sizeAxis, 17 * sizeAxis),
//                       hintText: 'Gender',
//                       hintStyle: TextStyle(color: const Color(0xff8390a1)),
//                     ),
//                     value: selectedGender,
//                     icon: const Icon(Icons.arrow_drop_down,
//                         color: Color(0xff8390a1)),
//                     iconSize: 24 * sizeAxis,
//                     elevation: 16,
//                     style: TextStyle(
//                       fontSize: 15 * sizeAxis,
//                       height: 1.25 * sizeAxis,
//                       color: const Color(0xffef3924),
//                     ),
//                     onChanged: (String? newValue) {
//                       setState(() {
//                         selectedGender = newValue;
//                       });
//                     },
//                     items: <String>['Male', 'Female', 'Other']
//                         .map<DropdownMenuItem<String>>((String value) {
//                       return DropdownMenuItem<String>(
//                         value: value,
//                         child: Text(value),
//                       );
//                     }).toList(),
//                   ),
//                 ),
//                 Container(
//                   margin: EdgeInsets.fromLTRB(0 * sizeAxis, 20 * sizeAxis,
//                       150 * sizeAxis, 15 * sizeAxis),
//                   child: Text(
//                     'Contact Information',
//                     style: GoogleFonts.urbanist(
//                       fontSize: 18 * size,
//                       fontWeight: FontWeight.w700,
//                       height: 1.3 * size / sizeAxis,
//                       letterSpacing: -0.3 * sizeAxis,
//                       color: const Color(0xff0272bc),
//                     ),
//                   ),
//                 ),
//                 Container(
//                   margin: EdgeInsets.fromLTRB(
//                       1 * sizeAxis, 0 * sizeAxis, 0 * sizeAxis, 15 * sizeAxis),
//                   width: double.infinity,
//                   height: 56 * sizeAxis,
//                   decoration: BoxDecoration(
//                     border: Border.all(color: const Color(0xffe8ecf4)),
//                     color: const Color(0xfff7f7f8),
//                     borderRadius: BorderRadius.circular(8 * sizeAxis),
//                   ),
//                   child: TextField(
//                     controller: addressController,
//                     decoration: InputDecoration(
//                       border: InputBorder.none,
//                       focusedBorder: InputBorder.none,
//                       enabledBorder: InputBorder.none,
//                       errorBorder: InputBorder.none,
//                       disabledBorder: InputBorder.none,
//                       contentPadding: EdgeInsets.fromLTRB(18 * sizeAxis,
//                           17 * sizeAxis, 16 * sizeAxis, 17 * sizeAxis),
//                       hintText: 'Address',
//                       hintStyle: const TextStyle(color: Color(0xff8390a1)),
//                     ),
//                     style: GoogleFonts.urbanist(
//                       fontSize: 15 * size,
//                       fontWeight: FontWeight.w500,
//                       height: 1.25 * size / sizeAxis,
//                       color: const Color(0xffef3924),
//                     ),
//                   ),
//                 ),
//                 Container(
//                   margin: EdgeInsets.fromLTRB(
//                       1 * sizeAxis, 0 * sizeAxis, 0 * sizeAxis, 15 * sizeAxis),
//                   width: double.infinity,
//                   height: 56 * sizeAxis,
//                   decoration: BoxDecoration(
//                     border: Border.all(color: const Color(0xffe8ecf4)),
//                     color: const Color(0xfff7f7f8),
//                     borderRadius: BorderRadius.circular(8 * sizeAxis),
//                   ),
//                   child: TextField(
//                     controller: phoneController,
//                     decoration: InputDecoration(
//                       border: InputBorder.none,
//                       focusedBorder: InputBorder.none,
//                       enabledBorder: InputBorder.none,
//                       errorBorder: InputBorder.none,
//                       disabledBorder: InputBorder.none,
//                       contentPadding: EdgeInsets.fromLTRB(18 * sizeAxis,
//                           17 * sizeAxis, 16 * sizeAxis, 17 * sizeAxis),
//                       hintText: 'Phone Number',
//                       hintStyle: const TextStyle(color: Color(0xff8390a1)),
//                     ),
//                     style: GoogleFonts.urbanist(
//                       fontSize: 15 * size,
//                       fontWeight: FontWeight.w500,
//                       height: 1.25 * size / sizeAxis,
//                       color: const Color(0xffef3924),
//                     ),
//                   ),
//                 ),
//                 Container(
//                   margin: EdgeInsets.fromLTRB(
//                       1 * sizeAxis, 0 * sizeAxis, 0 * sizeAxis, 15 * sizeAxis),
//                   width: double.infinity,
//                   height: 56 * sizeAxis,
//                   decoration: BoxDecoration(
//                     border: Border.all(color: const Color(0xffe8ecf4)),
//                     color: const Color(0xfff7f7f8),
//                     borderRadius: BorderRadius.circular(8 * sizeAxis),
//                   ),
//                   child: TextField(
//                     controller: emailController,
//                     decoration: InputDecoration(
//                       border: InputBorder.none,
//                       focusedBorder: InputBorder.none,
//                       enabledBorder: InputBorder.none,
//                       errorBorder: InputBorder.none,
//                       disabledBorder: InputBorder.none,
//                       contentPadding: EdgeInsets.fromLTRB(18 * sizeAxis,
//                           17 * sizeAxis, 16 * sizeAxis, 17 * sizeAxis),
//                       hintText: 'Email Address',
//                       hintStyle: const TextStyle(color: Color(0xff8390a1)),
//                     ),
//                     style: GoogleFonts.urbanist(
//                       fontSize: 15 * size,
//                       fontWeight: FontWeight.w500,
//                       height: 1.25 * size / sizeAxis,
//                       color: const Color(0xffef3924),
//                     ),
//                   ),
//                 ),
//                 Container(
//                   margin: EdgeInsets.fromLTRB(0 * sizeAxis, 20 * sizeAxis,
//                       110 * sizeAxis, 15 * sizeAxis),
//                   child: Text(
//                     'Health-care Information',
//                     style: GoogleFonts.urbanist(
//                       fontSize: 18 * size,
//                       fontWeight: FontWeight.w700,
//                       height: 1.3 * size / sizeAxis,
//                       letterSpacing: -0.3 * sizeAxis,
//                       color: const Color(0xff0272bc),
//                     ),
//                   ),
//                 ),
//                 Container(
//                   margin: EdgeInsets.fromLTRB(
//                       1 * sizeAxis, 0 * sizeAxis, 0 * sizeAxis, 15 * sizeAxis),
//                   width: double.infinity,
//                   height: 56 * sizeAxis,
//                   decoration: BoxDecoration(
//                     border: Border.all(color: const Color(0xffe8ecf4)),
//                     color: const Color(0xfff7f7f8),
//                     borderRadius: BorderRadius.circular(8 * sizeAxis),
//                   ),
//                   child: TextField(
//                     controller: emergencyController,
//                     decoration: InputDecoration(
//                       border: InputBorder.none,
//                       focusedBorder: InputBorder.none,
//                       enabledBorder: InputBorder.none,
//                       errorBorder: InputBorder.none,
//                       disabledBorder: InputBorder.none,
//                       contentPadding: EdgeInsets.fromLTRB(18 * sizeAxis,
//                           17 * sizeAxis, 16 * sizeAxis, 17 * sizeAxis),
//                       hintText: 'Emergency Contact',
//                       hintStyle: const TextStyle(color: Color(0xff8390a1)),
//                     ),
//                     style: GoogleFonts.urbanist(
//                       fontSize: 15 * size,
//                       fontWeight: FontWeight.w500,
//                       height: 1.25 * size / sizeAxis,
//                       color: const Color(0xffef3924),
//                     ),
//                   ),
//                 ),
//
//                 Container(
//                   margin: EdgeInsets.fromLTRB(
//                       1 * sizeAxis, 0 * sizeAxis, 0 * sizeAxis, 15 * sizeAxis),
//                   width: double.infinity,
//                   height: 56 * sizeAxis,
//                   decoration: BoxDecoration(
//                     border: Border.all(color: const Color(0xffe8ecf4)),
//                     color: const Color(0xfff7f7f8),
//                     borderRadius: BorderRadius.circular(8 * sizeAxis),
//                   ),
//                   child: TextField(
//                     controller: docController,
//                     decoration: InputDecoration(
//                       border: InputBorder.none,
//                       focusedBorder: InputBorder.none,
//                       enabledBorder: InputBorder.none,
//                       errorBorder: InputBorder.none,
//                       disabledBorder: InputBorder.none,
//                       contentPadding: EdgeInsets.fromLTRB(18 * sizeAxis,
//                           17 * sizeAxis, 16 * sizeAxis, 17 * sizeAxis),
//                       hintText: 'Assigned Doctor',
//                       hintStyle: const TextStyle(color: Color(0xff8390a1)),
//                     ),
//                     style: GoogleFonts.urbanist(
//                       fontSize: 15 * size,
//                       fontWeight: FontWeight.w500,
//                       height: 1.25 * size / sizeAxis,
//                       color: const Color(0xffef3924),
//                     ),
//                   ),
//                 ),
//
//                 Container(
//                   margin: EdgeInsets.fromLTRB(
//                       1 * sizeAxis, 0 * sizeAxis, 0 * sizeAxis, 15 * sizeAxis),
//                   width: double.infinity,
//                   height: 56 * sizeAxis,
//                   decoration: BoxDecoration(
//                     border: Border.all(color: const Color(0xffe8ecf4)),
//                     color: const Color(0xfff7f7f8),
//                     borderRadius: BorderRadius.circular(8 * sizeAxis),
//                   ),
//                   child: TextField(
//                     controller: roomController,
//                     decoration: InputDecoration(
//                       border: InputBorder.none,
//                       focusedBorder: InputBorder.none,
//                       enabledBorder: InputBorder.none,
//                       errorBorder: InputBorder.none,
//                       disabledBorder: InputBorder.none,
//                       contentPadding: EdgeInsets.fromLTRB(18 * sizeAxis,
//                           17 * sizeAxis, 16 * sizeAxis, 17 * sizeAxis),
//                       hintText: 'Room Assigned',
//                       hintStyle: const TextStyle(color: Color(0xff8390a1)),
//                     ),
//                     style: GoogleFonts.urbanist(
//                       fontSize: 15 * size,
//                       fontWeight: FontWeight.w500,
//                       height: 1.25 * size / sizeAxis,
//                       color: const Color(0xffef3924),
//                     ),
//                   ),
//                 ),
//                 Container(
//                   margin: EdgeInsets.fromLTRB(
//                       1 * sizeAxis, 0 * sizeAxis, 0 * sizeAxis, 15 * sizeAxis),
//                   width: double.infinity,
//                   height: 56 * sizeAxis,
//                   decoration: BoxDecoration(
//                     border: Border.all(color: const Color(0xffe8ecf4)),
//                     color: const Color(0xfff7f7f8),
//                     borderRadius: BorderRadius.circular(8 * sizeAxis),
//                   ),
//                   child: TextField(
//                     controller: statusController,
//                     decoration: InputDecoration(
//                       border: InputBorder.none,
//                       focusedBorder: InputBorder.none,
//                       enabledBorder: InputBorder.none,
//                       errorBorder: InputBorder.none,
//                       disabledBorder: InputBorder.none,
//                       contentPadding: EdgeInsets.fromLTRB(18 * sizeAxis,
//                           17 * sizeAxis, 16 * sizeAxis, 17 * sizeAxis),
//                       hintText: 'Status',
//                       hintStyle: const TextStyle(color: Color(0xff8390a1)),
//                     ),
//                     style: GoogleFonts.urbanist(
//                       fontSize: 15 * size,
//                       fontWeight: FontWeight.w500,
//                       height: 1.25 * size / sizeAxis,
//                       color: const Color(0xffef3924),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 25),
//                 Container(
//                   margin: EdgeInsets.fromLTRB(
//                       39 * sizeAxis, 0 * sizeAxis, 36 * sizeAxis, 0 * sizeAxis),
//                   child: TextButton(
//                     onPressed: () async {},
//                     style: TextButton.styleFrom(
//                       padding: EdgeInsets.zero,
//                     ),
//                     child: Container(
//                       width: double.infinity,
//                       height: 56 * sizeAxis,
//                       decoration: BoxDecoration(
//                         color: const Color(0xffef3924),
//                         borderRadius: BorderRadius.circular(30 * sizeAxis),
//                         boxShadow: [
//                           BoxShadow(
//                             color: const Color(0x14000000),
//                             offset: Offset(0 * sizeAxis, 20 * sizeAxis),
//                             blurRadius: 30 * sizeAxis,
//                           ),
//                         ],
//                       ),
//                       child: Center(
//                         child: Text(
//                           'Submit',
//                           textAlign: TextAlign.center,
//                           style: GoogleFonts.urbanist(
//                             fontSize: 16 * size,
//                             fontWeight: FontWeight.w600,
//                             height: 1.5 * size / sizeAxis,
//                             color: const Color(0xffffffff),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
