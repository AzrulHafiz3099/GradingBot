import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import '/utils/colors.dart';
import 'Student_Result.dart';

class ScanAnswerPage extends StatelessWidget {
  const ScanAnswerPage({super.key});

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
            const SizedBox(height: 16),
            const Text(
              'Question',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 4),
            const TextField(
              decoration: InputDecoration(
                hintText: 'Enter question',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Total Keywords',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 4),
            const TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter total keywords',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Keyword 1',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 4),
            const TextField(
              decoration: InputDecoration(
                hintText: 'e.g. One / 1',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Keyword 2',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 4),
            const TextField(
              decoration: InputDecoration(
                hintText: 'e.g. Two / 2',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 24),

            GestureDetector(
              onTap: () {
                debugPrint('clicked');
              },
              child: DottedBorder(
                color: Colors.blue.shade300,
                strokeWidth: 1,
                dashPattern: [6, 3],
                borderType: BorderType.RRect,
                radius: const Radius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: const [
                      Icon(
                        Icons.cloud_upload_outlined,
                        size: 40,
                        color: Colors.blue,
                      ),
                      SizedBox(height: 12),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: 'Drag your file(s) or '),
                            TextSpan(
                              text: 'browse',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Max 10 MB files are allowed',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Total Marks Received',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 4),
            const TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter marks',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StudentResultPage(),
                    ),
                  );
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Next',
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
