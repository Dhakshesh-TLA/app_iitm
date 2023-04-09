import 'dart:convert';
import 'package:banking/signup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:translator/translator.dart';
import 'NaviOne.dart';
import 'signup.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}
class _LoginPageState extends State<LoginPage> {
  GoogleTranslator translator = GoogleTranslator();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  FlutterTts tts = FlutterTts();
  String _selectedLanguage = 'en-US';

 static const alert = SnackBar(content: Text('invalid nick name'));
 static const error = SnackBar(content: Text('Invalid Password'));

  @override
  void initState() {
    super.initState();
    speaking();
  }
  void speaking() async {
    await tts.setLanguage(_selectedLanguage);
    Future.delayed(const Duration(seconds: 10), () {
      _initializeSpeechRecognizer();
    });
  }
  void _initializeSpeechRecognizer() async {
    bool isAvailable = await _speech.initialize();
    if (isAvailable) {
      _speech.listen(
        onResult: (result) {
          if (!result.finalResult) {
            setState(() {
              _usernameController.text = result.recognizedWords.toLowerCase();
            });
          }
        },
      );
    }
  }
  void _startListening() async {
    bool isAvailable = await _speech.initialize();
    if (isAvailable) {
      _speech.listen(
        onResult: (result) {
          if (!result.finalResult) {
            setState(() {
              if (result.recognizedWords.length == 6) {
                _passwordController.text = result.recognizedWords;
              }
            });
          }
        },
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
        centerTitle: true,
        backgroundColor: Colors.amberAccent,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('asset/Image 2023-03-28 at 21.38.43.jpg'),fit: BoxFit.cover,
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                hintText: 'Enter your username',
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                hintText: 'Enter your password',
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    _selectedLanguage = 'en-US'; // English language selected
                    await tts.setLanguage(_selectedLanguage);
                    await tts.speak('Enter the username and Enter the password');
                    speaking();
                  },
                  child: const Text('English'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    _selectedLanguage = 'ta-IN'; // Tamil language selected
                    Translation translation = await translator.translate(
                        'Enter the username and Enter the pincode', from: 'en',
                        to: 'ta');
                    String text = translation
                        .text; // extract the text field from the Translation object
                    await tts.setLanguage(_selectedLanguage);
                    await tts.speak(text);
                    speaking();
                  }, child: const Text('தமிழ்'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: _initializeSpeechRecognizer,
                  child: const Text('Speech User Input'),
                ),
                ElevatedButton(
                  onPressed: _startListening,
                  child: const Text('Pincode Speech Input'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Handle login logic
                String username = _usernameController.text;
                String password = _passwordController.text;
                String p = await fetchDetail(_usernameController.text);
                if (p == "None") {
                  ScaffoldMessenger.of(context).showSnackBar(alert);
                }
                else {
                  if (p != _passwordController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(error);
                  }
                  else {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              NaviOne(
                                username: username,
                                password: password,
                              ),
                        ),
                    );
                  }
                  // Navigate to the new screen
                }
              }, child: const Text('Login'),
            ),
            ElevatedButton(onPressed: (){
              String username = _usernameController.text;
             Navigator.push(
               context,
               MaterialPageRoute(
                 builder: (context) =>
                     SignupScreen(
                       username: username),
               ),
             );
            },
                child: const Text('sign up'))
          ],
          ),
        ),
      );

  }
}
Future<String> fetchDetail(String name) async {
  final url = 'http://events.respark.iitm.ac.in:5000/rp_bank_api';
  final payload = jsonEncode({"action": "details", "nick_name": name});
  final headers = {'Content-Type': 'application/json'};
  final response = await http.post(
    Uri.parse(url),
    headers: headers,
    body: payload,
  );
  if (response.statusCode == 200) {
    if (response.body == "None") {
      return "None";
    }

    String p = "{" + response.body.substring(46);
    String k = check(p);
    var ans = jsonDecode(k);
    return ans['pin_number'];
  } else {
    return "None";
  }
}

String check(String p) {
  String k;
  k = p.replaceAll("'", '"');
  return k;
}