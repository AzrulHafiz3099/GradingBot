import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/utils/env.dart';

class UpdateSchemePage extends StatefulWidget {
  final String questionId;
  final String schemeId;
  final String schemeText;
  final String marks;

  const UpdateSchemePage({
    Key? key,
    required this.questionId,
    required this.schemeId,
    required this.schemeText,
    required this.marks,
  }) : super(key: key);

  @override
  State<UpdateSchemePage> createState() => _UpdateSchemePageState();
}

class _UpdateSchemePageState extends State<UpdateSchemePage> {
  late TextEditingController _schemeController;
  late TextEditingController _marksController;

  @override
  void initState() {
    super.initState();
    _schemeController = TextEditingController(text: widget.schemeText);
    _marksController = TextEditingController(text: widget.marks);
  }

  @override
  void dispose() {
    _schemeController.dispose();
    _marksController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _updateScheme() async {
    final schemeText = _schemeController.text.trim();
    final marksText = _marksController.text.trim();
    final marks = double.tryParse(marksText) ?? 0.0;

    if (schemeText == widget.schemeText.trim() && marksText == widget.marks.trim()) {
      Navigator.pop(context, false);
      return;
    }

    if (schemeText.isEmpty) {
      _showSnackBar('Scheme text cannot be empty.');
      return;
    }

    final url = Uri.parse('${Env.baseUrl}/api_scheme/schemes/${widget.schemeId}');
    final body = jsonEncode({
      "scheme_text": schemeText,
      "marks": marks,
    });

    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        _showSnackBar('Scheme updated successfully.');
        Navigator.pop(context, true);
      } else {
        _showSnackBar('Failed to update scheme.');
      }
    } catch (e) {
      _showSnackBar('Error updating scheme: $e');
    }
  }

  String? _validateMarks(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter the marks';
  }
  final double? marks = double.tryParse(value.trim());
  if (marks == null) {
    return 'Please enter a valid number';
  }
  if (marks <= 0) {
    return 'Marks must be greater than zero';
  }
  return null;
}


  Future<void> _deleteScheme() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete this scheme?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final response = await http.delete(
        Uri.parse('${Env.baseUrl}/api_scheme/schemes/${widget.schemeId}'),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        _showSnackBar('Scheme deleted successfully.');
        Navigator.pop(context, true);
      } else {
        _showSnackBar(data['message'] ?? 'Failed to delete scheme.');
      }
    } catch (e) {
      _showSnackBar('Error deleting scheme: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false, // Removes back button
          title: const Text(
            'Update Scheme',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2BA8FF)),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Scheme'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _schemeController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Marks'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _marksController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                validator: _validateMarks,
              ),
              Center(
                child: TextButton(
                  onPressed: _deleteScheme,
                  child: const Text(
                    'Delete Scheme',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: _updateScheme,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2BA8FF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Update', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
