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
  
  // TextEditingController questionController = TextEditingController(); // 🔒 Commented: used for number of questions

  final secureStorage = const FlutterSecureStorage();
  String? lecturerId;
  String? selectedClassId;
  String? selectedExamId;

  @override
  void initState() {
    super.initState();
    _loadLecturerId(); // Load lecturer ID at start
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
      onSelected: (value) {
        setState(() {
          selectedStudent = value;
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
              'Student Name',
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

            // 🔒 Commented out - No. of Question Input
            /*
            const Text(
              'No. of Question (Max - 10)',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: questionController,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                if (value.isEmpty) return;

                if (value.length > 1 && value.startsWith('0')) {
                  questionController.text = value.substring(1);
                  questionController.selection = TextSelection.fromPosition(
                    TextPosition(offset: questionController.text.length),
                  );
                  return;
                }

                final number = int.tryParse(value);

                if (number == null || number < 0 || number > 10) {
                  questionController.text = '10';
                  questionController.selection = const TextSelection.collapsed(
                    offset: 2,
                  );
                }
              },
              decoration: const InputDecoration(
                hintText: 'Enter number of questions',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
            */
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
              // final numberText = questionController.text; // 🔒 Commented
              // final number = int.tryParse(numberText); // 🔒 Commented

              String? errorMessage;

              if (selectedClass == 'Choose Class') {
                errorMessage = 'Please select a class.';
              } else if (selectedExam == 'Choose Exam') {
                errorMessage = 'Please select an exam.';
              } else if (selectedStudent == 'Choose Student') {
                errorMessage = 'Please select a student.';
              }
              /*
              else if (numberText.isEmpty) {
                errorMessage = 'Please enter the number of questions.';
              } else if (number == null) {
                errorMessage = 'Invalid number format.';
              } else if (number < 0 || number > 10) {
                errorMessage = 'Number of questions must be between 0 and 10.';
              } else if (numberText.length > 1 && numberText.startsWith('0')) {
                errorMessage = 'Do not use leading zeros (e.g. 01, 02).';
              }
              */

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
                value: selectedStudent,
              );

              // ✅ Navigate to Scan Answer Page
              Navigator.push(
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
