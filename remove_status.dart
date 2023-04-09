import "package:flutter/material.dart";
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:translator/translator.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';

class Status_Removed extends StatefulWidget {
  const Status_Removed({super.key, required this.data});
  final String data;
  @override
  State<Status_Removed> createState() => _Status_RemovedState();
}

class _Status_RemovedState extends State<Status_Removed> {
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
    answer = remove_user(splitted[0]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Removal Status"),
        centerTitle: true,
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            tooltip: "Back",
            onPressed: () async {
              ftts.stop();
              Navigator.popUntil(context, ModalRoute.withName('/'));
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
                fn_english(string);
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

Future<String> remove_user(String name) async {
  final url = 'http://events.respark.iitm.ac.in:5000/rp_bank_api';
  final payload = jsonEncode({"action": "remove", "nick_name": name});
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

    String p = response.body;
    String k = check(p);
    var ans = jsonDecode(k);
    var f = "Status:" + ans["status"] + "\n\nReason:" + ans["reason"];
    return f;
  } else {
    return "None";
  }
}

String check(String p) {
  String k;
  k = p.replaceAll("'", '"');
  return k;
}

void fn_english(String string) async {
  FlutterTts ftts = FlutterTts();
  await ftts.setLanguage("en");
  ftts.speak(string);
}
