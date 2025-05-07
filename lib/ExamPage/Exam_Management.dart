import 'package:flutter/material.dart';
import '/utils/colors.dart';
import '/widget/class_picker.dart';
import 'ExamPage.dart';

class ExamManagementPage extends StatefulWidget {
  const ExamManagementPage({super.key});

  @override
  _ExamManagementPageState createState() => _ExamManagementPageState();
}

class _ExamManagementPageState extends State<ExamManagementPage> {
  String selectedClass = 'Choose Class';

  final List<Map<String, String>> exams = List.generate(
    1,
    (index) => {'name': 'FINAL 2/2024', 'number': '2'},
  );

  void _showClassPicker() {
    showClassPicker(
      context: context,
      selectedClass: selectedClass,
      onSelected: (newClass) {
        setState(() {
          selectedClass = newClass;
        });
      },
    );
  }

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
          'Exam Management',
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

            // Class Selection
            Row(
              children: [
                const Text(
                  'Select Class',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: _showClassPicker,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[300],
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      selectedClass,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Table header
            const Row(
              children: [
                Expanded(
                  flex: 6,
                  child: Text(
                    'Exam Name',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Center(
                    child: Text(
                      'Number of Question',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),

            const Divider(),

            // Exam list
            Expanded(
              child:
                  exams.isEmpty
                      ? const Center(child: Text("No exams available."))
                      : ListView.builder(
                        itemCount: exams.length,
                        itemBuilder: (context, index) {
                          final exam = exams[index];
                          return Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              AddExamPage(),
                                    ),
                                  );
                                },
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 6,
                                      child: Text(exam['name'] ?? ''),
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: Center(
                                        child: Text(exam['number'] ?? ''),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const Divider(),
                            ],
                          );
                        },
                      ),
            ),
            const SizedBox(height: 12),

            // Add Exam Button
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => AddExamPage(),
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
                  'Add Exam',
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
