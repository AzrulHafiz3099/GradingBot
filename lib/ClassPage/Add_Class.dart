import 'package:flutter/material.dart';
import '/utils/colors.dart';

class AddClassPage extends StatelessWidget {
  const AddClassPage({super.key});

  static const Color secondaryColor = Color(0xFF1DA1FA);

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
          'Add Class',
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
          children: const [
            SizedBox(height: 10),
            Text(
              'Class Name',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            SizedBox(height: 4),
            TextField(
              decoration: InputDecoration(
                hintText: 'Enter Class Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Class Code',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            SizedBox(height: 4),
            TextField(
              decoration: InputDecoration(
                hintText: 'Enter Class Code',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Session',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            SizedBox(height: 4),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter Session',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Year',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            SizedBox(height: 4),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter Year',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
            SizedBox(height: 100), // give some breathing room above the button
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              // handle confirm logic here
            },
            child: const Text(
              'Confirm',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
