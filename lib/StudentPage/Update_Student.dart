import 'package:flutter/material.dart';
import '/utils/colors.dart';
import '/widget/class_picker.dart';

class UpdateStudentPage extends StatefulWidget {
  final String name;
  final String matrix;
  final String phone;
  final String selectedClass; // Add selectedClass here

  const UpdateStudentPage({
    super.key,
    required this.name,
    required this.matrix,
    required this.phone,
    required this.selectedClass, // Add required selectedClass parameter
  });

  @override
  State<UpdateStudentPage> createState() => _UpdateStudentPageState();
}

class _UpdateStudentPageState extends State<UpdateStudentPage> {

  late String selectedClass;
  late TextEditingController nameController;
  late TextEditingController matrixController;
  late TextEditingController phoneController;

  @override
  void initState() {
    super.initState();
    selectedClass = widget.selectedClass; // Use the passed selectedClass
    nameController = TextEditingController(text: widget.name);
    matrixController = TextEditingController(text: widget.matrix);
    phoneController = TextEditingController(text: widget.phone);
  }

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
          'Update Student',
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
            const SizedBox(height: 10),
            const Text(
              'Class',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 4),
            InkWell(
              onTap: _showClassPicker,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(selectedClass),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Student Name',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Matrix Number',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: matrixController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Phone No.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Center(
              child: TextButton(
                onPressed: () {
                  // Implement delete logic
                },
                child: const Text(
                  'Delete Student',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 100),
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
              // Confirm logic
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
