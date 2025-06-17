import 'package:flutter/material.dart';
import '/utils/colors.dart';
import '/widget/class_picker.dart';
import '/widget/exam_picker.dart';
import '/widget/student_picker.dart';
import 'package:flutter/services.dart';
import 'Scan_Answer.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SubmissionPage extends StatefulWidget {
  const SubmissionPage({super.key});

  @override
  State<SubmissionPage> createState() => _SubmissionPageState();
}

class _SubmissionPageState extends State<SubmissionPage> {
  String selectedClass = 'Choose Class';
  String selectedExam = 'Choose Exam';
  String selectedStudent = 'Choose Student';

  final secureStorage = const FlutterSecureStorage();
  String? lecturerId;
  String? selectedClassId;
  String? selectedExamId;
  String? selectedStudentId;

  @override
  void initState() {
    super.initState();
    _loadLecturerId(); // Load lecturer ID at start
    clearSummary();
  }

  Future<void> clearSummary() async {
    await secureStorage.delete(key: 'summary');
    await secureStorage.delete(key: 'summary_json');
  }

  Future<void> _loadLecturerId() async {
    final id = await secureStorage.read(key: 'lecturer_id');
    setState(() => lecturerId = id);
  }

  void _showClassPicker() {
    if (lecturerId == null) return; // Safety check
    showClassPicker(
      context: context,
      selectedClass: selectedClass,
      lecturerId: lecturerId!,
      onSelected: (classId, className) {
        setState(() {
          selectedClass = className;
          selectedClassId = classId;
          selectedExam = 'Choose Exam'; // Reset exam
          selectedExamId = null;
          selectedStudent = 'Choose Student'; // Reset student
        });
      },
    );
  }

  void _showExamPicker() {
    if (selectedClassId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a class first')),
      );
      return;
    }

    showExamPicker(
      context: context,
      selectedExam: selectedExam,
      classId: selectedClassId!,
      onSelected: (examId, examName) {
        setState(() {
          selectedExam = examName;
          selectedExamId = examId;
        });
      },
    );
  }

  void _showStudentPicker() {
  if (selectedClassId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select a class first')),
    );
    return;
  }

  showStudentPicker(
    context: context,
    selectedStudent: selectedStudent,
    classId: selectedClassId!,
    onSelected: (studentId, studentName) {
      setState(() {
        selectedStudent = studentName;
        selectedStudentId = studentId; // Store actual ID
      });
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
            const SizedBox(height: 10),
            const Text(
              'Class',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 4),
            InkWell(
              onTap: lecturerId != null ? _showClassPicker : null,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(10),
                  color:
                      lecturerId == null
                          ? Colors.grey.shade200
                          : Colors.transparent,
                ),
                child: Text(
                  lecturerId == null ? 'Loading...' : selectedClass,
                  style: TextStyle(
                    color: lecturerId == null ? Colors.grey : Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Exam',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 4),
            InkWell(
              onTap: _showExamPicker,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(selectedExam),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Matrix Number',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 4),
            InkWell(
              onTap: _showStudentPicker,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(selectedStudent),
              ),
            ),
            const SizedBox(height: 16),

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

              String? errorMessage;

              if (selectedClass == 'Choose Class') {
                errorMessage = 'Please select a class.';
              } else if (selectedExam == 'Choose Exam') {
                errorMessage = 'Please select an exam.';
              } else if (selectedStudent == 'Choose Student') {
                errorMessage = 'Please select a student.';
              }

              if (errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(errorMessage),
                    backgroundColor: Colors.red,
                    duration: const Duration(milliseconds: 2000),
                  ),
                );
                return;
              }

              // ✅ Save to secure storage
              await secureStorage.write(
                key: 'class_id',
                value: selectedClassId,
              );
              await secureStorage.write(key: 'exam_id', value: selectedExamId);
              await secureStorage.write(
                key: 'student_id',
                value: selectedStudentId,
              );

              await secureStorage.write(key: 'class_name', value: selectedClass);
              await secureStorage.write(key: 'exam_name', value: selectedExam);
              await secureStorage.write(key: 'student_name', value: selectedStudent);

              // ✅ Navigate to Scan Answer Page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ScanAnswerPage()),
              );
            },

            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Scan Answer',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
