import 'package:flutter/material.dart';
import 'QuestionPage.dart';

class UpdateExamPage extends StatelessWidget {
  final String examName;

  const UpdateExamPage({super.key, required this.examName});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _examNameController = TextEditingController(text: examName);

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
          'Update Exam',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2BA8FF)),
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
              controller: _examNameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AddQuestionPage()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2BA8FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Manage Question', style: TextStyle(color: Colors.white)),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: () {
                  // Save updated exam logic
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2BA8FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Update', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
