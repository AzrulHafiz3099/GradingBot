import 'package:flutter/material.dart';
import '/utils/colors.dart';

class StudentResultPage extends StatelessWidget {
  const StudentResultPage({super.key});

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
          children: const [
            SizedBox(height: 10),
            Text('Class', style: TextStyle(color: Colors.grey, fontSize: 12)),
            SizedBox(height: 4),
            TextField(
              decoration: InputDecoration(
                hintText: 'Enter class',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text('Exam', style: TextStyle(color: Colors.grey, fontSize: 12)),
            SizedBox(height: 4),
            TextField(
              decoration: InputDecoration(
                hintText: 'Enter exam name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text('Student Name', style: TextStyle(color: Colors.grey, fontSize: 12)),
            SizedBox(height: 4),
            TextField(
              decoration: InputDecoration(
                hintText: 'Enter student name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text('No. of Question', style: TextStyle(color: Colors.grey, fontSize: 12)),
            SizedBox(height: 4),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter number of questions',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text('Total Marks', style: TextStyle(color: Colors.grey, fontSize: 12)),
            SizedBox(height: 4),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter total marks',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text('Score', style: TextStyle(color: Colors.grey, fontSize: 12)),
            SizedBox(height: 4),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter student score',
                
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
            SizedBox(height: 32),
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
              // Handle Confirm
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }
}
