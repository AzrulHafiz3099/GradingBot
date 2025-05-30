import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/utils/env.dart'; // Env.baseUrl for API base url


typedef OnExamSelected = void Function(String examId, String examName);

Future<void> showExamPicker({
  required BuildContext context,
  required String selectedExam,
  required String classId,
  required OnExamSelected onSelected,
}) async {
  final response = await http.get(Uri.parse('${Env.baseUrl}/api_exam/exams?class_id=$classId'));

  if (response.statusCode != 200) {
    // Handle error
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to load exams')),
    );
    return;
  }

  final data = json.decode(response.body);
  final exams = data['data'] as List;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Choose Exam', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: exams.length,
                itemBuilder: (context, index) {
                  final exam = exams[index];
                  return ListTile(
                    title: Text(
                      exam['name'],
                      style: TextStyle(
                        color: exam['name'] == selectedExam ? Colors.blue : Colors.black,
                        fontWeight: exam['name'] == selectedExam ? FontWeight.bold : null,
                      ),
                    ),
                    onTap: () {
                      onSelected(exam['exam_id'], exam['name']);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}
