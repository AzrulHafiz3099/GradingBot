import 'package:flutter/material.dart';
import '/utils/colors.dart';

class UpdateClassPage extends StatelessWidget {
  final String className;
  final String classCode;
  final String session;
  final String year;

  const UpdateClassPage({
    super.key,
    required this.className,
    required this.classCode,
    required this.session,
    required this.year,
  });

  static const Color secondaryColor = Color(0xFF1DA1FA);

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController(text: className);
    final TextEditingController codeController = TextEditingController(text: classCode);
    final TextEditingController sessionController = TextEditingController(text: session);
    final TextEditingController yearController = TextEditingController(text: year);

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
          'Update Class',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: secondaryColor,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          children: [
            const SizedBox(height: 10),
            const Text('Class Name', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 4),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Class Code', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 4),
            TextField(
              controller: codeController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Session', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 4),
            TextField(
              controller: sessionController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Year', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 4),
            TextField(
              controller: yearController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: TextButton(
                onPressed: () {
                  // Implement delete logic here
                },
                child: const Text(
                  'Delete Class',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            const SizedBox(height: 100), // Space above the bottom button
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: secondaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              // Implement update logic here
            },
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }
}
