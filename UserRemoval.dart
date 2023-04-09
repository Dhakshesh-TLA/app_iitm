import 'package:banking/remove_status.dart';
import 'package:banking/status.dart';
import "package:flutter/material.dart";
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';

class Remove extends StatefulWidget {
  const Remove({super.key, required this.username});
  final String username;
  @override
  State<Remove> createState() => _RemoveState();
}

class _RemoveState extends State<Remove> {
  var userData;
  var splitted;
  late Future<String> answer;
  FlutterTts ftts = FlutterTts();
  final TextEditingController pin = TextEditingController();
  static const alert = SnackBar(content: Text('Invalid Pin Number '));
  @override
  void initState() {
    super.initState();
    userData = widget.username;
    userData = userData.toString();
    splitted = userData.split(" ");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("User Removal"),
          centerTitle: true,
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              tooltip: "Back",
              onPressed: () async {
                ftts.stop();
                Navigator.pop(context);
              }),
        ),
        body: Padding(
          padding: EdgeInsets.all(25.0),
          child: Column(
            children: [
              Expanded(
                child: TextField(
                  controller: pin,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Enter Pin Number',
                    hintText: '6 Digit Pin',
                  ),
                ),
              ),
              SizedBox(
                height: 50,
                width: 150,
                child: ElevatedButton(
                  style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: () async {
                    String p = await fetchDetail(splitted[0]);
                    if (pin.text != p) {
                      ScaffoldMessenger.of(context).showSnackBar(alert);
                    } else {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  Status_Removed(data: userData)));
                    }
                    ;
                  },
                  child: const Text("Remove"),
                ),
              ),
            ],
          ),
        ));
  }
}

void fn_english(String string) async {
  FlutterTts ftts = FlutterTts();
  await ftts.setLanguage("en");
  ftts.speak(string);
}
