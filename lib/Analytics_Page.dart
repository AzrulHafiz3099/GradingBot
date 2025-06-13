import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '/widget/class_picker.dart';
import '/widget/exam_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/utils/env.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> with TickerProviderStateMixin {

  final secureStorage = const FlutterSecureStorage();

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


  @override
void initState() {
  super.initState();
  _loadLecturerId();

  _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  );

  _animation = CurvedAnimation(
    parent: _animationController,
    curve: Curves.easeOut,
  );
}

  Future<void> _loadLecturerId() async {
    final id = await secureStorage.read(key: 'lecturer_id');
    setState(() => lecturerId = id);
  }

  List<Map<String, dynamic>> scoreDist = [];
  double totalMarks = 0;

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
      final d = jsonDecode(resp.body)['data'];
      print('Parsed data: $d');

      setState(() {
        totalMarks = (d['total_marks'] as num).toDouble(); // ✅ Safe cast
        scoreDist = List<Map<String, dynamic>>.from(d['distribution']);
      });
      _animationController.reset();
      _animationController.forward();


      print('Total Marks: $totalMarks');
      print('Score Distribution: $scoreDist');
    } else {
      print('Failed to fetch score distribution.');
    }
  }

  Future<void> fetchExamSummary() async {
    if (selectedClassId.isEmpty || selectedExamId.isEmpty) return;

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

      // Generate PDF
      final pdf = pw.Document();

      final imageLogo = pw.MemoryImage(
        (await rootBundle.load('assets/logo.png')).buffer.asUint8List(),
      );

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text('Exam Summary', style: pw.TextStyle(fontSize: 20)),
                    pw.Spacer(),
                    pw.Image(
                      imageLogo,
                      height: 60, // Adjust height to match text height visually
                      width: 60,
                    ),
                  ],
                ),
                pw.Divider(
                  thickness: 1,
                ), // You can increase thickness if needed
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
                pw.SizedBox(height: 4), // optional spacing

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

                // Completion Summary
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

                // Score Distribution
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
                        'Student Name',
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
                ...students.map((student) {
                  return pw.Row(
                    children: [
                      pw.Expanded(child: pw.Text(student['Student_Name'])),
                      pw.Text('${student['Score']}'),
                    ],
                  );
                }).toList(),
              ],
            );
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
    }
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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Completion analytics data: $data');
        final analyticsData = data['data'] ?? {};
        final taken = analyticsData['students_completed'] ?? 0;
        final total = analyticsData['total_students'] ?? 0;
        final percent =
            (analyticsData['completion_percentage'] ?? 0.0).toDouble();

        setState(() {
          studentsTaken = taken;
          totalStudents = total;
          completionPercentage = percent;
        });

        print("completionPercentage: $completionPercentage");
      } else {
        throw Exception('Failed to fetch analytics');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error loading completion data')),
      );
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
          selectedExamName = 'Choose Exam'; // Reset exam
          selectedExamId = '';
          // Reset analytics
          completionPercentage = 0.0;
          studentsTaken = 0;
          totalStudents = 0;
          scoreDist = [];
          totalMarks = 0.0;
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
        // _buildScoreChart(totalMarks, scoreDist);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalScore = data.reduce((a, b) => a + b);
    final double percentage = totalScore / total;
    // final double completionPercentage = 0.68;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header with pickers
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 55, 20, 20),
            color: Colors.blue,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Analytics Page',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select Class & Exam',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
                const SizedBox(height: 12),
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
            child: Container(
              color: Colors.white,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          CircularPercentIndicator(
                            radius: 30.0,
                            lineWidth: 6.0,
                            percent: completionPercentage.clamp(0.0, 1.0),
                            center: Text(
                              isLoading
                                  ? "..."
                                  : "${(completionPercentage * 100).toStringAsFixed(0)}%",
                            ),
                            progressColor: Colors.blue,
                            backgroundColor: Colors.white,
                            circularStrokeCap: CircularStrokeCap.round,
                            animation: true, // 🔥 Enables animation
                            animationDuration: 1000, // in milliseconds
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Completion',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text('$selectedExamName | $selectedClassName'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      selectedExamName.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildScoreChart(totalMarks, scoreDist),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed:
                            (isLoading || selectedExamId.isEmpty)
                                ? null
                                : fetchExamSummary,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child:
                            isLoading
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : const Text(
                                  'Download Exam Summary',
                                  style: TextStyle(color: Colors.white),
                                ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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

    final paint = Paint()
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
