import 'package:flutter/material.dart';
import 'SchemePage.dart';

class UpdateQuestionPage extends StatelessWidget {
  final String question;
  final String marks;

  const UpdateQuestionPage({super.key, required this.question, required this.marks});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _questionController = TextEditingController(text: question);
    final TextEditingController _marksController = TextEditingController(text: marks);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2BA8FF)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Update Question', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2BA8FF))),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Question'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _questionController,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Total Marks'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _marksController,
              keyboardType: TextInputType.number,
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
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AddSchemePage()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2BA8FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('Update Scheme', style: TextStyle(color: Colors.white)),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: () {
                  // Save updated question logic
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
