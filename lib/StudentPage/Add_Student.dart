import 'package:flutter/material.dart';
import '/utils/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/utils/env.dart';

class AddStudentPage extends StatefulWidget {
  final String classId;
  final String className;

  const AddStudentPage({
    super.key,
    required this.classId,
    required this.className,
  });

  @override
  State<AddStudentPage> createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController matrixController;
  late TextEditingController phoneController;

  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    matrixController = TextEditingController();
    phoneController = TextEditingController();
  }

  Future<void> _addStudent() async {
    if (!_formKey.currentState!.validate()) {
      // Form is invalid, don't proceed
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('${Env.baseUrl}/api_student/students'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'class_id': widget.classId,
          'name': nameController.text.trim(),
          'matrix': matrixController.text.trim(),
          'phone': phoneController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          Navigator.pop(context, true);
        } else {
          setState(() {
            errorMessage = data['message'] ?? 'Failed to add student.';
          });
        }
      } else {
        setState(() {
          errorMessage = 'Server error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    matrixController.dispose();
    phoneController.dispose();
    super.dispose();
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
          'Add Student',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.secondaryColor,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 10),
              const Text('Class', style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(widget.className),
              ),
              const SizedBox(height: 16),

              const Text('Student Name', style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 4),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: 'Enter student name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter student name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              const Text('Matrix Number', style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 4),
              TextFormField(
                controller: matrixController,
                decoration: const InputDecoration(
                  hintText: 'Enter matrix number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter matrix number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              const Text('Phone No.', style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 4),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: 'Enter phone number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter phone number';
                  }
                  // Optional: Add a regex or length check for phone number format if needed
                  return null;
                },
              ),

              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: isLoading ? null : _addStudent,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Confirm',
                    style: TextStyle(color: Colors.white),
                  ),
          ),
        ),
      ),
    );
  }
}
