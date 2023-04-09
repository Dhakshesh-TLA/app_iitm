import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_tts/flutter_tts.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key, required this.username});
  final String username;
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  var lang;
  final TextEditingController nick_name = TextEditingController();
  final TextEditingController full_name = TextEditingController();
  final TextEditingController user_name = TextEditingController();
  final TextEditingController pin = TextEditingController();
  final TextEditingController mobile = TextEditingController();
  static const alert = SnackBar(content: Text('Invalid Pin Number '));
  static const error =
  SnackBar(content: Text('Name already exists.Try Signing in'));
  static const success = SnackBar(content: Text('Registration successful '));

  @override
  void initState() {
    super.initState();
    lang = widget.username;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text("Welcome to DK Bank"),
            backgroundColor: Colors.greenAccent,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              tooltip: 'Back',
              onPressed: () async {
                Navigator.pop(context);
              },
            )),
        body: Column(
          children: [
            Expanded(
              child: TextField(
                controller: nick_name,
                decoration: InputDecoration(
                  labelText: 'Enter nick_name',
                  hintText: 'Enter Nick Name',
                ),
              ),
            ),
            Expanded(
              child: TextField(
                controller: full_name,
                decoration: InputDecoration(
                  labelText: 'Enter full_name',
                  hintText: 'Enter Full Name',
                ),
              ),
            ),
            Expanded(
              child: TextField(
                controller: user_name,
                decoration: InputDecoration(
                  labelText: 'Enter user_name',
                  hintText: 'Enter User Name',
                ),
              ),
            ),
            Expanded(
              child: TextField(
                controller: pin,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Enter Pin Number',
                  hintText: 'Enter 6 digit pin',
                ),
              ),
            ),
            Expanded(
              child: TextField(
                controller: mobile,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Enter Mobile Number',
                  hintText: 'Enter 10 digit phone number',
                ),
              ),
            ),
            SizedBox(
              height: 50,
              width: 150,
              child: ElevatedButton(
                onPressed: () async {
                  String p = await fetchDetail(nick_name.text);
                  if (p != "None") {
                    ScaffoldMessenger.of(context).showSnackBar(error);
                  } else {
                    if (pin.text.toString().length != 6) {
                      ScaffoldMessenger.of(context).showSnackBar(alert);
                    } else {
                      await RegisterDetail(
                          pin.text.toString(),
                          nick_name.text.toString(),
                          user_name.text.toString(),
                          full_name.text.toString(),
                          mobile.text.toString());

                      ScaffoldMessenger.of(context).showSnackBar(success);
                      sleep(Duration(seconds: 1));
                      Navigator.popUntil(context, ModalRoute.withName('/'));
                    }
                  }
                  ;
                },
                child: const Text("Register"),
              ),
            ),
          ],
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

Future<void> RegisterDetail(String pin, String n_name, String u_name,
    String f_name, String mobile) async {
  final url = 'http://events.respark.iitm.ac.in:5000/rp_bank_api';
  final payload = jsonEncode({
    "action": "register",
    "nick_name": n_name,
    "full_name": f_name,
    "user_name": u_name,
    "pin_number": pin,
    "mob_number": mobile,
    "upi_id": "$n_name@rpbank"
  });
  final headers = {'Content-Type': 'application/json'};
  final response = await http.post(
    Uri.parse(url),
    headers: headers,
    body: payload,
  );
  if (response.statusCode == 200) {
    if (response.body == "None") {
      //
    }

    String p = response.body;
    print(p);
  } else {
    //
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
