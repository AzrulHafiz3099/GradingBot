import 'package:flutter/material.dart';
import '/utils/colors.dart';
import '/widget/class_picker.dart';
import '/widget/exam_picker.dart';
import '/widget/student_picker.dart';
import 'package:flutter/services.dart';
import 'Scan_Answer.dart';

class SubmissionPage extends StatefulWidget {
  const SubmissionPage({super.key});

  @override
  State<SubmissionPage> createState() => _SubmissionPageState();
}

class _SubmissionPageState extends State<SubmissionPage> {
  String selectedClass = 'Choose Class';
  String selectedExam = 'Choose Exam';
  String selectedStudent = 'Choose Student';
  TextEditingController questionController = TextEditingController();

  void _showClassPicker() {
    showClassPicker(
      context: context,
      selectedClass: selectedClass,
      onSelected: (value) {
        setState(() {
          selectedClass = value;
        });
      },
    );
  }

  void _showExamPicker() {
    showExamPicker(
      context: context,
      selectedExam: selectedExam,
      onSelected: (value) {
        setState(() {
          selectedExam = value;
        });
      },
    );
  }

  void _showStudentPicker() {
    showStudentPicker(
      context: context,
      selectedStudent: selectedStudent,
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
              onTap: _showClassPicker,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(selectedClass),
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

                // Prevent leading zeros like '01', '02'
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
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              final numberText = questionController.text;
              final number = int.tryParse(numberText);

              String? errorMessage;

              if (selectedClass == 'Choose Class') {
                errorMessage = 'Please select a class.';
              } else if (selectedExam == 'Choose Exam') {
                errorMessage = 'Please select an exam.';
              } else if (selectedStudent == 'Choose Student') {
                errorMessage = 'Please select a student.';
              } else if (numberText.isEmpty) {
                errorMessage = 'Please enter the number of questions.';
              } else if (number == null) {
                errorMessage = 'Invalid number format.';
              } else if (number < 0 || number > 10) {
                errorMessage = 'Number of questions must be between 0 and 10.';
              } else if (numberText.length > 1 && numberText.startsWith('0')) {
                errorMessage = 'Do not use leading zeros (e.g. 01, 02).';
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

              // All inputs are valid, navigate to ScanAnswerPage
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
