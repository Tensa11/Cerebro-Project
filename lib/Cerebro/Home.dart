import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'Add.dart';
import 'AddPatient.dart';

class CereDash extends StatefulWidget {
  const CereDash({Key? key}) : super(key: key);

  @override
  _CereDashState createState() => _CereDashState();
}

class _CereDashState extends State<CereDash> {
  List<dynamic> items = []; // List to store fetched data

  @override
  void initState() {
    super.initState();
    fetchData(); // Fetch data when the widget is initialized
  }

  Future<List<Map<String, dynamic>>> fetchData() async {
    var url = Uri.parse('http://192.168.18.24:6969');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      // Handle successful response
      var jsonData = json.decode(response.body);
      var transactions = jsonData['total_amount'] as List<dynamic>;
      List<Map<String, dynamic>> data = transactions
          .map((transaction) => {
        'amount': transaction['amount'] as double,
        'trans_date': transaction['trans_date'] as String,
      })
          .toList();

      // Sort the list based on the trans_date in descending order
      data.sort((a, b) => b['trans_date'].compareTo(a['trans_date']));

      print('Total transactions: $data');
      return data;
    } else {
      // Handle error response
      print('Request failed with status: ${response.statusCode}');
      throw Exception('Failed to fetch data');
    }
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 375;
    double sizeAxis = MediaQuery.of(context).size.width / baseWidth;
    double size = sizeAxis * 0.97;

    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: Container(
            padding: EdgeInsets.fromLTRB(24 * sizeAxis, 30 * sizeAxis, 24 * sizeAxis, 0 * sizeAxis),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xffffffff),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(8 * sizeAxis, 0 * sizeAxis, 0 * sizeAxis, 32 * sizeAxis),
                  width: double.infinity,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.fromLTRB(0 * sizeAxis, 0 * sizeAxis, 200 * sizeAxis, 0 * sizeAxis),
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                          ),
                          child: Container(
                            width: 48 * sizeAxis,
                            height: 48 * sizeAxis,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24 * sizeAxis),
                              image: const DecorationImage(
                                fit: BoxFit.cover,
                                image: AssetImage('assets/logo/applogo.png'),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Current Credits ListView
                Container(
                  margin: EdgeInsets.fromLTRB(0 * sizeAxis, 20 * sizeAxis, 0 * sizeAxis, 13 * sizeAxis),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Display Amounts',
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 18 * size,
                          fontWeight: FontWeight.w500,
                          height: 1.2 * size / sizeAxis,
                          color: const Color(0xff5c5473),
                          decoration: TextDecoration.none,
                        ),
                      ),
                      // Payment Data ListView
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: fetchData(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            var transactions = snapshot.data!;
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: transactions.length,
                              itemBuilder: (BuildContext context, int index) {
                                var transaction = transactions[index];
                                var amount = transaction['amount'] as double;
                                var transDate = transaction['trans_date'] as String;
                                return Card(
                                  elevation: 3,
                                  child: ListTile(
                                    leading: const CircleAvatar(
                                      backgroundImage: AssetImage('assets/logo/applogo.png'),
                                    ),
                                    title: Text(
                                      'Amount: ₱$amount',
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        SizedBox(height: 5),
                                        Text(
                                          'Transaction Date: $transDate',
                                          style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            decoration: TextDecoration.none,
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddPatient(),
            ),
          );},
        child: Icon(Icons.add),
        backgroundColor: Color(0xffef3924),
      ),
    );
  }
}
