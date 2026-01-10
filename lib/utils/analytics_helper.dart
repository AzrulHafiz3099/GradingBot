import 'dart:math';

class AnalyticsHelper {
  /// Calculate average score from distribution
  static double calculateAverage(List<Map<String, dynamic>> distribution) {
    if (distribution.isEmpty) return 0.0;
    
    double total = 0;
    int count = 0;
    
    for (var entry in distribution) {
      final score = double.tryParse(entry['score'].toString().split('/').first.trim()) ?? 0;
      final studentCount = int.tryParse(entry['count'].toString()) ?? 0;
      total += score * studentCount;
      count += studentCount;
    }
    
    return count == 0 ? 0 : total / count;
  }

  /// Calculate median score from distribution
  static double calculateMedian(List<Map<String, dynamic>> distribution) {
    if (distribution.isEmpty) return 0.0;
    
    List<double> allScores = [];
    for (var entry in distribution) {
      final score = double.tryParse(entry['score'].toString().split('/').first.trim()) ?? 0;
      final studentCount = int.tryParse(entry['count'].toString()) ?? 0;
      for (int i = 0; i < studentCount; i++) {
        allScores.add(score);
      }
    }
    
    if (allScores.isEmpty) return 0.0;
    allScores.sort();
    
    if (allScores.length.isEven) {
      return (allScores[allScores.length ~/ 2 - 1] + allScores[allScores.length ~/ 2]) / 2;
    } else {
      return allScores[allScores.length ~/ 2];
    }
  }

  /// Calculate standard deviation
  static double calculateStdDev(List<Map<String, dynamic>> distribution) {
    if (distribution.isEmpty) return 0.0;
    
    final average = calculateAverage(distribution);
    double sumSquaredDiff = 0;
    int count = 0;
    
    for (var entry in distribution) {
      final score = double.tryParse(entry['score'].toString().split('/').first.trim()) ?? 0;
      final studentCount = int.tryParse(entry['count'].toString()) ?? 0;
      sumSquaredDiff += (score - average).abs() * (score - average).abs() * studentCount;
      count += studentCount;
    }
    
    return count == 0 ? 0 : sqrt(sumSquaredDiff / count);
  }

  /// Get grade letter from score and max score
  static String getGradeLetter(double score, double maxScore) {
    final percentage = (score / maxScore) * 100;
    
    if (percentage >= 90) return 'A';
    if (percentage >= 80) return 'B';
    if (percentage >= 70) return 'C';
    if (percentage >= 60) return 'D';
    return 'F';
  }

  /// Get grade distribution (A/B/C/D/F counts)
  static Map<String, int> getGradeDistribution(
    List<Map<String, dynamic>> distribution,
    double maxScore,
  ) {
    final grades = {'A': 0, 'B': 0, 'C': 0, 'D': 0, 'F': 0};
    
    for (var entry in distribution) {
      final score = double.tryParse(entry['score'].toString().split('/').first.trim()) ?? 0;
      final studentCount = int.tryParse(entry['count'].toString()) ?? 0;
      final grade = getGradeLetter(score, maxScore);
      grades[grade] = (grades[grade] ?? 0) + studentCount;
    }
    
    return grades;
  }

  /// Get statistics summary
  static Map<String, double> getStatistics(
    List<Map<String, dynamic>> distribution,
    double maxScore,
  ) {
    final average = calculateAverage(distribution);
    final median = calculateMedian(distribution);
    final stdDev = calculateStdDev(distribution);
    
    return {
      'average': average,
      'median': median,
      'stdDev': stdDev,
      'averagePercentage': (average / maxScore) * 100,
      'medianPercentage': (median / maxScore) * 100,
    };
  }

  /// Filter distribution by score range
  static List<Map<String, dynamic>> filterByScoreRange(
    List<Map<String, dynamic>> distribution,
    double minScore,
    double maxScore,
  ) {
    return distribution.where((entry) {
      final score = double.tryParse(entry['score'].toString().split('/').first.trim()) ?? 0;
      return score >= minScore && score <= maxScore;
    }).toList();
  }

  /// Get students in score range from full student list
  static List<Map<String, dynamic>> getStudentsInRange(
    List<Map<String, dynamic>> students,
    double minScore,
    double maxScore,
  ) {
    return students.where((student) {
      final score = double.tryParse(student['Score'].toString()) ?? 0;
      return score >= minScore && score <= maxScore;
    }).toList();
  }

  /// Calculate percentile rank
  static double getPercentileRank(
    double score,
    List<Map<String, dynamic>> distribution,
  ) {
    int below = 0;
    int total = 0;
    
    for (var entry in distribution) {
      final entryScore = double.tryParse(entry['score'].toString().split('/').first.trim()) ?? 0;
      final studentCount = int.tryParse(entry['count'].toString()) ?? 0;
      total += studentCount;
      
      if (entryScore < score) {
        below += studentCount;
      }
    }
    
    return total == 0 ? 0 : (below / total) * 100;
  }

  /// Trend comparison between two exams
  static Map<String, dynamic> compareTrends(
    List<Map<String, dynamic>> currentDist,
    List<Map<String, dynamic>> previousDist,
    double currentMax,
    double previousMax,
  ) {
    final currentAvg = calculateAverage(currentDist);
    final previousAvg = calculateAverage(previousDist);
    final difference = currentAvg - previousAvg;
    final percentChange = previousAvg == 0 ? 0 : (difference / previousAvg) * 100;
    
    return {
      'currentAverage': currentAvg,
      'previousAverage': previousAvg,
      'difference': difference,
      'percentChange': percentChange,
      'trend': percentChange > 0 ? 'up' : percentChange < 0 ? 'down' : 'stable',
    };
  }
}
