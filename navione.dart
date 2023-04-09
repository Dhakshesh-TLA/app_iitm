import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:translator/translator.dart';

import 'ProfileCreate.dart';

class NaviOne extends StatelessWidget {
  final String username;
  final String password;

  const NaviOne({
    Key? key,
    required this.username,
    required this.password,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String _selectedLanguage = '';

    FlutterTts tts = FlutterTts();
    GoogleTranslator translator = GoogleTranslator();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome Page'),
        centerTitle: true,
        backgroundColor: Colors.amberAccent,
      ),
      body: Center(
        child: Container(
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
              Text(
                'Welcome to our bank $username. We are very happy to see you again. This app allows you to access your banking accounts and conduct financial transactions using a mobile device, anytime and from anywhere. With this banking app, you can easily keep track of your transaction activities, such as checking your bank passbook and everyday transactions!',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.amberAccent,
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
                      await tts.speak(
                          'Welcome to our bank $username. We are very happy to see you again. This app allows you to access your banking accounts and conduct financial transactions using a mobile device, anytime and from anywhere. With this banking app, you can easily keep track of your transaction activities, such as checking your bank passbook and everyday transactions!');
                    },
                    child: const Text('English'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      _selectedLanguage = 'ta-IN'; // Tamil language selected
                      Translation translation = await translator.translate(
                        'Welcome to our bank $username. We are very happy to see you again. This app allows you to access your banking accounts and conduct financial transactions using a mobile device, anytime and from anywhere. With this banking app, you can easily keep track of your transaction activities, such as checking your bank passbook and everyday transactions!',
                        from: 'en',
                        to: 'ta',
                      );
                      String text = translation.text;
                      await tts.setLanguage(_selectedLanguage);
                      await tts.speak(text);
                    },
                    child: const Text('தமிழ்'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      String username = this.username;
                      String password = this.password;
                      tts.stop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileCreate(
                            username: username,
                            password: password,
                          ),
                        ),
                      );
                    },
                    child: const Text('Next'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
