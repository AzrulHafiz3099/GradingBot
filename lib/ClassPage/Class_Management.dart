import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'Add_Class.dart';
import 'Update_Class.dart';
import '/utils/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/utils/env.dart'; // contains Env.baseUrl

class ClassManagementPage extends StatefulWidget {
  const ClassManagementPage({super.key});

  @override
  State<ClassManagementPage> createState() => _ClassManagementPageState();
}

class _ClassManagementPageState extends State<ClassManagementPage> {
  final secureStorage = const FlutterSecureStorage();
  List<Map<String, dynamic>> classes = [];
  bool isLoading = true;
  String? errorMessage;
  String? lecturerId;

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
    if (id != null) {
      fetchClasses(id);
    } else {
      setState(() {
        isLoading = false;
        errorMessage = 'Lecturer ID not found in secure storage.';
      });
    }
  }

  Future<void> fetchClasses(String lecturerId) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse('${Env.classApi}/classes?lecturer_id=$lecturerId'),
      );

      print(
        '[DEBUG] API URL: ${Env.classApi}/classes?lecturer_id=$lecturerId',
      ); // <-- added
      print('[DEBUG] Response Status: ${response.statusCode}'); // <-- added
      print('[DEBUG] Response Body: ${response.body}'); // <-- added

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          print('[DEBUG] Classes fetched: ${data['data']}'); // <-- added

          setState(() {
            classes = List<Map<String, dynamic>>.from(data['data']);
          });
        } else {
          print('[DEBUG] API Error Message: ${data['message']}'); // <-- added
          setState(() {
            errorMessage = data['message'] ?? 'Failed to fetch classes';
          });
        }
      } else {
        print('[DEBUG] Server Error Code: ${response.statusCode}'); // <-- added
        setState(() {
          errorMessage = 'Server Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      print('[DEBUG] Exception: $e'); // <-- added
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
          'Class Management',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.secondaryColor,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // Table Header
            const Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Text(
                    'Class Name',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Class Code',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Session / Year',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(),

            // Table Content
            Expanded(
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : errorMessage != null
                      ? Center(child: Text(errorMessage!))
                      : ListView.builder(
                        itemCount: classes.length,
                        itemBuilder: (context, index) {
                          final classItem = classes[index];
                          return InkWell(
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => UpdateClassPage(
                                        classId: classItem['class_id'] ?? '',
                                        className:
                                            classItem['class_name'] ?? '',
                                        classCode:
                                            classItem['class_code'] ?? '',
                                        session: classItem['session'] ?? '',
                                        year: classItem['year'] ?? '',
                                      ),
                                ),
                              );

                              // If update or delete was successful, refresh the classes list
                              if (result == true && lecturerId != null) {
                                await fetchClasses(lecturerId!);
                              }
                            },

                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: Text(
                                        classItem['class_name'] ?? '',
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        classItem['class_code'] ?? '',
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        "${classItem['session']} / ${classItem['year']}",
                                      ),
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

            // Add Class Button
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddClassPage(),
                    ),
                  );

                  if (result == true && lecturerId != null) {
                    fetchClasses(
                      lecturerId!,
                    ); // <-- refresh class list if AddClassPage returns true
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Add Class',
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
