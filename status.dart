import "package:flutter/material.dart";
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:translator/translator.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';

class Status extends StatefulWidget {
  const Status({super.key, required this.data});
  final String data;
  @override
  State<Status> createState() => _StatusState();
}

class _StatusState extends State<Status> {
  var userData;
  late Future<String> answer;
  var splitted;
  FlutterTts ftts = FlutterTts();
  @override
  void initState() {
    super.initState();
    userData = widget.data;
    userData = userData.toString();
    splitted = userData.split(" ");
    answer = fetchDetail(splitted);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Transaction Status"),
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
              var string = snapshot.data!;
              if (splitted[1] == "tamil") {
                fn_tamil(string);
              } else {
                ftts.speak(string);
              }
              return Text(
                string,
                style: TextStyle(fontSize: 25),
              );
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

Future<String> fetchDetail(var splitted) async {
  final url = 'http://events.respark.iitm.ac.in:5000/rp_bank_api';
  final payload = jsonEncode({
    "action": "transfer",
    "amount": int.parse(splitted[2]),
    "from_user": splitted[0],
    "to_user": splitted[1]
  });
  final headers = {'Content-Type': 'application/json'};
  final response = await http.post(
    Uri.parse(url),
    headers: headers,
    body: payload,
  );
  if (response.statusCode == 200) {
    String p = response.body;
    String k = check(p);
    try {
      String s = jsonDecode(k)['status'];
      s = "\tTransaction Summary\n\n\nFrom: " +
          splitted[0] +
          "\n\nTo: " +
          splitted[1] +
          "\n\nAmount: " +
          splitted[2] +
          "\n\nStatus: " +
          s;
      return s;
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
