import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class CereAdd extends StatefulWidget {
  const CereAdd({super.key});

  @override
  _CereAddState createState() => _CereAddState();
}

class _CereAddState extends State<CereAdd> {
  double baseWidth = 375;
  double sizeAxis = 1.0;
  double size = 1.0;

  TextEditingController itemController = TextEditingController();
  TextEditingController dateTimeController = TextEditingController();
  TextEditingController amountController = TextEditingController();


  String generateRandomItem() {
    List<String> items = [
      'Coffee Mug',
      'Notebook',
      'Smartphone',
      'Sunglasses',
      'Water Bottle'
    ];
    Random random = Random();
    return items[random.nextInt(items.length)];
  }

  String getCurrentDateTime() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    return formattedDate;
  }

  @override
  void initState() {
    super.initState();
    itemController.text = generateRandomItem();
    dateTimeController.text = getCurrentDateTime();
  }

  @override
  Widget build(BuildContext context) {
    sizeAxis = MediaQuery.of(context).size.width / baseWidth;
    size = sizeAxis * 0.97;
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: Container(
            padding: EdgeInsets.fromLTRB(
                22 * sizeAxis, 28 * sizeAxis, 21 * sizeAxis, 180 * sizeAxis),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xffffffff),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(
                      10 * sizeAxis, 0 * sizeAxis, 3 * sizeAxis, 70 * sizeAxis),
                  width: double.infinity,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.fromLTRB(0 * sizeAxis, 0 * sizeAxis,
                            200 * sizeAxis, 0 * sizeAxis),
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                          ),
                          child: Container(
                            width: 48 * sizeAxis,
                            height: 48 * sizeAxis,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(24 * sizeAxis),
                              image: const DecorationImage(
                                fit: BoxFit.cover,
                                image: AssetImage(
                                  'assets/ipecs-mobile/images/userCartoon.png',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(
                      0 * sizeAxis, 0 * sizeAxis, 150 * sizeAxis, 4 * sizeAxis),
                  child: Text(
                    'Cashier Add',
                    style: GoogleFonts.urbanist(
                      fontSize: 30 * size,
                      fontWeight: FontWeight.w700,
                      height: 1.3 * size / sizeAxis,
                      letterSpacing: -0.3 * sizeAxis,
                      color: const Color(0xff1e232c),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0 * sizeAxis, 0 * sizeAxis,
                      200 * sizeAxis, 15 * sizeAxis),
                  constraints: BoxConstraints(
                    maxWidth: 330 * sizeAxis,
                  ),
                  child: Text(
                    'Add data to fill up \n'
                    'the needed details',
                    style: GoogleFonts.inter(
                      fontSize: 13 * size,
                      fontWeight: FontWeight.w400,
                      height: 1.5384615385 * size / sizeAxis,
                      color: const Color(0xff1e232c),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(
                      1 * sizeAxis, 0 * sizeAxis, 0 * sizeAxis, 15 * sizeAxis),
                  width: 331 * sizeAxis,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8 * sizeAxis),
                    border: Border.all(color: const Color(0xffe8ecf4)),
                    color: const Color(0xfff7f8f9),
                  ),
                  child: TextField(
                    controller: itemController,
                    // Use the referenceController to capture user input
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.fromLTRB(18 * sizeAxis,
                          18 * sizeAxis, 18 * sizeAxis, 19 * sizeAxis),
                      hintText: 'Generate an Item',
                      hintStyle: const TextStyle(color: Color(0xff8390a1)),
                    ),
                    style: GoogleFonts.urbanist(
                      fontSize: 15 * size,
                      fontWeight: FontWeight.w500,
                      height: 1.25 * size / sizeAxis,
                      color: const Color(0xff000000),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(
                      1 * sizeAxis, 0 * sizeAxis, 0 * sizeAxis, 15 * sizeAxis),
                  width: double.infinity,
                  height: 56 * sizeAxis,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xffe8ecf4)),
                    color: const Color(0xfff7f7f8),
                    borderRadius: BorderRadius.circular(8 * sizeAxis),
                  ),
                  child: TextField(
                    controller: dateTimeController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.fromLTRB(18 * sizeAxis,
                          17 * sizeAxis, 16 * sizeAxis, 17 * sizeAxis),
                      hintText: 'Date and Time',
                      hintStyle: const TextStyle(color: Color(0xff8390a1)),
                    ),
                    style: GoogleFonts.urbanist(
                      fontSize: 15 * size,
                      fontWeight: FontWeight.w500,
                      height: 1.25 * size / sizeAxis,
                      color: const Color(0xff000000),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(
                      1 * sizeAxis, 0 * sizeAxis, 0 * sizeAxis, 15 * sizeAxis),
                  width: double.infinity,
                  height: 56 * sizeAxis,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xffe8ecf4)),
                    color: const Color(0xfff7f7f8),
                    borderRadius: BorderRadius.circular(8 * sizeAxis),
                  ),
                  child: TextField(
                    controller: amountController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.fromLTRB(18 * sizeAxis,
                          17 * sizeAxis, 16 * sizeAxis, 17 * sizeAxis),
                      hintText: 'Amount',
                      hintStyle: const TextStyle(color: Color(0xff8390a1)),
                    ),
                    style: GoogleFonts.urbanist(
                      fontSize: 15 * size,
                      fontWeight: FontWeight.w500,
                      height: 1.25 * size / sizeAxis,
                      color: const Color(0xff000000),
                    ),
                  ),
                ),
                SizedBox(height: 25),
                Container(
                  margin: EdgeInsets.fromLTRB(
                      39 * sizeAxis, 0 * sizeAxis, 36 * sizeAxis, 0 * sizeAxis),
                  child: TextButton(
                    onPressed: () async {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                    ),
                    child: Container(
                      width: double.infinity,
                      height: 56 * sizeAxis,
                      decoration: BoxDecoration(
                        color: const Color(0xff231b53),
                        borderRadius: BorderRadius.circular(30 * sizeAxis),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0x14000000),
                            offset: Offset(0 * sizeAxis, 20 * sizeAxis),
                            blurRadius: 30 * sizeAxis,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Submit',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.urbanist(
                            fontSize: 16 * size,
                            fontWeight: FontWeight.w600,
                            height: 1.5 * size / sizeAxis,
                            color: const Color(0xffffffff),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
