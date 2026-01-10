import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'dart:math';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '/widget/class_picker.dart';
import '/widget/exam_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/utils/env.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import '/utils/analytics_helper.dart';
import '/utils/export_helper.dart';
import '/utils/analytics_widgets.dart';
import '/utils/cache_service.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage>
    with TickerProviderStateMixin {
  final secureStorage = const FlutterSecureStorage();
  late CacheService cacheService;

  String selectedClassName = 'Choose Class';
  String selectedClassId = '';
  String selectedExamName = 'Choose Exam';
  String selectedExamId = '';
  String? lecturerId;
  bool isLoading = false;
  int studentsTaken = 0;
  int totalStudents = 0;
  double completionPercentage = 0.0;

  final int total = 10;
  final List<int> data = [4, 3, 2, 1];

  late AnimationController _animationController;
  late Animation<double> _animation;
  late Timer _autoRefreshTimer;

  // New state variables
  List<Map<String, dynamic>> allStudents = [];
  List<Map<String, dynamic>> filteredStudents = [];
  String searchQuery = '';
  bool showHistogram = false;
  String sortBy = 'score_desc'; // score_asc, score_desc, name_asc
  
  // Statistics
  Map<String, dynamic> statistics = {};
  Map<String, int> gradeDistribution = {};
  List<Map<String, dynamic>> scoreDist = [];
  double totalMarks = 0.0;

  @override
  void initState() {
    super.initState();
    cacheService = CacheService();
    _loadLecturerId();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    // Auto-refresh every 5 minutes
    _autoRefreshTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (selectedExamId.isNotEmpty) {
        fetchCompletionAnalytics();
        fetchScoreDistribution();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _autoRefreshTimer.cancel();
    super.dispose();
  }

  Future<void> _loadLecturerId() async {
    final id = await secureStorage.read(key: 'lecturer_id');
    setState(() => lecturerId = id);
  }

  Future<void> fetchScoreDistribution() async {
    print('Fetching score distribution...');
    print('Selected Class ID: $selectedClassId');
    print('Selected Exam ID: $selectedExamId');

    final resp = await http.get(
      Uri.parse(
        '${Env.baseUrl}/api_analytics/score_distribution'
        '?class_id=$selectedClassId&exam_id=$selectedExamId',
      ),
    );

    print('Response status: ${resp.statusCode}');
    print('Response body: ${resp.body}');

    if (resp.statusCode == 200) {
      try {
        final d = jsonDecode(resp.body)['data'];
        print('Parsed data: $d');

        setState(() {
          final marksValue = d['total_marks'];
          totalMarks = marksValue is String ? double.tryParse(marksValue) ?? 0.0 : (marksValue as num).toDouble();
          scoreDist = List<Map<String, dynamic>>.from(d['distribution']);
          _updateStatistics();
        });
        _animationController.reset();
        _animationController.forward();

        print('Total Marks: $totalMarks');
        print('Score Distribution: $scoreDist');
        print('✅ Score distribution loaded successfully');

        // Cache the data - wrap in try-catch
        try {
          await cacheService.cacheScoreDistribution(selectedClassId, selectedExamId, scoreDist);
          print('✅ Score distribution cached successfully');
        } catch (cacheError) {
          print('⚠️ Cache error (not critical): $cacheError');
        }
      } catch (parseError) {
        print('❌ Error parsing score distribution: $parseError');
        _showErrorSnackBar('Error parsing score distribution data');
      }
    } else {
      print('Failed to fetch score distribution.');
      _showErrorSnackBar('Failed to fetch score distribution');
    }
  }

  void _updateStatistics() {
    if (scoreDist.isNotEmpty && totalMarks > 0) {
      statistics = AnalyticsHelper.getStatistics(scoreDist, totalMarks);
      gradeDistribution = AnalyticsHelper.getGradeDistribution(scoreDist, totalMarks);
    }
  }

  void _filterStudents() {
    filteredStudents = allStudents.where((student) {
      final matrixNum = student['Matrix_Number'].toString().toLowerCase();
      final matchesSearch = matrixNum.contains(searchQuery.toLowerCase());
      return matchesSearch;
    }).toList();

    // Sort
    switch (sortBy) {
      case 'score_asc':
        filteredStudents.sort((a, b) {
          final aScorePart = a['Score'].toString().split('/')[0];
          final bScorePart = b['Score'].toString().split('/')[0];
          final aScore = double.tryParse(aScorePart.trim()) ?? 0.0;
          final bScore = double.tryParse(bScorePart.trim()) ?? 0.0;
          return aScore.compareTo(bScore);
        });
        break;
      case 'score_desc':
        filteredStudents.sort((a, b) {
          final aScorePart = a['Score'].toString().split('/')[0];
          final bScorePart = b['Score'].toString().split('/')[0];
          final aScore = double.tryParse(aScorePart.trim()) ?? 0.0;
          final bScore = double.tryParse(bScorePart.trim()) ?? 0.0;
          return bScore.compareTo(aScore);
        });
        break;
      case 'name_asc':
        filteredStudents.sort((a, b) => a['Matrix_Number'].compareTo(b['Matrix_Number']));
        break;
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Retry',
          onPressed: () {
            if (selectedExamId.isNotEmpty) {
              fetchCompletionAnalytics();
              fetchScoreDistribution();
            }
          },
        ),
      ),
    );
  }

  Future<void> _loadStudentData() async {
    if (selectedClassId.isEmpty || selectedExamId.isEmpty) return;

    try {
      final resp = await http.get(
        Uri.parse(
          '${Env.baseUrl}/api_analytics/exam_summary?class_id=$selectedClassId&exam_id=$selectedExamId',
        ),
      );

      if (resp.statusCode == 200) {
        final summary = jsonDecode(resp.body);
        final students = List<Map<String, dynamic>>.from(summary['students']);

        print('DEBUG: Students data: $students');
        if (students.isNotEmpty) {
          print('DEBUG: First student: ${students[0]}');
          print('DEBUG: Available keys: ${students[0].keys.toList()}');
        }

        // Update state with students
        setState(() {
          allStudents = students;
          _filterStudents();
        });
      }
    } catch (e) {
      print('Error loading student data: $e');
    }
  }

  Future<void> fetchExamSummary() async {
    if (selectedClassId.isEmpty || selectedExamId.isEmpty) return;

    setState(() => isLoading = true);

    try {
      final resp = await http.get(
        Uri.parse(
          '${Env.baseUrl}/api_analytics/exam_summary?class_id=$selectedClassId&exam_id=$selectedExamId',
        ),
      );

      if (resp.statusCode == 200) {
        final summary = jsonDecode(resp.body);
        final className = summary['class_name'];
        final examName = summary['exam_name'];
        final students = List<Map<String, dynamic>>.from(summary['students']);

        print('DEBUG: Students data: $students');
        if (students.isNotEmpty) {
          print('DEBUG: First student: ${students[0]}');
          print('DEBUG: Available keys: ${students[0].keys.toList()}');
          students[0].forEach((key, value) {
            print('DEBUG: $key = $value (type: ${value.runtimeType})');
          });
        }

        // Update state with students
        setState(() {
          allStudents = students;
          _filterStudents();
        });

        // Generate PDF
        final pdf = pw.Document();

        final imageLogo = pw.MemoryImage(
          (await rootBundle.load('assets/logo.png')).buffer.asUint8List(),
        );

        pdf.addPage(
          pw.MultiPage(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return [
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text('Exam Summary', style: pw.TextStyle(fontSize: 20)),
                    pw.Spacer(),
                    pw.Image(imageLogo, height: 60, width: 60),
                  ],
                ),
                pw.Divider(thickness: 1),
                pw.SizedBox(height: 16),
                pw.RichText(
                  text: pw.TextSpan(
                    children: [
                      pw.TextSpan(
                        text: 'Class Name: ',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.TextSpan(
                        text: className,
                        style: pw.TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                pw.RichText(
                  text: pw.TextSpan(
                    children: [
                      pw.TextSpan(
                        text: 'Class Code: ',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.TextSpan(
                        text: selectedClassName,
                        style: pw.TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.RichText(
                  text: pw.TextSpan(
                    children: [
                      pw.TextSpan(
                        text: 'Exam Name: ',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.TextSpan(
                        text: examName,
                        style: pw.TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 12),

                pw.Text(
                  'Completion Summary:',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'Completed: $studentsTaken / $totalStudents students '
                  '(${(completionPercentage * 100).toStringAsFixed(0)}%)',
                ),
                pw.SizedBox(height: 12),

                pw.Text(
                  'Score Distribution:',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                ...scoreDist.map((entry) {
                  return pw.Text(
                    '${entry['score']} = ${entry['count']} student(s)',
                  );
                }),

                pw.SizedBox(height: 20),
                pw.Text(
                  'Student Scores:',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        'Matrix Number',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    pw.Text(
                      'Score',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                pw.Divider(),

                // List of student rows
                ...students.map((student) {
                  return pw.Row(
                    children: [
                      pw.Expanded(child: pw.Text(student['Matrix_Number'])),
                      pw.Text('${student['Score']}'),
                    ],
                  );
                }).toList(),
              ];
            },
          ),
        );

        // Let user download or share
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdf.save(),
          name: 'Exam_Summary_$examName.pdf',
        );
      } else {
        print('Failed to fetch exam summary.');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to fetch exam summary')),
          );
        }
      }
    } catch (e) {
      print('Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> fetchCompletionAnalytics() async {
    if (selectedClassId.isEmpty || selectedExamId.isEmpty) return;

    setState(() => isLoading = true);

    try {
      final response = await http.get(
        Uri.parse(
          '${Env.baseUrl}/api_analytics/completion?class_id=$selectedClassId&exam_id=$selectedExamId',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Completion analytics data: $data');
        final analyticsData = data['data'] ?? {};
        final taken = analyticsData['students_completed'] ?? 0;
        final total = analyticsData['total_students'] ?? 0;
        final percent = (analyticsData['completion_percentage'] ?? 0.0).toDouble();

        setState(() {
          studentsTaken = taken;
          totalStudents = total;
          completionPercentage = percent;
        });

        print("✅ Completion Loaded - Students: $studentsTaken / $totalStudents (${(percent * 100).toStringAsFixed(2)}%)");

        // Cache it - wrap in try-catch to not break the whole function
        try {
          await cacheService.cacheCompletionAnalytics(
            selectedClassId,
            selectedExamId,
            analyticsData,
          );
          print('✅ Completion data cached successfully');
        } catch (cacheError) {
          print('⚠️ Cache error (not critical): $cacheError');
        }
      } else {
        print('❌ Failed to fetch analytics. Status: ${response.statusCode}');
        throw Exception('Failed to fetch analytics: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in fetchCompletionAnalytics: $e');
      if (mounted) {
        _showErrorSnackBar('Error loading completion data: $e');
      }
    } finally {
      setState(() => isLoading = false);
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
          selectedClassName = className;
          selectedClassId = classId;
          selectedExamName = 'Choose Exam';
          selectedExamId = '';
          completionPercentage = 0.0;
          studentsTaken = 0;
          totalStudents = 0;
          scoreDist = [];
          totalMarks = 0.0;
          statistics = {};
          gradeDistribution = {};
          allStudents = [];
          filteredStudents = [];
        });
      },
    );
  }

  void _showExamPicker() {
    if (selectedClassId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a class first')),
      );
      return;
    }

    showExamPicker(
      context: context,
      selectedExam: selectedExamName,
      classId: selectedClassId,
      onSelected: (examId, examName) {
        setState(() {
          selectedExamName = examName;
          selectedExamId = examId;
        });
        fetchCompletionAnalytics();
        fetchScoreDistribution();
        _loadStudentData(); // Load student data with scores
      },
    );
  }

  void _onRefresh() {
    if (selectedExamId.isNotEmpty) {
      fetchCompletionAnalytics();
      fetchScoreDistribution();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () async => _onRefresh(),
        child: Column(
          children: [
            // Header with pickers
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 55, 20, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade600, Colors.blue.shade800],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Analytics Dashboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Track exam performance & analytics',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildStyledPickerBox(
                        label: selectedClassName,
                        onTap: _showClassPicker,
                      ),
                      const SizedBox(width: 12),
                      _buildStyledPickerBox(
                        label: selectedExamName,
                        onTap: _showExamPicker,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Analytics content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // Completion Card
                    if (selectedExamId.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade400,
                              Colors.blue.shade600,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircularPercentIndicator(
                              radius: 45.0,
                              lineWidth: 8.0,
                              percent: completionPercentage.clamp(0.0, 1.0),
                              center: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    isLoading
                                        ? "..."
                                        : "${(completionPercentage * 100).toStringAsFixed(0)}%",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text(
                                    'Complete',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                              progressColor: Colors.white,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              circularStrokeCap: CircularStrokeCap.round,
                              animation: true,
                              animationDuration: 1000,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Exam Completion',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$studentsTaken / $totalStudents students',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    selectedExamName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Statistics Cards
                      if (statistics.isNotEmpty) ...[
                        Text(
                          'Score Statistics',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            StatisticsCard(
                              label: 'Average Score',
                              value: (statistics['average'] ?? 0).toStringAsFixed(1),
                              icon: Icons.trending_up,
                              color: Colors.green,
                            ),
                            StatisticsCard(
                              label: 'Median Score',
                              value: (statistics['median'] ?? 0).toStringAsFixed(1),
                              icon: Icons.equalizer,
                              color: Colors.orange,
                            ),
                            StatisticsCard(
                              label: 'Std Deviation',
                              value: (statistics['stdDev'] ?? 0).toStringAsFixed(2),
                              icon: Icons.show_chart,
                              color: Colors.purple,
                            ),
                            StatisticsCard(
                              label: 'Max Score',
                              value: totalMarks.toStringAsFixed(1),
                              icon: Icons.star,
                              color: Colors.amber,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Score Chart Toggle
                      Text(
                        'Score Distribution',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: SegmentedButton<bool>(
                          segments: const [
                            ButtonSegment<bool>(
                              value: false,
                              label: Text('Pie Chart'),
                              icon: Icon(Icons.pie_chart),
                            ),
                            ButtonSegment<bool>(
                              value: true,
                              label: Text('Histogram'),
                              icon: Icon(Icons.bar_chart),
                            ),
                          ],
                          selected: <bool>{showHistogram},
                          onSelectionChanged: (Set<bool> newSelection) {
                            setState(() {
                              showHistogram = newSelection.first;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (showHistogram && scoreDist.isNotEmpty)
                        HistogramChart(
                          distribution: scoreDist,
                          maxScore: totalMarks,
                        )
                      else if (scoreDist.isNotEmpty)
                        _buildScoreChart(totalMarks, scoreDist)
                      else
                        const Padding(
                          padding: EdgeInsets.all(32),
                          child: Text('No distribution data available'),
                        ),

                      const SizedBox(height: 24),

                      // Student List Section
                      if (allStudents.isNotEmpty) ...[
                        const Divider(),
                        const SizedBox(height: 16),
                        Text(
                          'Student Results',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Search Bar
                        StudentSearchBar(
                          onSearchChanged: (query) {
                            setState(() {
                              searchQuery = query;
                              _filterStudents();
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        // Sort Dropdown
                        Row(
                          children: [
                            const Text(
                              'Sort by:',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DropdownButton<String>(
                                value: sortBy,
                                isExpanded: true,
                                items: [
                                  'score_desc',
                                  'score_asc',
                                  'name_asc',
                                ]
                                    .map((e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e == 'score_desc'
                                              ? 'Highest Score'
                                              : e == 'score_asc'
                                                  ? 'Lowest Score'
                                                  : 'Matrix Number'),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    sortBy = value ?? 'score_desc';
                                    _filterStudents();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Student List
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredStudents.length,
                          itemBuilder: (context, index) {
                            final student = filteredStudents[index];
                            // Score is in format "1.0/2.0", extract just the score part
                            final scoreStr = student['Score'].toString();
                            final scoreParts = scoreStr.contains('/') 
                              ? scoreStr.split('/')[0] 
                              : scoreStr;
                            final score = double.tryParse(scoreParts.trim()) ?? 0.0;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                title: Text(
                                  student['Matrix_Number'] ?? 'Unknown',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                trailing: Text(
                                  student['Score'].toString(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade600,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        if (filteredStudents.isEmpty && searchQuery.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(32),
                            child: Text(
                              'No students found matching "$searchQuery"',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ),
                      ],

                      const SizedBox(height: 24),

                      // Export Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: fetchExamSummary,
                              icon: const Icon(Icons.download),
                              label: const Text('Export Data'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: (isLoading || selectedExamId.isEmpty) ? null : _onRefresh,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Refresh'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                    ] else
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: [
                            Icon(Icons.analytics, size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text(
                              'Select a class and exam to view analytics',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A':
        return Colors.green;
      case 'B':
        return Colors.blue;
      case 'C':
        return Colors.orange;
      case 'D':
        return Colors.red.shade400;
      case 'F':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildStyledPickerBox({
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreChart(double totalMarks, List<Map<String, dynamic>> dist) {
    final totalStudents = dist.fold<int>(
      0,
      (sum, e) => sum + int.parse(e['count'].toString()),
    );
    final colors = List.generate(
      dist.length,
      (i) => Colors.primaries[i % Colors.primaries.length],
    );

    return SizedBox(
      height: 250,
      width: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularPercentIndicator(
            radius: 110,
            lineWidth: 34,
            percent: 1.0,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "$totalMarks",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text('Max Score'),
              ],
            ),
            progressColor: Colors.transparent,
            backgroundColor: Colors.grey.shade200,
            animation: true,
            animationDuration: 1000,
          ),
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CustomPaint(
                  painter: _MultiSegmentPainter(
                    dist,
                    totalStudents,
                    colors,
                    _animation.value,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MultiSegmentPainter extends CustomPainter {
  final List<Map<String, dynamic>> dist;
  final int total;
  final List<Color> colors;
  final double progress;

  _MultiSegmentPainter(this.dist, this.total, this.colors, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 18.0;
    final rect = Rect.fromCircle(
      center: center,
      radius: radius - strokeWidth / 2,
    );
    double startAngle = -pi / 2;

    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.butt;

    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < dist.length; i++) {
      final count = int.parse(dist[i]['count'].toString());
      final scoreLabel = dist[i]['score'].toString().split('/').first.trim();
      final sweepAngle = (count / total) * 2 * pi * progress;

      paint.color = colors[i];
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);

      // Label angle & offset
      final labelAngle = startAngle + sweepAngle / 2;
      final labelRadius = radius - strokeWidth * 2.0;
      final offset = Offset(
        center.dx + labelRadius * cos(labelAngle),
        center.dy + labelRadius * sin(labelAngle),
      );

      // Draw score text
      if (progress > 0.98) {
        textPainter.text = TextSpan(
          text: scoreLabel,
          style: const TextStyle(fontSize: 14, color: Colors.black),
        );
        textPainter.layout(minWidth: 0, maxWidth: 60);
        textPainter.paint(
          canvas,
          offset - Offset(textPainter.width / 2, textPainter.height / 2),
        );
      }

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
