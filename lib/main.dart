import 'package:flutter/material.dart';
import 'SignIn_Page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Poppins',
        textTheme: ThemeData.light().textTheme.apply(fontFamily: 'Poppins'),
      ),
      title: 'Grading Bot',
      debugShowCheckedModeBanner: false,
      home: const SignInPage(),
    );
  }
}
