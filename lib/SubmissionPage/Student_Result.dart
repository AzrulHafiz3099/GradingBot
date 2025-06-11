import 'dart:convert';

import 'package:flutter/material.dart';
import '/utils/colors.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '/utils/env.dart';
import 'package:http/http.dart' as http;
import '/main_screen.dart';

class StudentResultPage extends StatefulWidget {
  const StudentResultPage({super.key});

  @override
  State<StudentResultPage> createState() => _StudentResultPageState();
}

class _StudentResultPageState extends State<StudentResultPage> {
  final _storage = const FlutterSecureStorage();
  List<String> uploadedFiles = [];
  String? examId;
  String? studentId;
  String? classId;
  String? overallMarksSummary;
  String? submissionId;

  final TextEditingController _classController = TextEditingController();
  final TextEditingController _examController = TextEditingController();
  final TextEditingController _studentController = TextEditingController();
  final TextEditingController _totalMarksController = TextEditingController();
  final TextEditingController _scoreController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUploadedFiles();
    _loadSummaryText();
    _loadTotalMarksData();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    examId = await _storage.read(key: 'exam_id');
    classId = await _storage.read(key: 'class_id');
    studentId = await _storage.read(key: 'student_id');

    final examNameStored = await _storage.read(key: 'exam_name');
    final classNameStored = await _storage.read(key: 'class_name');
    final studentNameStored = await _storage.read(key: 'student_name');

    setState(() {
      _classController.text = classNameStored ?? '';
      _examController.text = examNameStored ?? '';
      _studentController.text = studentNameStored ?? '';
    });
  }

  Future<void> _loadUploadedFiles() async {
    final jsonRaw = await _storage.read(key: 'summary_json');
    if (jsonRaw != null) {
      final data = json.decode(jsonRaw);
      final files = <String>[];

      for (var entry in data) {
        final fileName = entry['uploaded_file'];
        files.add('Q${entry['question_number']}: $fileName');
      }

      setState(() {
        uploadedFiles = files;
      });

      // Optional: Debug print
      print("Uploaded Files: $uploadedFiles");
    } else {
      print('No uploaded files found in summary_json.');
    }
  }

  Future<void> _loadTotalMarksData() async {
    final jsonRaw = await _storage.read(key: 'summary_json');
    if (jsonRaw != null) {
      final data = json.decode(jsonRaw);

      double totalAwarded = 0;
      double totalPossible = 0;
      List<String> awardedParts = [];

      for (var entry in data) {
        final awarded = (entry['awarded_marks'] as num).toDouble();
        final possible = (entry['total_marks'] as num).toDouble();

        totalAwarded += awarded;
        totalPossible += possible;
        awardedParts.add(awarded.toStringAsFixed(1));
      }

      final awardedBreakdown = awardedParts.join(' + ');
      final scoreSummary =
          '${totalAwarded.toStringAsFixed(1)} / ${totalPossible.toStringAsFixed(1)}';

      setState(() {
        _totalMarksController.text =
            awardedBreakdown; // e.g., "1.0 + 2.0 + 3.0"
        _scoreController.text = scoreSummary; // e.g., "6.0 / 6.0"
      });

      overallMarksSummary = scoreSummary;
      await _addSub();
    } else {
      print('No summary data found in secure storage.');
    }
  }

  Future<String?> _addSub() async {
    final url = Uri.parse('${Env.baseUrl}/api_submission/submit');

    final studentId = await _storage.read(key: 'student_id');
    final examId = await _storage.read(key: 'exam_id');

    if (studentId == null || examId == null) {
      print("Missing studentId or examId");
      return null;
    }

    // Load summary_json and extract file list
    final jsonRaw = await _storage.read(key: 'summary_json');
    String uploadedFolder = '';

    if (jsonRaw != null) {
      try {
        final data = json.decode(jsonRaw);
        final uploadedFiles = <String>[];

        for (var entry in data) {
          final fileName = entry['uploaded_file'];
          if (fileName != null && fileName.toString().trim().isNotEmpty) {
            uploadedFiles.add(fileName);
          }
        }

        uploadedFolder = uploadedFiles.join(',');
      } catch (e) {
        print("❌ Error parsing summary_json: $e");
        return null;
      }
    } else {
      print('No uploaded files found in summary_json.');
      return null;
    }

    final body = jsonEncode({
      "student_id": studentId,
      "exam_id": examId,
      "uploaded_folder": uploadedFolder,
    });

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        submissionId = data['submission_id'];
        print("✅ Submission inserted: $submissionId");
        return submissionId;
      } else {
        print("❌ Failed to insert submission: ${data['message']}");
        return null;
      }
    } catch (e) {
      print("❌ Error submitting to backend: $e");
      return null;
    }
  }

  Future<void> _loadSummaryText() async {
    final summary = await _storage.read(key: 'summary');
    if (summary != null) {
      print('--- Summary Text ---\n$summary\n--- End of Summary ---');
    } else {
      print('No summary found in secure storage.');
    }
  }

  Future<String?> _saveResult(String submissionId) async {
    final url = Uri.parse('${Env.baseUrl}/api_submission/confirm');

    final scoreText = _scoreController.text; // e.g. "3.0 / 3.0"
    final summaryText = await _storage.read(key: 'summary') ?? '';

    final body = jsonEncode({
      "submission_id": submissionId,
      "score": scoreText,
      "summary": summaryText,
    });

    try {
      final resp = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );
      final data = jsonDecode(resp.body);
      if (resp.statusCode == 200 && data['success'] == true) {
        print("✅ Result saved: ${data['result_id']}");
        clearSummary();
        return data['result_id'];
      } else {
        print("❌ Failed to save result: ${data['message']}");
        return null;
      }
    } catch (e) {
      print("❌ Error saving result: $e");
      return null;
    }
  }

  Future<void> clearSummary() async {
    await _storage.delete(key: 'summary');
    await _storage.delete(key: 'summary_json');
    await _storage.delete(key: 'exam_id');
    await _storage.delete(key: 'class_id');
    await _storage.delete(key: 'student_id');
    await _storage.delete(key: 'exam_name');
    await _storage.delete(key: 'class_name');
    await _storage.delete(key: 'student_name');
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
          'Student Submission',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.secondaryColor,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          children: [
            SizedBox(height: 10),
            Text('Class', style: TextStyle(color: Colors.grey, fontSize: 12)),
            SizedBox(height: 4),
            TextField(
              controller: _classController,
              readOnly: true,
              decoration: InputDecoration(
                hintText: 'Enter class',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text('Exam', style: TextStyle(color: Colors.grey, fontSize: 12)),
            SizedBox(height: 4),
            TextField(
              controller: _examController,
              readOnly: true,
              decoration: InputDecoration(
                hintText: 'Enter exam name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Student Name',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            SizedBox(height: 4),
            TextField(
              controller: _studentController,
              readOnly: true,
              decoration: InputDecoration(
                hintText: 'Enter student name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Total Marks',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            SizedBox(height: 4),
            TextField(
              controller: _totalMarksController,
              readOnly: true,
              decoration: InputDecoration(
                hintText: 'Enter total marks',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text('Score', style: TextStyle(color: Colors.grey, fontSize: 12)),
            SizedBox(height: 4),
            TextField(
              controller: _scoreController,
              readOnly: true,
              decoration: InputDecoration(
                hintText: 'Enter student score',

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () async {
              if (submissionId != null) {
                final resultId = await _saveResult(submissionId!);

                if (resultId != null) {
                  if (!mounted) return;
                  Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MainScreen()),
              );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('❌ Failed to save result.')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('❌ Submission ID not available.'),
                  ),
                );
              }
            },

            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }
}
