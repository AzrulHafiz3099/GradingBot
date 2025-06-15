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
        students = (data['data'] as List)
            .map<Map<String, String>>((student) => {
                  'id': student['student_id'].toString(),
                  'name': student['name'].toString(),
                })
            .toList();
      }
    }
  } catch (_) {
    students = [];
  }

  if (students.isEmpty) return;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) {
      return _StudentPickerSheet(
        students: students,
        selectedStudent: selectedStudent,
        onSelected: onSelected,
      );
    },
  );
}

class _StudentPickerSheet extends StatefulWidget {
  final List<Map<String, String>> students;
  final String selectedStudent;
  final OnStudentSelected onSelected;

  const _StudentPickerSheet({
    required this.students,
    required this.selectedStudent,
    required this.onSelected,
  });

  @override
  State<_StudentPickerSheet> createState() => _StudentPickerSheetState();
}

class _StudentPickerSheetState extends State<_StudentPickerSheet> {
  late List<Map<String, String>> filteredStudents;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    filteredStudents = widget.students;
  }

  void updateSearch(String query) {
    setState(() {
      searchQuery = query;
      filteredStudents = widget.students
          .where((student) =>
              student['name']!
                  .toLowerCase()
                  .contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
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
          TextField(
            decoration: InputDecoration(
              hintText: 'Search student...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            ),
            onChanged: updateSearch,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 300,
            child: filteredStudents.isEmpty
                ? const Center(child: Text('No students found'))
                : ListView.builder(
                    itemCount: filteredStudents.length,
                    itemBuilder: (context, index) {
                      final student = filteredStudents[index];
                      return ListTile(
                        title: Text(
                          student['name']!,
                          style: TextStyle(
                            color: student['name'] == widget.selectedStudent
                                ? Colors.blue
                                : Colors.black,
                            fontWeight: student['name'] == widget.selectedStudent
                                ? FontWeight.bold
                                : null,
                          ),
                        ),
                        onTap: () {
                          widget.onSelected(
                            student['id']!,
                            student['name']!,
                          );
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
