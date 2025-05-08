import 'package:flutter/material.dart';
import 'ClassPage/Class_Management.dart';
import 'StudentPage/Student_Management.dart';
import 'ExamPage/Exam_Management.dart';
import 'ResultPage/Result_Management.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
            _buildResultCard("AZRUL HAFIZ BIN ABDULLAH"),
            _buildResultCard("AMIR HAMZAH BIN MOHD ZAMRI"),
            _buildResultCard("MOHAMAD IMAN AKMAL BIN ISMAIL"),
            _buildResultCard("NUR AMALINA AQILAH BINTI MOHD NAPI"),
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
          const Text(
            'Hi, Welcome Back Azrul',
            style: TextStyle(
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
                offset: const Offset(0, -16), // Move it up by 16 pixels
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
                        '2',
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
                        '21',
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
                        '5',
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
                        '35',
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

  Widget _buildResultCard(String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Color(0x11000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
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
              children: const [
                Text("Submitted :  13/4/2025", style: TextStyle(fontSize: 12)),
                Text(
                  "Score :  2/2",
                  style: TextStyle(fontSize: 12, color: Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Align(
              alignment: Alignment.bottomRight,
              child: Text(
                "BITP3233",
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShowMoreButton() {
    return ElevatedButton(
      onPressed: () {},
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
