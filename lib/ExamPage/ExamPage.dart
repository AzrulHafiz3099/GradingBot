import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/utils/env.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class AddExamPage extends StatefulWidget {
  final String classId; // You need to pass classId to create exam under a class

  const AddExamPage({Key? key, required this.classId}) : super(key: key);

  @override
  State<AddExamPage> createState() => _AddExamPageState();
}

class _AddExamPageState extends State<AddExamPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _examNameController;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isPreviewing = false;
  bool _previewReady = false;
  List<dynamic>? parsedPreview;

  File? selectedExamFile;

  @override
  void initState() {
    super.initState();
    _examNameController = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _examNameController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _addExam() async {
    if (!_formKey.currentState!.validate()) {
      // Form is invalid, do not proceed
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final url = Uri.parse('${Env.baseUrl}/api_exam/exams');
    final body = jsonEncode({
      "class_id": widget.classId,
      "name": _examNameController.text.trim(),
    });

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        _showSnackBar('Exam added successfully.');
        Navigator.pop(context, true);
      } else {
        setState(() {
          _errorMessage = data['message'] ?? 'Failed to add exam.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error adding exam: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _previewExamFile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final uri = Uri.parse('${Env.baseUrl}/api_exam/exams_file_preview');
      final request = http.MultipartRequest('POST', uri);

      request.files.add(
        await http.MultipartFile.fromPath('file', selectedExamFile!.path),
      );

      final res = await request.send();
      final response = await http.Response.fromStream(res);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        setState(() {
          parsedPreview = data['parsed'];
          _previewReady = true;
        });
      } else {
        _errorMessage = 'Failed to scan document';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addExamWithParsedData() async {
    setState(() => _isLoading = true);

    try {
      final uri = Uri.parse('${Env.baseUrl}/api_exam/exams_with_file');
      final request = http.MultipartRequest('POST', uri);

      request.fields['class_id'] = widget.classId;
      request.fields['name'] = _examNameController.text.trim();
      request.fields['parsed_data'] = jsonEncode(parsedPreview);

      final res = await request.send();
      final response = await http.Response.fromStream(res);
      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        _showSnackBar('Exam added successfully');
        Navigator.pop(context, true);
      } else {
        _errorMessage = data['message'];
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickExamFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'jpg', 'png'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedExamFile = File(result.files.single.path!);
      });

      debugPrint('Selected exam file: ${selectedExamFile!.path}');
    }
  }

  Widget _buildExamFilePreview(File file) {
    final ext = file.path.split('.').last.toLowerCase();

    if (['jpg', 'jpeg', 'png'].contains(ext)) {
      return Image.file(file, fit: BoxFit.cover);
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          ext == 'pdf' ? Icons.picture_as_pdf : Icons.insert_drive_file,
          size: 48,
          color: Colors.blue,
        ),
        const SizedBox(height: 8),
        Text(
          file.path.split('/').last,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
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
          'Add Exam',
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
              const Text('Exam Name'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _examNameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter exam name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              DottedBorder(
                color: Colors.blue.shade300,
                strokeWidth: 1,
                dashPattern: const [6, 3],
                borderType: BorderType.RRect,
                radius: const Radius.circular(12),
                child: Container(
                  width: double.infinity,
                  height: 180,
                  padding: const EdgeInsets.all(24),
                  child: GestureDetector(
                    onTap: _pickExamFile,
                    child:
                        selectedExamFile == null
                            ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.cloud_upload_outlined,
                                  size: 40,
                                  color: Colors.blue,
                                ),
                                SizedBox(height: 12),
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(text: 'Upload exam file or '),
                                      TextSpan(
                                        text: 'browse',
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'PDF, DOCX, JPG or PNG (Max 10 MB)',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            )
                            : _buildExamFilePreview(selectedExamFile!),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 8, right: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Powered by ',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Image.asset('assets/google_vision_icon.png', height: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Google Vision AI',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),

              if (selectedExamFile != null) ...[
                const SizedBox(height: 8),
                const Text(
                  '*Hold to preview, single tap to choose file',
                  style: TextStyle(
                    color: Color.fromARGB(255, 252, 89, 75),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Selected file: ${selectedExamFile!.path.split('/').last}',
                  style: const TextStyle(color: Colors.green),
                ),
              ],

              if (_previewReady && parsedPreview != null) ...[
                const SizedBox(height: 16),
                const Text(
                  'Scanned Questions Preview',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 220,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          parsedPreview!.map((q) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Question with marks
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Q${q['question_no']} (${q['marks']} marks): ${q['question_text']}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  // Schemes with marks
                                  ...q['schemes'].asMap().entries.map<Widget>((
                                    entry,
                                  ) {
                                    int idx = entry.key;
                                    String schemeText =
                                        entry.value['scheme_text'];
                                    int schemeMarks = entry.value['marks'];
                                    return Container(
                                      margin: const EdgeInsets.only(
                                        left: 16,
                                        bottom: 4,
                                      ),
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Scheme ${idx + 1} (${schemeMarks} marks): $schemeText',
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontSize: 14,
                                        ),
                                      ),
                                    );
                                  }).toList(),

                                  const SizedBox(
                                    height: 12,
                                  ), // space after each question
                                ],
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ),
              ],

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
                  onPressed:
                      _isLoading
                          ? null
                          : () async {
                            if (selectedExamFile == null) {
                              _addExam(); // old behavior
                            } else if (!_previewReady) {
                              await _previewExamFile(); // FIRST confirm
                            } else {
                              await _addExamWithParsedData(); // SECOND confirm
                            }
                          },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2BA8FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _isLoading
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
