import 'package:flutter/material.dart';
import 'utils/colors.dart';
import 'ClassPage/Class_Management.dart';
import 'StudentPage/Student_Management.dart';
import 'ExamPage/Exam_Management.dart';
import 'ResultPage/Result_Management.dart';

class ManagePage extends StatelessWidget {
  const ManagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.06,
            vertical: screenHeight * 0.03,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Management page',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenHeight * 0.03),

              // Class
              AnimatedManageCard(
                index: 0,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ClassManagementPage()),
                    );
                  },
                  child: _buildManageCard(
                    title: 'Class',
                    subtitle: 'Manage your class',
                    imagePlaceholder: 'assets/class.png',
                    screenWidth: screenWidth,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),

              // Student
              AnimatedManageCard(
                index: 1,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => StudentManagementPage()),
                    );
                  },
                  child: _buildManageCard(
                    title: 'Student',
                    subtitle: 'Manage your class student',
                    imagePlaceholder: 'assets/student.png',
                    screenWidth: screenWidth,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),

              // Exam
              AnimatedManageCard(
                index: 2,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ExamManagementPage()),
                    );
                  },
                  child: _buildManageCard(
                    title: 'Exam',
                    subtitle: 'Manage your exam',
                    imagePlaceholder: 'assets/exam.png',
                    screenWidth: screenWidth,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),

              // Result
              AnimatedManageCard(
                index: 3,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ResultManagementPage()),
                    );
                  },
                  child: _buildManageCard(
                    title: 'Result',
                    subtitle: 'Manage students’ result',
                    imagePlaceholder: 'assets/result.png',
                    screenWidth: screenWidth,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManageCard({
    required String title,
    required String subtitle,
    required String imagePlaceholder,
    required double screenWidth,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Left Text Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          // Right Image Placeholder
          Container(
            width: screenWidth * 0.2,
            height: screenWidth * 0.2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[200],
            ),
            child: Center(
              child: Image.asset(imagePlaceholder, fit: BoxFit.contain),
            ),
          ),
        ],
      ),
    );
  }
}

// ADD THIS BELOW ManagePage OR IN A SEPARATE FILE
class AnimatedManageCard extends StatefulWidget {
  final Widget child;
  final int index;

  const AnimatedManageCard({required this.child, required this.index, super.key});

  @override
  State<AnimatedManageCard> createState() => _AnimatedManageCardState();
}

class _AnimatedManageCardState extends State<AnimatedManageCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  bool _visible = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    Future.delayed(Duration(milliseconds: 250 * widget.index), () {
      if (mounted) {
        setState(() => _visible = true);
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 600),
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
