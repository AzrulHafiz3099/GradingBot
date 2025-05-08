import 'package:flutter/material.dart';

typedef OnStudentSelected = void Function(String selectedStudent);

final List<String> students = [
  'Choose Student',
  'AZRUL HAFIZ BIN ABDULLAH',
  'MOHAMAD IMAN AKMAL BIN ISMAIL',
  'AMIR HAMZAH BIN MOHD ZAMRI',
  'NUR AMALINA AQILAH BINTI MOHD NAPI',
  'STUDENT 5',
  'STUDENT 6',
  'STUDENT 7',
  'STUDENT 8',
];

Future<void> showStudentPicker({
  required BuildContext context,
  required String selectedStudent,
  required OnStudentSelected onSelected,
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
            SizedBox(
              height: 300, // Match exam picker height
              child: ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];
                  return ListTile(
                    title: Text(
                      student,
                      style: TextStyle(
                        color: student == selectedStudent ? Colors.blue : Colors.black,
                        fontWeight: student == selectedStudent ? FontWeight.bold : null,
                      ),
                    ),
                    onTap: () {
                      onSelected(student);
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
