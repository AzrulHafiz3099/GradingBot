import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/utils/env.dart';

typedef OnStudentSelected = void Function(String studentId, String studentName);

Future<void> showStudentPicker({
  required BuildContext context,
  required String selectedStudent,
  required String classId,
  required OnStudentSelected onSelected,
}) async {
  List<Map<String, String>> students = [];

  try {
    final response = await http.get(
      Uri.parse('${Env.baseUrl}/api_student/students?class_id=$classId'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        students =
            (data['data'] as List)
                .map<Map<String, String>>(
                  (student) => {
                    'id': student['student_id'].toString(),
                    'name': student['name'].toString(),
                  },
                )
                .toList();
      }
    } else {
      throw Exception('Failed to load students');
    }
  } catch (e) {
    // Optional: show error dialog/snackbar here
    students = [];
  }

  if (students.isEmpty) {}

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
                const Text(
                  'Choose Student',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
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
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];
                  return ListTile(
                    title: Text(
                      student['name']!,
                      style: TextStyle(
                        color:
                            student['name'] == selectedStudent
                                ? Colors.blue
                                : Colors.black,
                        fontWeight:
                            student['name'] == selectedStudent
                                ? FontWeight.bold
                                : null,
                      ),
                    ),
                    onTap: () {
                      onSelected(
                        student['id']!,
                        student['name']!,
                      ); // ✅ Pass both ID and name
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
