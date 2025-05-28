import 'package:flutter/material.dart';
import '/utils/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/utils/env.dart';
import '/widget/class_picker.dart'; // <-- Add this line
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UpdateStudentPage extends StatefulWidget {
  final String studentId;
  final String selectedClass;
  final String currentName;
  final String currentMatrix;
  final String currentPhone;

  const UpdateStudentPage({
    super.key,
    required this.studentId,
    required this.selectedClass,
    required this.currentName,
    required this.currentMatrix,
    required this.currentPhone,
  });

  @override
  State<UpdateStudentPage> createState() => _UpdateStudentPageState();
}

class _UpdateStudentPageState extends State<UpdateStudentPage> {
  late TextEditingController nameController;
  late TextEditingController matrixController;
  late TextEditingController phoneController;
  bool isLoading = false;

  final secureStorage = const FlutterSecureStorage();
  String? lecturerId;

  late String selectedClassName;
  String? selectedClassId;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.currentName);
    matrixController = TextEditingController(text: widget.currentMatrix);
    phoneController = TextEditingController(text: widget.currentPhone);
    selectedClassName = widget.selectedClass;
    _loadLecturerId();
  }

  Future<void> _loadLecturerId() async {
    final id = await secureStorage.read(key: 'lecturer_id');
    setState(() => lecturerId = id);
  }

  void _showClassPicker() {
    if (lecturerId == null) return;

    showClassPicker(
      context: context,
      selectedClass: selectedClassName,
      lecturerId: lecturerId!,
      onSelected: (classId, className) {
        setState(() {
          selectedClassId = classId;
          selectedClassName = className;
        });
      },
    );
  }

  Future<void> _updateStudent() async {
    final name = nameController.text.trim();
    final matrix = matrixController.text.trim();
    final phone = phoneController.text.trim();

    if (name.isEmpty || matrix.isEmpty || phone.isEmpty) {
      _showSnackBar('Please fill in all fields.');
      return;
    }

    final isUnchanged =
        name == widget.currentName.trim() &&
        matrix == widget.currentMatrix.trim() &&
        phone == widget.currentPhone.trim() &&
        selectedClassName == widget.selectedClass;

    setState(() => isLoading = true);

    try {
      if (isUnchanged) {
        Navigator.pop(context, true);
        return;
      }

      final body = {
        'name': name,
        'matrix': matrix,
        'phone': phone,
        if (selectedClassId != null) 'class_id': selectedClassId,
      };

      final response = await http.put(
        Uri.parse('${Env.baseUrl}/api_student/students/${widget.studentId}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        _showSnackBar('Student updated successfully!');
        Navigator.pop(context, true);
      } else {
        _showSnackBar(data['message'] ?? 'Failed to update student.');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _deleteStudent() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete this student?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => isLoading = true);

    try {
      final response = await http.delete(
        Uri.parse('${Env.baseUrl}/api_student/students/${widget.studentId}'),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        _showSnackBar('Student deleted successfully!');
        Navigator.pop(context, true);
      } else {
        _showSnackBar(data['message'] ?? 'Failed to delete student.');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
            const Text('Class', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 4),
            InkWell(
              onTap: _showClassPicker,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(selectedClassName),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Student Name', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 4),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: 'Enter student name',
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Matrix Number', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 4),
            TextField(
              controller: matrixController,
              decoration: const InputDecoration(
                hintText: 'Enter matrix number',
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Phone No.', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 4),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: 'Enter phone number',
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
              ),
            ),
            const SizedBox(height: 24),
            if (isLoading) const Center(child: CircularProgressIndicator()),
            Center(
              child: TextButton(
                onPressed: isLoading ? null : _deleteStudent,
                child: const Text('Delete Student', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
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
            onPressed: isLoading ? null : _updateStudent,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Update', style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }
}
