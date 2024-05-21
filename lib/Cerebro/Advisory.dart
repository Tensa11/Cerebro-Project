import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../util/utils.dart';
import 'Drawer.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class Advisory extends StatefulWidget {
  const Advisory({Key? key}) : super(key: key);

  @override
  _AdvisoryState createState() => _AdvisoryState();
}

class _AdvisoryState extends State<Advisory> {
  List<Map<String, String>> advisories = [];

  @override
  void initState() {
    super.initState();
    fetchAdvisory();
    _getAvatarData();
    _getUserData();
  }

  Future<void> fetchAdvisory() async {
    var headers = {
      'Content-Type': 'application/x-www-form-urlencoded'
    };
    var request = http.Request('POST', Uri.parse('http://eclaimsportal.solarestech.com/api/advisory'));
    request.bodyFields = {
      'HCICODE': 'H11022785 or 940533',
      'AUTH_TOKEN': 'TEST AUTH TOKEN',
      'ADVISORY_TYPE': 'E'
    };
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      List<dynamic> data = json.decode(responseBody);
      List<Map<String, String>> parsedData = [];
      data.forEach((item) {
        parsedData.add({
          'title': item['TITLE'],
          'description': item['DESCRIPTION'],
          'id': item['ID'],
          'postDate': item['POSTDATE'],
          'imageSrc': item['IMAGESRC']
        });
      });
      // Sort the advisories by the advisory number
      parsedData.sort((b, a) => int.parse(a['id']!).compareTo(int.parse(b['id']!)));
      setState(() {
        advisories = parsedData;
      });
    } else {
      print(response.reasonPhrase);
    }
  }

  String avatarUrl = '';
  String username = '';
  Future<void> _getAvatarData() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username') ?? '';

    // Fetch the avatar URL
    final apiUrl = dotenv.env['API_URL']; // Retrieve API URL from .env file
    if (apiUrl == null) {
      throw Exception('API_URL environment variable is not defined');
    }
    var url = Uri.parse('$apiUrl/med/hospital/me');
    final token = prefs.getString('token'); // Assuming you saved the token with this key
    final refreshToken = prefs.getString('refreshToken'); // Assuming refresh token is stored separately

    if (token == null) {
      throw Exception('Token not found.');
    }
    var response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token', // Include the token in the Authorization header
        'Cookie': 'refreshToken=$refreshToken',
      },
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        avatarUrl = data['avatar']; // Store the avatar URL
      });
    } else {
      print('Failed to load user data');
    }
  }
  Future<void> _getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username') ?? '';
    setState(() {}); // Update the UI with retrieved data
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
          icon: Icon(Icons.menu, color: Color(0xFFFFFFFF)),
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
                    padding: EdgeInsets.only(left: 40.0, right: 40.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'News Advisory!',
                          style: SafeGoogleFont(
                            'Urbanist',
                            fontSize: 20 * size,
                            fontWeight: FontWeight.bold,
                            height: 1.2 * size / sizeAxis,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Get informed! This Advisory page offers essential updates and guidance to optimize your experience within Cerebro',
                          style: SafeGoogleFont(
                            'Urbanist',
                            fontSize: 13 * size,
                            height: 1.2 * size / sizeAxis,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30.0),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(75.0)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(left: 30.0, right: 30.0),
                      child: SingleChildScrollView( // Wrap the Column in a SingleChildScrollView
                        child: Column(
                          children: [
                            SizedBox(height: 30),
                            // List of advisories
                            ListView.separated(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: advisories.length,
                              itemBuilder: (context, index) {
                                return buildAdvisoryCard(advisories[index], size, sizeAxis);
                              },
                              separatorBuilder: (context, index) {
                                return SizedBox(height: 10); // Adjust the height as needed
                              },
                            ),
                            SizedBox(height: 30),
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
    await fetchAdvisory();
    await _getAvatarData();
    await _getUserData();
    setState(() {});
    return await Future.delayed(Duration(seconds: 2));
  }

  Widget buildAdvisoryCard(Map<String, String> advisory, double size, double sizeAxis) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      elevation: 5,
      color: Color(0xFF1497E8),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Container(
                    height: 240,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Image.network(
                    advisory['imageSrc'] ?? '',
                    height: 240,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 240,
                      width: double.infinity,
                      color: Colors.white,
                      child: Icon(Icons.broken_image, size: 50),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 15),
            Text(
              advisory['title'] ?? '',
              style: SafeGoogleFont(
                'Urbanist',
                fontSize: 16 * size,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                height: 1.2 * size / sizeAxis,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 15),
            buildDescription(advisory['description'] ?? '', size, sizeAxis),
            SizedBox(height: 10),
            Text(
              '- Advisory No.${advisory['id'] ?? ''} (${advisory['postDate'] ?? ''})',
              style: SafeGoogleFont(
                'Urbanist',
                fontSize: 11 * size,
                height: 1.2 * size / sizeAxis,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDescription(String description, double size, double sizeAxis) {
    List<InlineSpan> textSpans = [];

    RegExp regex = RegExp(r'<a href="(.*?)".*?>(.*?)<\/a>');
    RegExp strongRegex = RegExp(r'<strong>(.*?)<\/strong>');

    // Replace <strong> tags with bold text
    description = description.replaceAllMapped(strongRegex, (match) {
      String content = match.group(1)!;
      return '$content';
    });
    RegExp bulletListRegex = RegExp(r'<li>(.*?)<\/li>');

    // Replace <li> tags with bullet points
    description = description.replaceAllMapped(bulletListRegex, (match) {
      String content = match.group(1)!;
      return '• $content\n';
    });

    // Remove <ul> and </ul> tags
    description = description.replaceAll('<ul>', '');
    description = description.replaceAll('</ul>', '');

    // Build TextSpans for styled content
    int prevIndex = 0;
    regex.allMatches(description).forEach((match) {
      String link = match.group(1)!;
      String text = match.group(2)!;

      if (prevIndex < match.start) {
        textSpans.add(TextSpan(
          text: description.substring(prevIndex, match.start),
          style: SafeGoogleFont(
            'Urbanist',
            fontSize: 13 * size,
            height: 1.2 * size / sizeAxis,
            color: Colors.white,
          ),
        ));
      }
      textSpans.add(TextSpan(
        text: text,
        style: SafeGoogleFont(
          fontSize: 13 * size,
          'Urbanist',
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
          height: 1.2 * size / sizeAxis,
          color: Colors.white,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () async {
            await _launchURL(link);
          },
      ));
      prevIndex = match.end;
    });
    if (prevIndex < description.length) {
      textSpans.add(TextSpan(
        text: description.substring(prevIndex),
        style: SafeGoogleFont(
          'Urbanist',
          fontSize: 13 * size,
          height: 1.2 * size / sizeAxis,
          color: Colors.white,
        ),
      ));
    }

    // Return Text widget with hidden description and styled content
    return Column(
      children: [
        Visibility(
          visible: false,
          child: Text(
            description,
            style: SafeGoogleFont(
              'Urbanist',
              fontSize: 13 * size,
              height: 1.2 * size / sizeAxis,
              color: Colors.transparent, // Make text transparent
            ),
          ),
        ),
        Text.rich(
          TextSpan(children: textSpans),
        ),
      ],
    );
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}


