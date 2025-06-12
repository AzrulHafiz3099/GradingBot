import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '/widget/class_picker.dart';
import '/widget/exam_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/utils/env.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
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

  @override
  void initState() {
    super.initState();
    _loadLecturerId();
  }

  Future<void> _loadLecturerId() async {
    final id = await secureStorage.read(key: 'lecturer_id');
    setState(() => lecturerId = id);
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
                    _buildScoreChart(total, data),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed:
                            isLoading
                                ? null
                                : () {
                                  // Use selectedClassId, selectedExamId here if needed
                                  print('Selected classId: $selectedClassId');
                                  print('Selected examId: $selectedExamId');
                                },
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

  Widget _buildScoreChart(int total, List<int> data) {
    final colors = [
      Colors.cyan,
      Colors.blueAccent,
      Colors.indigo,
      Colors.indigo[900]!,
    ];
    final totalScore = data.reduce((a, b) => a + b);

    return SizedBox(
      height: 250,
      width: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularPercentIndicator(
            radius: 110.0,
            lineWidth: 34.0,
            percent: totalScore / total,
            circularStrokeCap: CircularStrokeCap.round,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "$totalScore / $total",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text('Total Score', style: TextStyle(fontSize: 14)),
              ],
            ),
            progressColor: Colors.transparent,
            backgroundColor: Colors.grey.shade200,
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: _MultiSegmentPainter(data, total, colors),
            ),
          ),
        ],
      ),
    );
  }
}

class _MultiSegmentPainter extends CustomPainter {
  final List<int> scores;
  final int total;
  final List<Color> colors;

  _MultiSegmentPainter(this.scores, this.total, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 18.0;
    double startAngle = -90.0;

    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < scores.length; i++) {
      final sweepAngle = 360 * (scores[i] / total);
      final angleRad = radians(startAngle + sweepAngle / 2);

      paint.color = colors[i % colors.length];
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        radians(startAngle),
        radians(sweepAngle),
        false,
        paint,
      );

      final percent = (scores[i] / total) * 100;
      final label = '${percent.toStringAsFixed(0)}%';
      final labelRadius = radius - strokeWidth * 1.9;

      final offset = Offset(
        center.dx + labelRadius * cos(angleRad) - 12,
        center.dy + labelRadius * sin(angleRad) - 8,
      );

      textPainter.text = TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, offset);

      startAngle += sweepAngle;
    }
  }

  double radians(double degrees) => degrees * pi / 180;

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
