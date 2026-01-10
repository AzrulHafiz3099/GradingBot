import 'dart:io';

class ExportHelper {
  /// Generate CSV content from students data
  static String generateCSV(
    String className,
    String examName,
    List<Map<String, dynamic>> students,
    double maxScore,
  ) {
    final buffer = StringBuffer();
    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    
    // Header
    buffer.writeln('Class,$className');
    buffer.writeln('Exam,$examName');
    buffer.writeln('Export Date,$dateStr');
    buffer.writeln('');
    buffer.writeln('Matrix Number,Score,Percentage,Grade');
    
    // Data
    for (var student in students) {
      final matrixNum = student['Matrix_Number'] ?? 'N/A';
      final score = student['Score'] ?? 0;
      final percentage = (score / maxScore * 100).toStringAsFixed(2);
      final grade = _getGrade(score, maxScore);
      
      buffer.writeln('$matrixNum,$score,$percentage%,$grade');
    }
    
    return buffer.toString();
  }

  /// Generate JSON content from students data
  static String generateJSON(
    String className,
    String examName,
    List<Map<String, dynamic>> students,
    List<Map<String, dynamic>> distribution,
    double maxScore,
    Map<String, dynamic> analytics,
  ) {
    final data = {
      'metadata': {
        'className': className,
        'examName': examName,
        'exportDate': DateTime.now().toIso8601String(),
        'maxScore': maxScore,
      },
      'analytics': analytics,
      'students': students.map((s) {
        return {
          'matrixNumber': s['Matrix_Number'],
          'score': s['Score'],
          'percentage': ((s['Score'] / maxScore) * 100).toStringAsFixed(2),
          'grade': _getGrade(s['Score'], maxScore),
        };
      }).toList(),
      'distribution': distribution,
    };
    
    return _formatJson(data);
  }

  /// Format JSON with proper indentation
  static String _formatJson(Map<String, dynamic> json) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(json);
  }

  /// Get grade letter
  static String _getGrade(double score, double maxScore) {
    final percentage = (score / maxScore) * 100;
    if (percentage >= 90) return 'A';
    if (percentage >= 80) return 'B';
    if (percentage >= 70) return 'C';
    if (percentage >= 60) return 'D';
    return 'F';
  }

  /// Generate email body with statistics
  static String generateEmailBody(
    String className,
    String examName,
    int totalStudents,
    int completedStudents,
    double completionPercentage,
    Map<String, dynamic> statistics,
  ) {
    return '''
<html>
<body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
  <h2 style="color: #0066cc;">Exam Analytics Report</h2>
  
  <p><strong>Class:</strong> $className</p>
  <p><strong>Exam:</strong> $examName</p>
  <p><strong>Generated:</strong> ${DateTime.now().toString()}</p>
  
  <hr style="border: none; border-top: 1px solid #ddd; margin: 20px 0;">
  
  <h3>Completion Summary</h3>
  <table style="width: 100%; border-collapse: collapse;">
    <tr style="background-color: #f0f0f0;">
      <td style="padding: 10px; border: 1px solid #ddd;"><strong>Metric</strong></td>
      <td style="padding: 10px; border: 1px solid #ddd;"><strong>Value</strong></td>
    </tr>
    <tr>
      <td style="padding: 10px; border: 1px solid #ddd;">Total Students</td>
      <td style="padding: 10px; border: 1px solid #ddd;">$totalStudents</td>
    </tr>
    <tr>
      <td style="padding: 10px; border: 1px solid #ddd;">Completed</td>
      <td style="padding: 10px; border: 1px solid #ddd;">$completedStudents</td>
    </tr>
    <tr>
      <td style="padding: 10px; border: 1px solid #ddd;">Completion %</td>
      <td style="padding: 10px; border: 1px solid #ddd;">${(completionPercentage * 100).toStringAsFixed(2)}%</td>
    </tr>
  </table>
  
  <h3 style="margin-top: 20px;">Score Statistics</h3>
  <table style="width: 100%; border-collapse: collapse;">
    <tr style="background-color: #f0f0f0;">
      <td style="padding: 10px; border: 1px solid #ddd;"><strong>Metric</strong></td>
      <td style="padding: 10px; border: 1px solid #ddd;"><strong>Value</strong></td>
    </tr>
    <tr>
      <td style="padding: 10px; border: 1px solid #ddd;">Average Score</td>
      <td style="padding: 10px; border: 1px solid #ddd;">${(statistics['average'] ?? 0).toStringAsFixed(2)}</td>
    </tr>
    <tr>
      <td style="padding: 10px; border: 1px solid #ddd;">Median Score</td>
      <td style="padding: 10px; border: 1px solid #ddd;">${(statistics['median'] ?? 0).toStringAsFixed(2)}</td>
    </tr>
    <tr>
      <td style="padding: 10px; border: 1px solid #ddd;">Std Deviation</td>
      <td style="padding: 10px; border: 1px solid #ddd;">${(statistics['stdDev'] ?? 0).toStringAsFixed(2)}</td>
    </tr>
  </table>
  
  <p style="margin-top: 30px; color: #666; font-size: 12px;">
    This is an automated report from the Grading Bot system.
  </p>
</body>
</html>
''';
  }
}

class JsonEncoder {
  final String indent;
  const JsonEncoder({this.indent = ''});
  const JsonEncoder.withIndent(this.indent);

  String convert(Object? object) {
    return _encode(object, 0);
  }

  String _encode(Object? object, int depth) {
    if (object == null) return 'null';
    if (object is bool) return object.toString();
    if (object is num) return object.toString();
    if (object is String) return '"${object.replaceAll('"', '\\"')}"';
    if (object is List) return _encodeList(object, depth);
    if (object is Map) return _encodeMap(object, depth);
    return object.toString();
  }

  String _encodeList(List list, int depth) {
    if (list.isEmpty) return '[]';
    
    final newline = indent.isNotEmpty ? '\n' : '';
    final currentIndent = indent * depth;
    final nextIndent = indent * (depth + 1);
    
    final items = list.map((item) => '$nextIndent${_encode(item, depth + 1)}').join(',$newline');
    return '[$newline$items$newline$currentIndent]';
  }

  String _encodeMap(Map map, int depth) {
    if (map.isEmpty) return '{}';
    
    final newline = indent.isNotEmpty ? '\n' : '';
    final currentIndent = indent * depth;
    final nextIndent = indent * (depth + 1);
    
    final items = map.entries
        .map((e) => '$nextIndent"${e.key}": ${_encode(e.value, depth + 1)}')
        .join(',$newline');
    return '{$newline$items$newline$currentIndent}';
  }
}
