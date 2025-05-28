import 'package:flutter/material.dart';
import '/utils/colors.dart';
import '/widget/class_picker.dart'; // Your class picker widget, pass lecturerId to it
import 'ExamPage.dart'; // Your exam detail/add page
import 'Update_Exam.dart'; // Your exam detail/add page
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '/utils/env.dart'; // Env.baseUrl for API base url

class ExamManagementPage extends StatefulWidget {
  const ExamManagementPage({super.key});

  @override
  _ExamManagementPageState createState() => _ExamManagementPageState();
}

class _ExamManagementPageState extends State<ExamManagementPage> {
  final secureStorage = const FlutterSecureStorage();

  String selectedClass = 'Choose Class';
  String? selectedClassId;
  String? lecturerId;

  List<Map<String, dynamic>> exams = [];
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadLecturerId();
  }

  Future<void> _loadLecturerId() async {
    String? id = await secureStorage.read(key: 'lecturer_id');
    setState(() {
      lecturerId = id;
    });
    print('Lecturer ID from secure storage: $lecturerId');
  }

  Future<void> fetchExams(String classId) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      exams = [];
    });

    try {
      final response = await http.get(
        Uri.parse('${Env.baseUrl}/api_exam/exams?class_id=$classId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            exams = List<Map<String, dynamic>>.from(data['data']);
          });
        } else {
          setState(() {
            errorMessage = data['message'] ?? 'Failed to fetch exams';
          });
        }
      } else {
        setState(() {
          errorMessage = 'Server Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showClassPicker() {
    if (lecturerId == null) return;

    showClassPicker(
      context: context,
      selectedClass: selectedClass,
      lecturerId: lecturerId!,
      onSelected: (classId, className) {
        setState(() {
          selectedClassId = classId;
          selectedClass = className;
        });
        fetchExams(classId);
      },
    );
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
          'Exam Management',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2BA8FF),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // Class Selection
            Row(
              children: [
                const Text(
                  'Select Class',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: _showClassPicker,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[300],
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      selectedClass,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Table header
            const Row(
              children: [
                Expanded(
                  flex: 7,
                  child: Text(
                    'Exam Name',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Text(
                      'Number of Question',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),

            // Exam list
            Expanded(
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : errorMessage != null
                      ? Center(child: Text(errorMessage!))
                      : exams.isEmpty
                      ? const Center(child: Text("Select a class."))
                      : ListView.builder(
                        itemCount: exams.length,
                        itemBuilder: (context, index) {
                          final exam = exams[index];
                          return Column(
                            children: [
                              InkWell(
                                onTap: () async {
                                  final updated = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              UpdateExamPage(examData: exam),
                                    ),
                                  );

                                  if (updated == true &&
                                      selectedClassId != null) {
                                    fetchExams(
                                      selectedClassId!,
                                    ); // Refresh exam list after update
                                  }
                                },

                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 7,
                                      child: Text(exam['name'] ?? ''),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Center(
                                        child: Text(
                                          exam['question_count']?.toString() ??
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
                        },
                      ),
            ),
            const SizedBox(height: 12),

            // Add Exam Button
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed:
                    selectedClassId == null
                        ? null // disable if no class selected
                        : () async {
                          final added = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      AddExamPage(classId: selectedClassId!),
                            ),
                          );

                          if (added == true) {
                            // Refresh exams if new exam was added successfully
                            if (selectedClassId != null) {
                              fetchExams(selectedClassId!);
                            }
                          }
                        },

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2BA8FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Add Exam',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
