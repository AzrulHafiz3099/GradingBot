import 'package:flutter/material.dart';
import 'QuestionPage.dart';
import '/utils/colors.dart';

class AddExamPage extends StatelessWidget {
  const AddExamPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2BA8FF)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add Exam',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2BA8FF),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Exam Name'),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: 'FINAL 2/2024',
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
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
                          (context) => AddQuestionPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2BA8FF),
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
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Question',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign:
                        TextAlign
                            .start, // Ensuring "Question" is aligned to the left
                  ),
                ),
                Expanded(
                  child: Text(
                    'Total Marks',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center, // Centering "Total Marks"
                  ),
                ),
                Expanded(
                  child: Text(
                    'Total Keywords',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center, // Centering "Total Keywords"
                  ),
                ),
              ],
            ),
            const Divider(),
            const Row(
              children: [
                Expanded(flex: 3, child: Text('Give 2 Prime Number of 2.')),
                Expanded(child: Center(child: Text('2'))),
                Expanded(child: Center(child: Text('2'))),
              ],
            ),
            const Divider(),
            const SizedBox(height: 10),
            Center(
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  'Delete Exam',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2BA8FF),
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
    );
  }
}
