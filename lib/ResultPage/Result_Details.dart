import 'package:flutter/material.dart';
import '/utils/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/utils/env.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:flutter/services.dart' show rootBundle;

class ResultDetailsPage extends StatefulWidget {
  final String studentId;
  final String resultId;

  const ResultDetailsPage({super.key, required this.studentId, required this.resultId});

  @override
  State<ResultDetailsPage> createState() => _ResultDetailsPageState();
}

class _ResultDetailsPageState extends State<ResultDetailsPage> {
  Map<String, dynamic>? studentResult;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchStudentResult();
  }

  Future<void> _downloadResultSummary() async {
  if (studentResult == null) return;

  final pdf = pw.Document();

  final imageLogo = pw.MemoryImage(
    (await rootBundle.load('assets/logo.png')).buffer.asUint8List(),
  );

  print("Summary raw value: ${studentResult?['summary']}");

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Result Summary', style: pw.TextStyle(fontSize: 20)),
              pw.Image(imageLogo, height: 60, width: 60),
            ],
          ),
          pw.Divider(),
          pw.SizedBox(height: 10),
          _buildPdfText('Matrix Number', studentResult?['matrix_number']),
          _buildPdfText('Class', studentResult?['class_name']),
          _buildPdfText('Exam', studentResult?['exam_name']),
          _buildPdfText('Phone No.', studentResult?['phone_number']),
          _buildPdfText('Score', studentResult?['score']?.toString()),
          _buildPdfText('Timestamp', studentResult?['timestamp']),
          pw.SizedBox(height: 10),
          pw.Text('Answer Summary:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 5),
          ..._buildSummaryLines(studentResult?['summary']),
        ];
      },
    ),
  );

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
    name: 'Result_Summary_${studentResult?['matrix_number'] ?? 'Student'}.pdf',
  );
}

List<pw.Widget> _buildSummaryLines(String? summary) {
  if (summary == null || summary.trim().isEmpty) {
    return [pw.Text('-', style: pw.TextStyle(fontSize: 12))];
  }

  final lines = summary.split('\n');
  final widgets = <pw.Widget>[];

  for (int i = 0; i < lines.length; i++) {
    final line = lines[i].trim();

    // Skip completely empty lines
    if (line.isEmpty) continue;

    // If line starts with "Question" and it's NOT the first line, add space above
    if (RegExp(r'^Question\s+\d+', caseSensitive: false).hasMatch(line) && widgets.isNotEmpty) {
      widgets.add(pw.SizedBox(height: 10));
    }

    widgets.add(pw.Text(line, style: pw.TextStyle(fontSize: 12)));
  }

  return widgets;
}



pw.Widget _buildPdfText(String label, String? value) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 6),
    child: pw.RichText(
      text: pw.TextSpan(
        children: [
          pw.TextSpan(
            text: '$label: ',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
          ),
          pw.TextSpan(
            text: value ?? '-',
            style: pw.TextStyle(fontSize: 12),
          ),
        ],
      ),
    ),
  );
}


  Future<void> _fetchStudentResult() async {
    try {
      final response = await http.get(
        Uri.parse('${Env.baseUrl}/api_result/by_result?result_id=${widget.resultId}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          setState(() {
            studentResult = data['data'];
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
    const secondaryColor = Color(0xFF2BA8FF);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: secondaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Result Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: secondaryColor,
          ),
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
                ? Center(child: Text(errorMessage!))
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: ListView(
                      children: [
                        _buildTextField(label: 'Matrix Number', value: studentResult?['matrix_number'] ?? ''),
                        _buildTextField(label: 'Class', value: studentResult?['class_name'] ?? ''),
                        _buildTextField(label: 'Exam', value: studentResult?['exam_name'] ?? ''),
                        _buildTextField(label: 'Phone No.', value: studentResult?['phone_number'] ?? ''),
                        _buildTextField(label: 'Score', value: studentResult?['score'] ?? ''),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _downloadResultSummary,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: secondaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Download Result Summary', style: TextStyle(color: Colors.white)),
                        )
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildTextField({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          TextField(
            readOnly: true,
            controller: TextEditingController(text: value),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
            ),
          ),
        ],
      ),
    );
  }
}
