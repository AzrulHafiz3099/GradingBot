import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'ResultPage/Result_Management.dart';
import 'ClassPage/Class_Management.dart';
import 'StudentPage/Student_Management.dart';
import 'ExamPage/Exam_Management.dart';
import '/utils/env.dart';
import 'ResultPage/Result_Details.dart'; // Update path if needed

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  String? lecturerId;
  bool isLoading = true;
  List<Map<String, dynamic>> recentResults = [];
  String? errorMessage;
  String? lecturerName;
  int? classCount;
  int? studentCount;
  int? examCount;
  int? resultCount;

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
    if (id != null) {
      await fetchSummaryData(id);
      await fetchRecentResults(id);
    } else {
      setState(() {
        isLoading = false;
        errorMessage = 'Lecturer ID not found';
      });
    }
  }

  Future<void> fetchSummaryData(String lecturerId) async {
    final url = '${Env.baseUrl}/api_homepage/summary?lecturer_id=$lecturerId';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            lecturerName = data['data']['lecturer_name'];
            classCount = data['data']['class_count'];
            studentCount = data['data']['student_count'];
            examCount = data['data']['exam_count'];
            resultCount = data['data']['result_count'];
          });
        } else {
          setState(() {
            errorMessage = data['message'];
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
    }
  }

  Future<void> fetchRecentResults(String lecturerId) async {
    final url =
        '${Env.baseUrl}/api_result/by_lecturer5?lecturer_id=$lecturerId';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            recentResults = List<Map<String, dynamic>>.from(data['data']);
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = data['message'];
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Server error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeaderSection(),
            const SizedBox(height: 20),
            _buildRecentResultsTitle(),
            const SizedBox(height: 10),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              )
            else if (recentResults.isNotEmpty)
              Column(
                children:
                    recentResults.asMap().entries.map((entry) {
                      final index = entry.key;
                      final result = entry.value;

                      return AnimatedResultCard(
                        index: index,
                        child: _buildResultCard(
                          result['result_id'].toString(),
                          result['student_id'].toString(),
                          result['student_name'] ?? '',
                          result['timestamp']?.split('T')[0] ?? '',
                          result['score']?.toString() ?? '0',
                          result['class_name'] ?? '',
                        ),
                      );
                    }).toList(),
              )
            else
              const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text("No recent results available."),
              ),
            const SizedBox(height: 10),
            _buildShowMoreButton(),
            const SizedBox(height: 90),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 52, 16, 16),
      decoration: const BoxDecoration(
        color: Color(0xFF2BA8FF),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hi, Welcome Back ${lecturerName ?? ''}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Smart Scanning. Instant Results.',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 25),
          LayoutBuilder(
            builder: (context, constraints) {
              return Transform.translate(
                offset: const Offset(0, -16),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.8,
                    children: [
                      _buildInfoCard(
                        Icons.tv,
                        'CLASS',
                        classCount?.toString() ?? '0',
                        Colors.blue,
                        const Color(0xFFE0F1FF),
                        Colors.blue,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ClassManagementPage(),
                            ),
                          );
                        },
                      ),
                      _buildInfoCard(
                        Icons.school_outlined,
                        'STUDENT',
                        studentCount?.toString() ?? '0',
                        Colors.pink,
                        const Color(0xFFFFE9EE),
                        Colors.pink,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StudentManagementPage(),
                            ),
                          );
                        },
                      ),
                      _buildInfoCard(
                        Icons.edit_document,
                        'EXAM',
                        examCount?.toString() ?? '0',
                        Colors.green,
                        const Color(0xFFE6FFF2),
                        Colors.green,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ExamManagementPage(),
                            ),
                          );
                        },
                      ),
                      _buildInfoCard(
                        Icons.assignment_turned_in,
                        'RESULT',
                        resultCount?.toString() ?? '0',
                        Colors.purple,
                        const Color(0xFFEDEBFF),
                        Colors.purple,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ResultManagementPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    IconData icon,
    String title,
    String value,
    Color iconBgColor,
    Color bgColor,
    Color valueColor,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: valueColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentResultsTitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Recent Result',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(
    String resultId,
    String studentId,
    String name,
    String date,
    String score,
    String className,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ResultDetailsPage(
                    studentId: studentId,
                    resultId: resultId,
                  ),
            ),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 242, 245, 252),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color.fromARGB(255, 206, 227, 245)),
            boxShadow: const [
              BoxShadow(
                color: Color.fromARGB(60, 0, 0, 0),
                blurRadius: 4,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.purple,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Submitted: $date",
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          "Score: $score",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        className,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShowMoreButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ResultManagementPage()),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        side: const BorderSide(color: Colors.blue),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
      ),
      child: const Text('Show more', style: TextStyle(color: Colors.blue)),
    );
  }
}

class AnimatedResultCard extends StatefulWidget {
  final int index;
  final Widget child;

  const AnimatedResultCard({
    super.key,
    required this.index,
    required this.child,
  });

  @override
  State<AnimatedResultCard> createState() => _AnimatedResultCardState();
}

class _AnimatedResultCardState extends State<AnimatedResultCard>
    with SingleTickerProviderStateMixin {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 200 * widget.index), () {
      if (mounted) {
        setState(() {
          _visible = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 3000),
      opacity: _visible ? 1.0 : 0.0,
      curve: Curves.easeOutBack,
      child: widget.child,
    );
  }
}
