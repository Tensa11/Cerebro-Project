import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../util/utils.dart';
import 'Drawer.dart';

class AiChat extends StatefulWidget {
  const AiChat({super.key});

  @override
  State<AiChat> createState() => _AiChatState();
}

class _AiChatState extends State<AiChat> {
  final TextEditingController _userMessage = TextEditingController();

  static const apiKey = "AIzaSyACrTe1Jg2Q5v4HoNniNV9wBUqIXqQj8D4";

  final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);

  final List<Message> _messages = [];

  Future<void> sendMessage() async {
    final message = _userMessage.text;
    _userMessage.clear();

    // Check if the message is related to health
    if (!isHealthRelated(message)) {
      // Optionally, show a message to the user asking for a health-related question
      setState(() {
        _messages.add(Message(
            isUser: false,
            message: "Please ask a question related to health.",
            date: DateTime.now()));
      });
      return;
    }

    setState(() {
      // Add user message to the chat
      _messages.add(Message(isUser: true, message: message, date: DateTime.now()));
    });

    // Send the user message to the bot and wait for the response
    final content = [Content.text(message)];
    final response = await model.generateContent(content);
    setState(() {
      // Add bot's response to the chat
      _messages.add(Message(
          isUser: false, message: response.text ?? "", date: DateTime.now()));
    });
  }

  bool isHealthRelated(String message) {
    List<String> healthKeywords = [
      "health",
      "medicine",
      "doctor",
      "hospital",
      "disease",
      "symptom",
      "treatment",
      "vaccine",
      "nutrition",
      "exercise",
      "healthcare system",
      "PhilHealth",
      "Philippine Health Insurance Corporation",
      "merger",
      "acquisition",
      "partnership",
      "strategic planning",
      "asset purchase",
      "joint venture",
      "transaction model",
      "Stark and Anti-Kickback laws",
      "pension plan obligations",
      "collective bargaining arrangements",
      "real estate leases",
      "portfolio realignment",
      "regional growth",
      "management services agreement",
      "joint operating model",
      "non-ownership collaboration",
      "affiliation",
      "M&A activity",
      "transaction volume",
      "operational efficiency",
      "financial refinement",
      "quality improvement",
      "diagnostic system",
      "diagnostic error",
      "outcomes-based diagnostic research",
      "test result management",
      "follow-up",
      "decision support system",
      "pathology",
      "medical imaging",
      "digital health",
      "data storage",
      "information retrieval",
      "transmission",
      "utilization",
      "diagnostic informatics",
      "diagnostic stewardship",
      "shared decision-making",
      "patient-centered care",
      "interoperable electronic systems",
      "artificial intelligence",
      "natural language processing",
      "machine translation",
      "speech recognition",
      "speech synthesis",
      "electronic decision support",
      "quality improvement project",
      "acute kidney injury",
      "serum creatinine",
      "RT-PCR",
      "molecular testing",
      "epidemiological surveillance",
      "viral infection",
      "comorbidities",
      "Anti-SARS-CoV-2 antibodies",
    ];

    return healthKeywords.any((keyword) => message.toLowerCase().contains(keyword));
  }

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  String avatarUrl = '';
  String username = '';
  Future<void> _getUserData() async {
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

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          title: Text('AI Assistant'),
          // Set a custom height for the app bar
          toolbarHeight: 80,
          // Transparent background with gradient in flexible space
          backgroundColor: Colors.transparent,
          elevation: 15,
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
                      ? Image.network(
                    avatarUrl,
                    height: 40,
                    width: 40,
                    fit: BoxFit.cover,
                  )
                      : Container(), // Removed the fallback to RandomAvatar
                ),
              ),
            ),
            SizedBox(width: 20),
          ],
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
        body: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(height: 15),
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return Messages(
                    isUser: message.isUser,
                    message: message.message,
                    date: DateFormat('HH:mm MMM d, yyyy').format(message.date),
                  );
                },
              ),
            ),
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 15),
              child: Row(
                children: [
                  Expanded(
                    flex: 15,
                    child: TextFormField(
                      controller: _userMessage,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25)),
                        label: const Text("What assistant do you need?"),
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    padding: const EdgeInsets.all(15),
                    iconSize: 30,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.tertiary),
                      foregroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
                      shape: MaterialStateProperty.all(
                        const CircleBorder(),
                      ),
                    ),
                    onPressed: () {
                      sendMessage();
                    },
                    icon: const Icon(Icons.send),
                  )
                ],
              ),
            )
          ],
        )
    );
  }
}

class Messages extends StatelessWidget {
  final bool isUser;
  final String message;
  final String date;
  const Messages(
      {super.key,
        required this.isUser,
        required this.message,
        required this.date});

  @override
  Widget build(BuildContext context) {
    double baseWidth = 375;
    double sizeAxis = MediaQuery.of(context).size.width / baseWidth;
    double size = sizeAxis * 0.97;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.symmetric(vertical: 15).copyWith(
        left: isUser ? 100 : 10,
        right: isUser ? 10 : 100,
      ),
      decoration: BoxDecoration(
        color: isUser
            ? Colors.red.shade800
            : Color(0xFF081E65),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(10),
          bottomLeft: isUser ? const Radius.circular(10) : Radius.zero,
          topRight: const Radius.circular(10),
          bottomRight: isUser ? Radius.zero : const Radius.circular(10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MarkdownBody(
            data: message,
            styleSheet: MarkdownStyleSheet(
              p: TextStyle(
                fontSize: 14 * size,
                height: 1.2 * size / sizeAxis,
                color: Colors.white,
                fontFamily: 'Urbanist',
              ),
              h1: TextStyle(
                fontSize: 14 * size,
                height: 1.2 * size / sizeAxis,
                color: Colors.white,
                fontFamily: 'Urbanist',
              ),
              // Add other styles as needed
            ),
          ),
          SizedBox(height: 15),
          Text(
            date,
            style: TextStyle(
              fontSize: 11 * size,
              fontFamily: 'Urbanist',
              fontStyle: FontStyle.italic,
              height: 1.2 * size / sizeAxis,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class Message {
  final bool isUser;
  final String message;
  final DateTime date;

  Message({
    required this.isUser,
    required this.message,
    required this.date,
  });
}