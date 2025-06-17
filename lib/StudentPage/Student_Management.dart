import 'package:flutter/material.dart';
import '/utils/colors.dart';
import 'Update_Student.dart';
import 'Add_Student.dart';
import '/widget/class_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '/utils/env.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StudentManagementPage extends StatefulWidget {
  const StudentManagementPage({super.key});

  @override
  _StudentManagementPageState createState() => _StudentManagementPageState();
}

class _StudentManagementPageState extends State<StudentManagementPage> {
  final secureStorage = const FlutterSecureStorage();

  String? lecturerId;
  String selectedClassName = 'Choose Class';
  String? selectedClassId;

  List<Map<String, dynamic>> students = [];
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadLecturerId();
  }

  Future<void> _loadLecturerId() async {
    String? id = await secureStorage.read(key: 'lecturer_id');
    setState(() {
      lecturerId = id;
    });
    print('Lecturer ID from secure storage: $lecturerId');
    if (id == null) {
      setState(() {
        isLoading = false;
        errorMessage = 'Lecturer ID not found in secure storage.';
      });
    }
  }

  Future<void> fetchStudents(String classId) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse('${Env.baseUrl}/api_student/students?class_id=$classId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            students = List<Map<String, dynamic>>.from(data['data']);
          });
        } else {
          setState(() {
            errorMessage = data['message'] ?? 'Failed to fetch students';
          });
        }
      } else {
        setState(() {
          errorMessage = 'Server Error: ${response.statusCode}';
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
          fetchStudents(classId);
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
                      selectedClassName,
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
                  flex: 5,
                  child: Text(
                    'Matrix No.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 5,
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
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : errorMessage != null
                      ? Center(child: Text(errorMessage!))
                      : selectedClassId == null
                      ? const Center(child: Text("Select a class."))
                      : students.isEmpty
                      ? const Center(child: Text("No students found."))
                      : ListView.builder(
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          final student = students[index];
                          return InkWell(
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => UpdateStudentPage(
                                        studentId: student['student_id'],
                                        selectedClass: selectedClassName,
                                        selectedClassId: selectedClassId!,
                                        currentMatrix: student['matrix'],
                                        currentPhone: student['phone'],
                                      ),
                                ),
                              );
                              if (result == true && selectedClassId != null) {
                                fetchStudents(selectedClassId!);
                              }
                            },
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: Text(student['matrix'] ?? ''),
                                    ),
                                    Expanded(
                                      flex: 5,
                                      child: Text(student['phone'] ?? ''),
                                    ),
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
                onPressed:
                    (selectedClassId == null || selectedClassId!.isEmpty)
                        ? null // Disable button if no class selected
                        : () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => AddStudentPage(
                                    classId: selectedClassId!,
                                    className: selectedClassName,
                                  ),
                            ),
                          );
                          if (result == true && selectedClassId != null) {
                            fetchStudents(
                              selectedClassId!,
                            ); // Refresh list after adding student
                          }
                        },

                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      (selectedClassId == null || selectedClassId!.isEmpty)
                          ? Colors
                              .grey // disabled color
                          : const Color(0xFF2BA8FF),
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
