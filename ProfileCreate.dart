import 'package:banking/profiledetails.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:translator/translator.dart';
import 'BalScreen.dart';
import 'Trans.dart';
import 'UserRemoval.dart';
import 'TransHist.dart';
class ProfileCreate extends StatelessWidget {
  final String username;
  final String password;

  const ProfileCreate({
    Key? key,
    required this.username,
    required this.password,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FlutterTts tts = FlutterTts();
    GoogleTranslator translator = GoogleTranslator();
    return Scaffold(
      appBar: AppBar(
        title: Text('Details'),
        centerTitle: true,
        backgroundColor: Colors.amberAccent,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('asset/welcome page.jpg'),
            fit: BoxFit.cover,
          ),
        ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProDetails(
                   username: username,
                  ),
                ),
              );
            },
            child: const Text('         PROFILE         '),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BalaScreen(),
                ),
              );
            },
            child: const Text('BALANCE DETAILS'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => History(
                    username: username,
                  ),
                ),
              );
            },
            child: const Text('TRANSACTION HISTORY'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                  builder: (context) => Transfer(
                username: username,
              ),
              ),
              );
            },
            child: const Text('TRANSFER AMOUNT'),
          ),
          const SizedBox(height: 20),
           ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Remove(
                    username: username,
                  ),
                ),
              );
            },
            child: const Text('REMOVE USER'),
           ),
        ],
      ),
    ),
    );
  }
}
