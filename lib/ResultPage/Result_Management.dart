import 'package:flutter/material.dart';
import '/utils/colors.dart';
import 'Result_Details.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/utils/env.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ResultManagementPage extends StatefulWidget {
  const ResultManagementPage({super.key});

  @override
  State<ResultManagementPage> createState() => _ResultManagementPageState();
}

class _ResultManagementPageState extends State<ResultManagementPage> {
  final secureStorage = const FlutterSecureStorage();
  List<Map<String, dynamic>> results = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadLecturerIdAndFetchResults();
  }

  Future<void> _loadLecturerIdAndFetchResults() async {
    String? lecturerId = await secureStorage.read(key: 'lecturer_id');
    if (lecturerId == null) {
      setState(() {
        isLoading = false;
        errorMessage = 'Lecturer ID not found';
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(
          '${Env.baseUrl}/api_result/by_lecturer?lecturer_id=$lecturerId',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            results = List<Map<String, dynamic>>.from(data['data']);
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = data['message'] ?? 'Failed to fetch results';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Server Error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  Color _getScoreColor(String score) {
    if (score.startsWith('0')) {
      return Colors.red;
    }
    return const Color(0xFF2BA8FF); // Blue
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.secondaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Result Management',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2BA8FF),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null
                ? Center(child: Text(errorMessage!))
                : Column(
                  children: [
                    const SizedBox(height: 16),
                    const Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Text(
                            'Matrix Number',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Class',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Score',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    Expanded(
                      child: ListView.builder(
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final result = results[index];
                          final scoreColor = _getScoreColor(
                            result['score'] ?? '0',
                          );

                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ResultDetailsPage(
                                        studentId:
                                            result['student_id'], // Pass student ID
                                        resultId: 
                                            result['result_id'],
                                      ),
                                ),
                              );
                            },

                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: Text(result['student_matrix'] ?? ''),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Text(result['class_name'] ?? ''),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          result['score'] ?? '',
                                          style: TextStyle(color: scoreColor),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
