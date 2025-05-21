import 'package:flutter/material.dart';
import 'SignIn_Page.dart';
import 'services/mongo_service.dart'; // Add this import

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required before async operations
  await MongoService.connect(); // Connect to MongoDB before launching the app
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
