import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/utils/colors.dart';
import '/utils/env.dart';
import 'Update_Scheme.dart';
import 'SchemePage.dart';

class UpdateQuestionPage extends StatefulWidget {
  final String questionId;
  final String question;
  final String marks;

  const UpdateQuestionPage({
    super.key,
    required this.questionId,
    required this.question,
    required this.marks,
  });

  @override
  State<UpdateQuestionPage> createState() => _UpdateQuestionPageState();
}

class _UpdateQuestionPageState extends State<UpdateQuestionPage> {
  late TextEditingController _questionController;
  late TextEditingController _marksController;

  bool isLoadingSchemes = false;
  List<Map<String, dynamic>> schemes = [];

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.question);
    _marksController = TextEditingController(text: widget.marks);
    _fetchSchemes();
  }

  @override
  void dispose() {
    _questionController.dispose();
    _marksController.dispose();
    super.dispose();
  }

  Future<void> _fetchSchemes() async {
    if (widget.questionId.isEmpty) {
      setState(() {
        schemes = [];
      });
      return;
    }

    setState(() {
      isLoadingSchemes = true;
    });

    try {
      final url = Uri.parse(
        '${Env.baseUrl}/api_scheme/schemes?question_id=${widget.questionId}',
      );
      final response = await http.get(url);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final List<dynamic> fetchedSchemes = data['data'];
        setState(() {
          schemes =
              fetchedSchemes.map<Map<String, dynamic>>((item) {
                return {
                  'scheme_id': item['scheme_id'],
                  'scheme_text': item['scheme_text'],
                  'marks': item['marks'],
                };
              }).toList();
        });
      } else {
        _showSnackBar('Failed to load schemes');
      }
    } catch (e) {
      _showSnackBar('Error loading schemes: $e');
    } finally {
      setState(() {
        isLoadingSchemes = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _updateQuestion() async {
    final questionText = _questionController.text.trim();
    final marksText = _marksController.text.trim();
    final marks = double.tryParse(marksText) ?? 0.0;

    if (questionText.isEmpty) {
      _showSnackBar('Question text cannot be empty.');
      return;
    }

    final noChanges =
        questionText == widget.question && marksText == widget.marks;
    if (noChanges) {
      Navigator.pop(context, true);
      return;
    }

    final url = Uri.parse(
      '${Env.baseUrl}/api_question/questions/${widget.questionId}',
    );

    final body = jsonEncode({
      "question_text": questionText,
      "total_marks": marks, // now a double
    });

    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        _showSnackBar('Question updated successfully.');
        Navigator.pop(context, true);
      } else {
        _showSnackBar('Failed to update question.');
      }
    } catch (e) {
      _showSnackBar('Error updating question: $e');
    }
  }

  String? _validateMarks(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter the total marks';
    }
    final double? marks = double.tryParse(value.trim());
    if (marks == null) {
      return 'Please enter a valid number';
    }
    if (marks <= 0) {
      return 'Marks must be greater than zero';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Disable back navigation
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false, // Remove back arrow
          title: const Text(
            'Update Question',
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
                        const Text('Question'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _questionController,
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
                        const Text('Total Marks'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _marksController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                          ),
                          validator: _validateMarks,
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () async {
                              final added = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => AddSchemePage(
                                        questionId: widget.questionId,
                                      ),
                                ),
                              );
                              if (added == true) _fetchSchemes();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Add Scheme',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Manage Scheme',
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
                                'Scheme',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  'Marks',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        if (isLoadingSchemes)
                          const Center(child: CircularProgressIndicator())
                        else if (schemes.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(12),
                            child: Text('No schemes found.'),
                          )
                        else
                          Column(
                            children:
                                schemes.map((scheme) {
                                  return Column(
                                    children: [
                                      InkWell(
                                        onTap: () async {
                                          final updated = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => UpdateSchemePage(
                                                    questionId:
                                                        widget.questionId,
                                                    schemeId:
                                                        scheme['scheme_id']
                                                            .toString(),
                                                    schemeText:
                                                        scheme['scheme_text'] ??
                                                        '',
                                                    marks:
                                                        scheme['marks']
                                                            .toString(),
                                                  ),
                                            ),
                                          );
                                          if (updated == true) _fetchSchemes();
                                        },
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                scheme['scheme_text'] ?? '',
                                              ),
                                            ),
                                            Expanded(
                                              child: Center(
                                                child: Text(
                                                  scheme['marks']?.toString() ??
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
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      title: const Text("Confirm Delete"),
                                      content: const Text(
                                        "Are you sure you want to delete this question and all related schemes?",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, false),
                                          child: const Text("Cancel"),
                                        ),
                                        TextButton(
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, true),
                                          child: const Text("Delete"),
                                        ),
                                      ],
                                    ),
                              );

                              if (confirm == true) {
                                try {
                                  final url = Uri.parse(
                                    '${Env.baseUrl}/api_question/questions/${widget.questionId}',
                                  );
                                  final response = await http.delete(url);

                                  final data = jsonDecode(response.body);
                                  if (response.statusCode == 200 &&
                                      data['success'] == true) {
                                    _showSnackBar(
                                      'Question deleted successfully.',
                                    );
                                    Navigator.pop(context, true);
                                  } else {
                                    _showSnackBar(
                                      data['message'] ??
                                          'Failed to delete question.',
                                    );
                                  }
                                } catch (e) {
                                  _showSnackBar('Error deleting question: $e');
                                }
                              }
                            },
                            child: const Text(
                              'Delete Question',
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
                    onPressed: _updateQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
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
