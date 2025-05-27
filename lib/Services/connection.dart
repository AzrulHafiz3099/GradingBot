import 'package:http/http.dart' as http;
import 'dart:convert';
import '/utils/env.dart';

Future<void> testConnection() async {
  final url = Uri.parse(Env.baseUrl + '/'); // your PC's IP & Flask port

  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Response from backend: $data');
    } else {
      print('Error: Server responded with status ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
