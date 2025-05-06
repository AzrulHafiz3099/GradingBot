import 'package:flutter/material.dart';
import '/utils/colors.dart';
import 'Update_Student.dart';
import 'Add_Student.dart';
import '/widget/class_picker.dart';

class StudentManagementPage extends StatefulWidget {
  const StudentManagementPage({super.key});

  @override
  _StudentManagementPageState createState() => _StudentManagementPageState();
}

class _StudentManagementPageState extends State<StudentManagementPage> {
  String selectedClass = 'Choose Class';

  final List<Map<String, String>> students = List.generate(
    4,
    (index) => {
      'name': 'AZRUL HAFIZ BIN ABDULLAH',
      'matrix': 'B032310228',
      'phone': '0123456789',
    },
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
          'Student Management',
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

            // Class selection
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
                  flex: 4,
                  child: Text(
                    'Student Name',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Matrix No.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Phone No.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(),

            // Student list
            Expanded(
              child: ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => UpdateStudentPage(
                                name: student['name']!,
                                matrix: student['matrix']!,
                                phone: student['phone']!,
                                selectedClass:
                                    selectedClass, // Pass selectedClass here
                              ),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(flex: 4, child: Text(student['name']!)),
                            Expanded(flex: 3, child: Text(student['matrix']!)),
                            Expanded(flex: 3, child: Text(student['phone']!)),
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

            // Add Student Button
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => AddStudentPage(
                            selectedClass: selectedClass,
                          ), // Remove const here
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
                  'Add Student',
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
