import 'package:flutter/material.dart';
import '/utils/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/utils/env.dart';

class ResultDetailsPage extends StatefulWidget {
  final String studentId;
  final String resultId;

  const ResultDetailsPage({super.key, required this.studentId, required this.resultId});

  @override
  State<ResultDetailsPage> createState() => _ResultDetailsPageState();
}

class _ResultDetailsPageState extends State<ResultDetailsPage> {
  Map<String, dynamic>? studentResult;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchStudentResult();
  }

  Future<void> _fetchStudentResult() async {
    try {
      final response = await http.get(
        Uri.parse('${Env.baseUrl}/api_result/by_result?result_id=${widget.resultId}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          setState(() {
            studentResult = data['data'];
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = data['message'];
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Server error: ${response.statusCode}';
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

  @override
  Widget build(BuildContext context) {
    const secondaryColor = Color(0xFF2BA8FF);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: secondaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Result Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: secondaryColor,
          ),
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
                ? Center(child: Text(errorMessage!))
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: ListView(
                      children: [
                        _buildTextField(label: 'Student Name', value: studentResult?['student_name'] ?? ''),
                        _buildTextField(label: 'Class', value: studentResult?['class_name'] ?? ''),
                        _buildTextField(label: 'Exam', value: studentResult?['exam_name'] ?? ''),
                        _buildTextField(label: 'Phone No.', value: studentResult?['phone_number'] ?? ''),
                        _buildTextField(label: 'Score', value: studentResult?['score'] ?? ''),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () {
                            // Handle download
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: secondaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Download Result Summary', style: TextStyle(color: Colors.white)),
                        )
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildTextField({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          TextField(
            readOnly: true,
            controller: TextEditingController(text: value),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
            ),
          ),
        ],
      ),
    );
  }
}
