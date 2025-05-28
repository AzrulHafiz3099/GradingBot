import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/utils/env.dart';

class AddSchemePage extends StatefulWidget {
  final String questionId;

  const AddSchemePage({
    Key? key,
    required this.questionId,
  }) : super(key: key);

  @override
  State<AddSchemePage> createState() => _AddSchemePageState();
}

class _AddSchemePageState extends State<AddSchemePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _schemeController;
  late TextEditingController _marksController;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _schemeController = TextEditingController();
    _marksController = TextEditingController();
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

  String? _validateScheme(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter the scheme text';
    }
    return null;
  }

  String? _validateMarks(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter marks';
    }
    final int? marks = int.tryParse(value.trim());
    if (marks == null) {
      return 'Please enter a valid number';
    }
    if (marks <= 0) {
      return 'Marks must be greater than zero';
    }
    return null;
  }

  Future<void> _addScheme() async {
    if (!_formKey.currentState!.validate()) {
      // Form not valid, don't proceed
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final url = Uri.parse('${Env.baseUrl}/api_scheme/schemes'); // POST to this route
    final body = jsonEncode({
      "question_id": widget.questionId,
      "scheme_text": _schemeController.text.trim(),
      "marks": int.parse(_marksController.text.trim()),
    });

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        _showSnackBar('Scheme added successfully.');
        Navigator.pop(context, true);
      } else {
        setState(() {
          _errorMessage = data['message'] ?? 'Failed to add scheme.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error adding scheme: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2BA8FF)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add Scheme',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2BA8FF),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              const Text('Scheme'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _schemeController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                validator: _validateScheme,
                maxLines: null,
              ),
              const SizedBox(height: 12),
              const Text('Marks'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _marksController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                validator: _validateMarks,
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _addScheme,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2BA8FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Confirm',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
