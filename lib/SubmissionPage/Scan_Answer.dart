import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '/utils/colors.dart';
import 'Student_Result.dart';
import '/utils/env.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class ScanAnswerPage extends StatefulWidget {
  const ScanAnswerPage({super.key});

  @override
  State<ScanAnswerPage> createState() => _ScanAnswerPageState();
}

class _ScanAnswerPageState extends State<ScanAnswerPage> {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  List<dynamic> questionsData = [];
  int currentQuestionIndex = 0;
  bool loading = true;
  Map<int, List<String>> selectedSchemeIds = {};

  String? examId;
  String? classId;
  String? studentId;

  @override
  void initState() {
    super.initState();
    loadInitialData();
  }

  File? selectedFile;

  Widget _buildFilePreview(File file) {
    final extension = file.path.split('.').last.toLowerCase();

    if (['jpg', 'jpeg', 'png', 'gif'].contains(extension)) {
      // Show image preview
      return Image.file(file, fit: BoxFit.cover, width: 300, height: 150);
    } else if (extension == 'pdf') {
      // Show PDF icon or thumbnail placeholder
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.picture_as_pdf, size: 80, color: Colors.redAccent),
          const SizedBox(height: 12),
          Text(
            file.path.split('/').last,
            style: const TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    } else {
      // Generic file icon for other file types
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.insert_drive_file, size: 80, color: Colors.grey),
          const SizedBox(height: 12),
          Text(
            file.path.split('/').last,
            style: const TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    }
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Capture from Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.folder),
                title: const Text('Browse from Files'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromFile();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        selectedFile = File(pickedFile.path);
      });
      debugPrint('Picked from camera: ${pickedFile.path}');
    }
  }

  Future<void> _pickFromFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
      });
      debugPrint('Picked from file: ${result.files.single.path!}');
    }
  }

  Future<void> loadInitialData() async {
    examId = await secureStorage.read(key: 'exam_id');
    classId = await secureStorage.read(key: 'class_id');
    studentId = await secureStorage.read(key: 'student_id');

    if (examId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exam ID not found in storage')),
      );
      setState(() => loading = false);
      return;
    }

    await fetchQuestionsSchemes();
  }

  Future<void> fetchQuestionsSchemes() async {
    try {
      final response = await http.get(
        Uri.parse('${Env.baseUrl}/api_scan/questions_schemes?exam_id=$examId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            questionsData = data['data'];
            loading = false;
          });
        } else {
          throw Exception('Failed to fetch questions');
        }
      } else {
        throw Exception('Failed to fetch questions');
      }
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching questions: $e')));
    }
  }

  void toggleSchemeSelection(String schemeId) {
    final selected = selectedSchemeIds[currentQuestionIndex] ?? [];
    setState(() {
      if (selected.contains(schemeId)) {
        selected.remove(schemeId);
      } else {
        selected.add(schemeId);
      }
      selectedSchemeIds[currentQuestionIndex] = selected;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (questionsData.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.secondaryColor),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Scan Answer',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.secondaryColor,
            ),
          ),
        ),
        body: const Center(child: Text('No questions found for this exam.')),
      );
    }

    final currentQuestion = questionsData[currentQuestionIndex];
    final schemes = currentQuestion['schemes'] ?? [];
    final selectedSchemes = selectedSchemeIds[currentQuestionIndex] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.secondaryColor),
          onPressed: () {
            if (currentQuestionIndex == 0) {
              Navigator.pop(context);
            } else {
              setState(() {
                currentQuestionIndex--;
              });
            }
          },
        ),
        title: const Text(
          'Scan Answer',
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
            const SizedBox(height: 16),
            Text(
              'Question ${currentQuestionIndex + 1} of ${questionsData.length}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              currentQuestion['question_text'] ?? '',
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 16),
            const Text(
              'Total Schemes',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: TextEditingController(
                text: schemes.length.toString(),
              ),
              readOnly: true,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),

            const SizedBox(height: 16),

            ...List.generate(schemes.length, (index) {
              final scheme = schemes[index];
              final schemeId = scheme['scheme_id'] ?? scheme['Scheme_ID'];
              final schemeText = scheme['scheme_text'] ?? scheme['Scheme_Text'];
              final marks = scheme['marks'] ?? scheme['Marks'];
              final isSelected = selectedSchemes.contains(schemeId);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Scheme ${index + 1}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: TextEditingController(
                            text: '$schemeText (Marks: $marks)',
                          ),
                          readOnly: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Checkbox(
                        value: isSelected,
                        onChanged: (value) {
                          toggleSchemeSelection(schemeId);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }),

            DottedBorder(
              color: Colors.blue.shade300,
              strokeWidth: 1,
              dashPattern: [6, 3],
              borderType: BorderType.RRect,
              radius: const Radius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                height: 180,
                child:
                    selectedFile == null
                        ? GestureDetector(
                          onTap: _showPickerOptions,
                          child: Column(
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
                                    TextSpan(text: 'Capture your file or '),
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
                                'Max 10 MB files are allowed',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        )
                        : GestureDetector(
                          onTap: _showPickerOptions, // Tap to redo/pick file
                          onLongPress: () {
                            // Show fullscreen preview on hold
                            final extension =
                                selectedFile!.path
                                    .split('.')
                                    .last
                                    .toLowerCase();
                            if ([
                              'jpg',
                              'jpeg',
                              'png',
                              'gif',
                            ].contains(extension)) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => FullscreenImagePreview(
                                        imageFile: selectedFile!,
                                      ),
                                ),
                              );
                            } else {
                              // For PDFs or other files, you can add other preview logic if needed
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Preview not available for this file type.',
                                  ),
                                ),
                              );
                            }
                          },
                          child: _buildFilePreview(selectedFile!),
                        ),
              ),
            ),

            if (selectedFile != null) ...[
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  '*Hold to preview, single tap to choose file',
                  style: const TextStyle(
                    color: Color.fromARGB(255, 252, 89, 75),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  'Selected file: ${selectedFile!.path.split('/').last}',
                  style: const TextStyle(color: Colors.green),
                ),
              ),
            ],

            const SizedBox(height: 24),
            const Text(
              'Total Marks Received',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 4),
            const TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter marks',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (currentQuestionIndex < questionsData.length - 1) {
                      currentQuestionIndex++;
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StudentResultPage(),
                        ),
                      );
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  currentQuestionIndex == questionsData.length - 1
                      ? 'Confirm'
                      : 'Next',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FullscreenImagePreview extends StatelessWidget {
  final File imageFile;
  const FullscreenImagePreview({required this.imageFile, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, elevation: 0),
      body: Center(
        child: InteractiveViewer(
          // Allows zoom/pan
          child: Image.file(imageFile),
        ),
      ),
    );
  }
}
