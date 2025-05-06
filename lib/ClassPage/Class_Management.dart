import 'package:flutter/material.dart';
import 'Add_Class.dart';
import 'Update_Class.dart';
import '/utils/colors.dart';

class ClassManagementPage extends StatelessWidget {
  const ClassManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> classes = List.generate(4, (index) => {
          'className': 'Software Requirement and Design',
          'classCode': 'BITP2223',
          'session': '1',
          'year': '2024',
        });

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
          'Class Management',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2BA8FF),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // Table Header
            const Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    'Class Name',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Class Code',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Session / Year',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(),

            // Table Content
            Expanded(
              child: ListView.builder(
                itemCount: classes.length,
                itemBuilder: (context, index) {
                  final classItem = classes[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UpdateClassPage(
                            className: 'Software Requirement and Design',
                            classCode: 'BITP2223',
                            session: '1',
                            year: '2024',
                          ),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: Text(classItem['className']!),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(classItem['classCode']!),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                  "${classItem['session']} / ${classItem['year']}"),
                            ),
                          ],
                        ),
                        const Divider(),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // Add Class Button
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddClassPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2BA8FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Add Class',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
