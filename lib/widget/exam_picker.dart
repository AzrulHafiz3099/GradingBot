import 'package:flutter/material.dart';

typedef OnExamSelected = void Function(String selectedExam);

final List<String> exams = [
  'Choose Exam',
  'FINAL 2/2024',
  'MIDTERM 2/2024',
  'QUIZ 1 2/2024',
  'QUIZ 2 2/2024',
  'TEST 1 2/2024',
  'TEST 2 2/2024',
  'PRACTICAL 2/2024',
  'FINAL 1/2024',
  'MIDTERM 1/2024',
  'QUIZ 1 1/2024',
  'QUIZ 2 1/2024',
  // Add more items if needed
];

Future<void> showExamPicker({
  required BuildContext context,
  required String selectedExam,
  required OnExamSelected onSelected,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            SizedBox(
              height: 300, // adjust this value as needed
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: exams.length,
                itemBuilder: (context, index) {
                  final exam = exams[index];
                  return ListTile(
                    title: Text(
                      exam,
                      style: TextStyle(
                        color: exam == selectedExam ? Colors.blue : Colors.black,
                        fontWeight: exam == selectedExam ? FontWeight.bold : null,
                      ),
                    ),
                    onTap: () {
                      onSelected(exam);
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
