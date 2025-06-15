import 'package:flutter/material.dart';
import '/utils/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/utils/env.dart';
import 'QuestionPage.dart';
import 'Update_Question.dart'; // <- make sure the path is correct

class UpdateExamPage extends StatefulWidget {
  final Map<String, dynamic> examData;

  const UpdateExamPage({super.key, required this.examData});

  @override
  State<UpdateExamPage> createState() => _UpdateExamPageState();
}

class _UpdateExamPageState extends State<UpdateExamPage> {
  late TextEditingController _examNameController;
  bool isLoading = false;
  List<dynamic> questions = [];
  bool isQuestionsLoading = true;

  @override
  void initState() {
    super.initState();
    _examNameController = TextEditingController(
      text: widget.examData['name'] ?? '',
    );
    _fetchQuestions();
  }

  @override
  void dispose() {
    _examNameController.dispose();
    super.dispose();
  }

  Future<void> _fetchQuestions() async {
    setState(() => isQuestionsLoading = true);
    try {
      final response = await http.get(
        Uri.parse(
          '${Env.baseUrl}/api_question/questions?exam_id=${widget.examData['exam_id']}',
        ),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        setState(() => questions = data['data']);
      } else {
        _showSnackBar('Failed to load questions');
      }
    } catch (e) {
      _showSnackBar('Error loading questions: $e');
    } finally {
      setState(() => isQuestionsLoading = false);
    }
  }

  Future<void> _updateExam() async {
    final newName = _examNameController.text.trim();
    final oldName = widget.examData['name']?.trim() ?? '';

    if (newName.isEmpty) {
      _showSnackBar('Exam name cannot be empty.');
      return;
    }

    // If no changes, skip API call and go back quietly
    if (newName == oldName) {
      Navigator.pop(context, true); // Just go back
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.put(
        Uri.parse(
          '${Env.baseUrl}/api_exam/exams/${widget.examData['exam_id']}',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': newName}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        _showSnackBar('Exam updated successfully.');
      } else {
        _showSnackBar(data['message'] ?? 'Failed to update exam.');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    } finally {
      setState(() => isLoading = false);
      Navigator.pop(context, true); // Always go back
    }
  }

  Future<void> _deleteExam() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Confirm Delete"),
            content: const Text("Are you sure you want to delete this exam?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    setState(() => isLoading = true);

    try {
      final response = await http.delete(
        Uri.parse(
          '${Env.baseUrl}/api_exam/exams/${widget.examData['exam_id']}',
        ),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        _showSnackBar('Exam deleted successfully.');
        Navigator.pop(context, true);
      } else {
        _showSnackBar(data['message'] ?? 'Failed to delete exam.');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Disable system back button
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          // Remove the back arrow button by not specifying leading:
          automaticallyImplyLeading: false,
          title: const Text(
            'Update Exam',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.secondaryColor,
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Exam Name'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _examNameController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => AddQuestionPage(
                                        examId:
                                            widget.examData['exam_id']
                                                .toString(),
                                      ),
                                ),
                              ).then((value) {
                                if (value == true) _fetchQuestions();
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Add Question',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Manage Question',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Question',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  'Total Marks',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  'Total Scheme',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        if (isQuestionsLoading)
                          const Center(child: CircularProgressIndicator())
                        else if (questions.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(12),
                            child: Text("No questions found."),
                          )
                        else
                          Column(
                            children:
                                questions.map((q) {
                                  return Column(
                                    children: [
                                      InkWell(
                                        onTap: () async {
                                          final updated = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (
                                                    context,
                                                  ) => UpdateQuestionPage(
                                                    questionId:
                                                        q['question_id']
                                                            ?.toString() ??
                                                        '',
                                                    question:
                                                        q['question_text'] ??
                                                        '',
                                                    marks:
                                                        q['total_marks']
                                                            ?.toString() ??
                                                        '0',
                                                  ),
                                            ),
                                          );
                                          if (updated == true)
                                            _fetchQuestions();
                                        },
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                q['question_text'] ?? '',
                                              ),
                                            ),
                                            Expanded(
                                              child: Center(
                                                child: Text(
                                                  q['total_marks']
                                                          ?.toString() ??
                                                      '0',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Center(
                                                child: Text(
                                                  q['total_scheme']
                                                          ?.toString() ??
                                                      '0',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Divider(),
                                    ],
                                  );
                                }).toList(),
                          ),
                        const SizedBox(height: 10),
                        Center(
                          child: TextButton(
                            onPressed: isLoading ? null : _deleteExam,
                            child: const Text(
                              'Delete Exam',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _updateExam,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child:
                        isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text(
                              'Confirm',
                              style: TextStyle(color: Colors.white),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
