import 'package:flutter/material.dart';
import 'SignIn_Page.dart'; // Make sure the file is in lib/

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
      home: const SignInPage(), // 👈 Set this as the start page
    );
  }
}
