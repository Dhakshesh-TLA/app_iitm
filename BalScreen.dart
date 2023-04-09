import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:convert';

import 'package:translator/translator.dart';

class BalaScreen extends StatefulWidget {
  const BalaScreen({Key? key}) : super(key: key);

  @override
  State<BalaScreen> createState() => _BalaScreenState();
}

class _BalaScreenState extends State<BalaScreen> {
  late Future<String> answer;

  var ans;
  @override
  void initState() {
    super.initState();
    answer = checkBalance();
  }

  FlutterTts ftts = FlutterTts();
  late String _selectedLanguage;
  final translator = GoogleTranslator();

  void speaking() async {
    await ftts.setLanguage(_selectedLanguage);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Account Balance'),
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              tooltip: "Back",
              onPressed: () async {
                ftts.stop();
                Navigator.pop(context);
              }),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 25.0),
            child: Column(
              children: <Widget>[
                const Expanded(
                  child: Text("Bank of DK:"),
                ),
                Expanded(
                  child: FutureBuilder<String>(
                    future: answer,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        ans = snapshot.data!;
                        ans = ans.substring(12, 17);
                        ans = "Account Balance is $ans";
                        ftts.speak(ans);
                        return Text("$ans");
                      } else if (snapshot.hasError) {
                        return Text('${snapshot.error}');
                      }

                      // By default, show a loading spinner.
                      return const CircularProgressIndicator();
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        _selectedLanguage = 'ta-IN'; // Tamil language selected
                        Translation translation = await translator.translate(
                            ans,
                            from: 'en',
                            to: 'ta');
                        String text =
                            translation.text; // extract the text field from the Translation object
                        await ftts.setLanguage(_selectedLanguage);
                        await ftts.speak(text);
                        speaking();
                      },
                      child: const Text('தமிழ்'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

Future<String> checkBalance() async {
  final url = 'http://events.respark.iitm.ac.in:5000/rp_bank_api';
  final payload = jsonEncode({"action": "balance", "nick_name": "irfan"});
  final headers = {'Content-Type': 'application/json'};

  final response = await http.post(
    Uri.parse(url),
    headers: headers,
    body: payload,
  );

  if (response.statusCode == 200) {
    String user = response.body.toString();
    return user;
  } else {
    throw Exception('Failed to check balance');
  }
}
