import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/utils/env.dart';

typedef OnExamSelected = void Function(String examId, String examName);

Future<void> showExamPicker({
  required BuildContext context,
  required String selectedExam,
  required String classId,
  required OnExamSelected onSelected,
}) async {
  List<Map<String, dynamic>> exams = [];

  try {
    final response = await http.get(Uri.parse('${Env.baseUrl}/api_exam/exams?class_id=$classId'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true && data['data'] is List) {
        exams = List<Map<String, dynamic>>.from(data['data']);
      }
    }
  } catch (_) {
    exams = [];
  }

  if (exams.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No exams found')),
    );
    return;
  }

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _ExamPickerSheet(
      exams: exams,
      selectedExam: selectedExam,
      onSelected: onSelected,
    ),
  );
}

class _ExamPickerSheet extends StatefulWidget {
  final List<Map<String, dynamic>> exams;
  final String selectedExam;
  final OnExamSelected onSelected;

  const _ExamPickerSheet({
    required this.exams,
    required this.selectedExam,
    required this.onSelected,
  });

  @override
  State<_ExamPickerSheet> createState() => _ExamPickerSheetState();
}

class _ExamPickerSheetState extends State<_ExamPickerSheet> {
  late List<Map<String, dynamic>> filteredExams;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    filteredExams = widget.exams;
  }

  void updateSearch(String query) {
    setState(() {
      searchQuery = query;
      filteredExams = widget.exams
          .where((exam) =>
              exam['name'].toString().toLowerCase().contains(query.toLowerCase()))
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
                'Choose Exam',
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
              hintText: 'Search exam...',
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
            child: filteredExams.isEmpty
                ? const Center(child: Text('No exams found'))
                : ListView.builder(
                    itemCount: filteredExams.length,
                    itemBuilder: (context, index) {
                      final exam = filteredExams[index];
                      return ListTile(
                        title: Text(
                          exam['name'],
                          style: TextStyle(
                            color: exam['name'] == widget.selectedExam
                                ? Colors.blue
                                : Colors.black,
                            fontWeight: exam['name'] == widget.selectedExam
                                ? FontWeight.bold
                                : null,
                          ),
                        ),
                        onTap: () {
                          widget.onSelected(exam['exam_id'], exam['name']);
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
