import 'package:flutter/material.dart';

class UpdateSchemePage extends StatelessWidget {
  final String scheme;
  final String marks;
  final String question;

  const UpdateSchemePage({
    super.key,
    required this.scheme,
    required this.marks,
    required this.question,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController _schemeController = TextEditingController(text: scheme);
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
        title: const Text(
          'Update Scheme',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2BA8FF)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Question'),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: question,
              readOnly: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Scheme'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _schemeController,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Marks'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _marksController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: () {
                  // Save updated scheme logic
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
