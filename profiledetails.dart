import "package:flutter/material.dart";
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:translator/translator.dart';
import 'package:audioplayers/audioplayers.dart';
import 'LoginPage.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';

class ProDetails extends StatefulWidget {
  const ProDetails({super.key, required this.username});
  final String username;

  @override
  State<ProDetails> createState() => _ProDetailsState();
}

class _ProDetailsState extends State<ProDetails> {
  GoogleTranslator translator = GoogleTranslator();
  var userData;
  String _selectedLanguage = 'en-US';
  late Future<Album> answer;
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
        title: Text("Profile Details"),
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
        child: FutureBuilder<Album>(
          future: answer,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var string = "Name:" +
                  snapshot.data!.full_name +
                  "\n\nNick Name:" +
                  snapshot.data!.nick_name +
                  "\n\nMobile Number:" +
                  snapshot.data!.mob_number +
                  "\n\nUPI ID:" +
                  snapshot.data!.upi_id;

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

dynamic fetchVoice(var text, String lang) async {
  AudioPlayer player = AudioPlayer();
  final url = 'https://asr.iitm.ac.in/ttsv2/tts';
  final payload = jsonEncode({
    "input": text,
    "gender": 'female',
    "lang": lang,
    "alpha": 1,
    "segmentwise": "True"
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
      var ans = jsonDecode(k);
      print(ans);

      List<int> bytes = utf8.encode(ans["audio"]);
      print(bytes);
      //final bytes = ans["audio"].bodyBytes;
      //await player.play("hsuhw");
    } catch (e) {
      print(e);
    }
  } else {
    //Handle Exception
  }
}

Future<Album> fetchDetail(String name) async {
  final url = 'http://events.respark.iitm.ac.in:5000/rp_bank_api';
  final payload = jsonEncode({"action": "details", "nick_name": name});
  final headers = {'Content-Type': 'application/json'};
  final response = await http.post(
    Uri.parse(url),
    headers: headers,
    body: payload,
  );
  if (response.statusCode == 200) {
    String p = "{" + response.body.substring(46);
    String k = check(p);
    try {
      return Album.fromJson(jsonDecode(k));
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
  final String pin_number;
  final String nick_name;
  final String user_name;
  final String full_name;
  final String upi_id;
  final String mob_number;

  const Album({
    required this.pin_number,
    required this.nick_name,
    required this.user_name,
    required this.full_name,
    required this.upi_id,
    required this.mob_number,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
        pin_number: json['pin_number'],
        nick_name: json['nick_name'],
        user_name: json['user_name'],
        full_name: json['full_name'],
        upi_id: json['upi_id'],
        mob_number: json['mob_number'],
        );
    }
}