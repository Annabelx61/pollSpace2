import 'package:flutter/material.dart';
import 'package:flutter_application_1/firebase_options.dart';
import 'home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'spacePoll 🗳',
      home: Polls(),
      debugShowCheckedModeBanner: false,
    );
  }
}
