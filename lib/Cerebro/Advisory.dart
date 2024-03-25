import 'dart:async';
import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../util/utils.dart';
import 'Drawer.dart';
import 'package:http/http.dart' as http;

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

      setState(() {
        advisories = parsedData;
      });
    } else {
      print(response.reasonPhrase);
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    double baseWidth = 375;
    double sizeAxis = MediaQuery.of(context).size.width / baseWidth;
    double size = sizeAxis * 0.97;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      key: _scaffoldKey,
      appBar: AppBar(
        // Set a custom height for the app bar
        toolbarHeight: 80,
        // Transparent background with gradient in flexible space
        backgroundColor: Colors.transparent,
        elevation: 15,
        // Remove default shadow
        leading: IconButton(
          icon: Icon(Icons.menu, color: Theme.of(context).colorScheme.tertiary),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle,
                color: Theme.of(context).colorScheme.tertiary),
            onPressed: () {
              // Add functionality for account button
            },
          ),
        ],
        // Add a gradient background with rounded corners at the bottom
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      drawer: CereDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            children: [
              SizedBox(height: 20),
              // CustomAppBar(),
              // WELCOME Text
              Container(
                margin: EdgeInsets.fromLTRB(
                    0 * sizeAxis, 20 * sizeAxis, 0 * sizeAxis, 0 * sizeAxis),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'News Advisory!',
                      style: SafeGoogleFont(
                        'Urbanist',
                        fontSize: 18 * size,
                        fontWeight: FontWeight.bold,
                        height: 1.2 * size / sizeAxis,
                        color: const Color(0xFF13A4FF),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Get informed! This Advisory page offers essential updates and guidance to optimize your experience within Cerebro',
                      style: SafeGoogleFont(
                        'Urbanist',
                        fontSize: 12 * size,
                        height: 1.2 * size / sizeAxis,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              // List of advisories
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: advisories.length,
                itemBuilder: (context, index) {
                  return buildAdvisoryCard(advisories[index], size, sizeAxis);
                },
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildAdvisoryCard(Map<String, String> advisory, double size, double sizeAxis) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      elevation: 5,
      color: Theme.of(context).colorScheme.secondary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Ink.image(
                  image: NetworkImage(advisory['imageSrc'] ?? ''),
                  child: InkWell(
                    onTap: () {},
                  ),
                  height: 240,
                  fit: BoxFit.contain,
                ),
              ],
            ),
            SizedBox(height: 15),
            Text(
              advisory['title'] ?? '',
              style: SafeGoogleFont(
                'Urbanist',
                fontSize: 15 * size,
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
            'Inter',
            fontSize: 13 * size,
            height: 1.2 * size / sizeAxis,
            color: Colors.white,
          ),
        ));
      }

      textSpans.add(TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.red,
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
          'Inter',
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
              'Inter',
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
