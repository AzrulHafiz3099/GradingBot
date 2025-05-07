import 'package:flutter/material.dart';
import '/utils/colors.dart';
import 'Result_Details.dart'; // Import the result details page

class ResultManagementPage extends StatelessWidget {
  const ResultManagementPage({super.key});

  final List<Map<String, String>> results = const [
    {
      'name': 'AZRUL HAFIZ BIN ABDULLAH',
      'class': 'BITP2223',
      'score': '2/2',
    },
    {
      'name': 'AZRUL HAFIZ BIN ABDULLAH',
      'class': 'BITP2223',
      'score': '2/2',
    },
    {
      'name': 'AZRUL HAFIZ BIN ABDULLAH',
      'class': 'BITP2223',
      'score': '2/2',
    },
    {
      'name': 'AZRUL HAFIZ BIN ABDULLAH',
      'class': 'BITP2223',
      'score': '0/2',
    },
  ];

  Color _getScoreColor(String score) {
    final parts = score.split('/');
    if (parts.length == 2 && parts[0] == '0') {
      return Colors.red;
    }
    return const Color(0xFF2BA8FF); // Blue
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
          'Result Management',
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
          children: [
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Text(
                    'Student Name',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Class',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Score',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),

            Expanded(
              child: ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final result = results[index];
                  final scoreColor = _getScoreColor(result['score']!);

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ResultDetailsPage(),
                          // You can pass result data here if needed
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: Text(result['name'] ?? ''),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(result['class'] ?? ''),
                            ),
                            Expanded(
                              flex: 2,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  result['score'] ?? '',
                                  style: TextStyle(color: scoreColor),
                                ),
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
          ],
        ),
      ),
    );
  }
}
