import 'package:flutter/material.dart';
import '/utils/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/utils/env.dart';

class UpdateClassPage extends StatefulWidget {
  final String classId;
  final String className;
  final String classCode;
  final String session;
  final String year;

  const UpdateClassPage({
    super.key,
    required this.classId,
    required this.className,
    required this.classCode,
    required this.session,
    required this.year,
  });

  @override
  State<UpdateClassPage> createState() => _UpdateClassPageState();
}

class _UpdateClassPageState extends State<UpdateClassPage> {
  static const Color secondaryColor = Color(0xFF1DA1FA);

  late TextEditingController nameController;
  late TextEditingController codeController;
  late TextEditingController sessionController;
  late TextEditingController yearController;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.className);
    codeController = TextEditingController(text: widget.classCode);
    sessionController = TextEditingController(text: widget.session);
    yearController = TextEditingController(text: widget.year);
  }

  @override
  void dispose() {
    nameController.dispose();
    codeController.dispose();
    sessionController.dispose();
    yearController.dispose();
    super.dispose();
  }

  Future<void> updateClass() async {
    setState(() => isLoading = true);

    final url = Uri.parse('${Env.classApi}/classes/${widget.classId}');
    final body = {
      "class_name": nameController.text.trim(),
      "class_code": codeController.text.trim(),
      "session": sessionController.text.trim(),
      "year": yearController.text.trim(),
    };

    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        Navigator.pop(context, true); // Return success to previous screen
      } else {
        _showError(data['message'] ?? 'Failed to update class');
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> deleteClass() async {
    setState(() => isLoading = true);

    final url = Uri.parse('${Env.classApi}/classes/${widget.classId}');

    try {
      final response = await http.delete(url);

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        Navigator.pop(context, true); // Return success to previous screen
      } else {
        _showError(data['message'] ?? 'Failed to delete class');
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _confirmDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this class?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteClass();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
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
                onPressed: isLoading ? null : _confirmDeleteDialog,
                child: const Text(
                  'Delete Class',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: secondaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: isLoading ? null : updateClass,
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }
}
