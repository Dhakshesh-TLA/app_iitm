import "package:flutter/material.dart";
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:translator/translator.dart';

class History extends StatefulWidget {
  const History({super.key, required this.username});
  final String username;
  @override
  State<History> createState() => _HistoryState();

}

class _HistoryState extends State<History> {
  var userData;
  GoogleTranslator translator = GoogleTranslator();
  String _selectedLanguage = 'en-US';
  late Future<String> answer;
  var splitted;
  FlutterTts ftts = FlutterTts();
  @override
  void speaking() async {
    await ftts.setLanguage(_selectedLanguage);
  }
  void initState() {
    super.initState();
    userData = widget.username;
    userData = userData.toString();
    splitted = userData.split(" ");
    answer = fetchDetail(splitted[0]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Last 10 Transactions"),
        centerTitle: true,
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            tooltip: "Back",
            onPressed: () async {
              ftts.stop();
              Navigator.pop(context);
            }),
      ),
      body: Center(
        child: FutureBuilder<String>(
          future: answer,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              print(snapshot.data);
              var string = snapshot.data!;
              return Column(
                children: [
                  Text(string),
                  ElevatedButton(
                    onPressed: () async{
                      _selectedLanguage = 'en-US'; // English language selected
                      await ftts.setLanguage(_selectedLanguage);
                      await ftts.speak(string);
                      speaking();
                    },
                    child: const Text("English"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      _selectedLanguage = 'ta-IN'; // Tamil language selected
                      Translation translation = await translator.translate(
                          string, from: 'en',
                          to: 'ta');
                      String text = translation
                          .text; // extract the text field from the Translation object
                      await ftts.setLanguage(_selectedLanguage);
                      await ftts.speak(text);
                      speaking();
                    }, child: const Text('தமிழ்'),
                  ),
                ],
              );
              return Text(string);
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }

            // By default, show a loading spinner.
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}

void fn_tamil(String string) async {
  FlutterTts ftts = FlutterTts();
  final translator = GoogleTranslator();
  await ftts.setLanguage("ta");
  var translation;
  translation = (await translator.translate(string, from: 'en', to: 'ta'));
  String p = translation + "'";
  p = "'" + p;
  ftts.speak(p);
}

Future<String> fetchDetail(String name) async {
  final url = 'http://events.respark.iitm.ac.in:5000/rp_bank_api';
  final payload = jsonEncode({"action": "history", "nick_name": name});
  final headers = {'Content-Type': 'application/json'};
  final response = await http.post(
    Uri.parse(url),
    headers: headers,
    body: payload,
  );
  if (response.statusCode == 200) {
    String k = " ";
    var p = response.body.split("}, {'_id'");
    int j = 0;
    String ans = " ";
    for (String i in p) {
      if (j == 10) {
        break;
      }
      if (j != 0) {
        k = check("{" + i.substring(39) + "}");
        print("hi");
      } else {
        k = check("{" + i.substring(46) + "}");
      }
      Album user = Album.fromJson(jsonDecode(k));

      ans = ans +
          "Date: " +
          user.date +
          " Time: " +
          user.time +
          " To-From: " +
          user.to_from +
          " Amount: " +
          user.amount.toString() +
          " Balance " +
          user.balance.toString() +
          "\n\n";
      j++;
    }
    try {
      return ans;
    } catch (e) {
      throw Exception(e);
    }
  } else {
    throw Exception("Failed to Login");
  }
}

String check(String p) {
  String k;
  k = p.replaceAll("'", '"');
  return k;
}

class Album {
  final String date;
  final String time;
  final String to_from;
  final int amount;
  final double balance;

  const Album({
    required this.date,
    required this.time,
    required this.to_from,
    required this.amount,
    required this.balance,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      date: json['date'],
      time: json['time'],
      to_from: json['to-from'],
      amount: json['amount'],
      balance: json['balance'],
    );
  }
}

void fn_english(String string) async {
  FlutterTts ftts = FlutterTts();
  await ftts.setLanguage("en");
  ftts.speak(string);
}
