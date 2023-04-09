import 'package:banking/status.dart';
import "package:flutter/material.dart";
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';

class Transfer extends StatefulWidget {
  const Transfer({super.key, required this.username});
  final String username;
  @override
  State<Transfer> createState() => _TransferState();
}

class _TransferState extends State<Transfer> {
  var userData;
  var splitted;
  FlutterTts ftts = FlutterTts();
  final TextEditingController name = TextEditingController();
  final TextEditingController amount = TextEditingController();
  static const alert = SnackBar(content: Text('Invalid Receiver '));
  static const error = SnackBar(content: Text('Invalid Amount '));
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
          title: Text("Amount Transaction"),
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
                  controller: name,
                  decoration: InputDecoration(
                    labelText: 'Enter Receiver Name',
                    hintText: 'Enter Name',
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: amount,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Enter Amount',
                    hintText: 'Amount',
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
                    String p = await fetchDetail(name.text);
                    if (p == "None") {
                      ScaffoldMessenger.of(context).showSnackBar(alert);
                    } else {
                      if (int.parse(amount.text) <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(error);
                      } else {
                        var userLogin =
                            splitted[0] + " " + name.text + " " + amount.text;
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Status(data: userLogin)));
                      }
                    }
                    ;
                  },
                  child: const Text("Transfer"),
                ),
              ),
            ],
          ),
        ));
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
