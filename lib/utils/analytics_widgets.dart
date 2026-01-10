import 'package:flutter/material.dart';
import 'dart:math';

/// Statistics Card Widget
class StatisticsCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const StatisticsCard({
    required this.label,
    required this.value,
    required this.icon,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Grade Distribution Bar Chart
class GradeDistributionChart extends StatelessWidget {
  final Map<String, int> grades;

  const GradeDistributionChart({required this.grades});

  @override
  Widget build(BuildContext context) {
    final total = grades.values.fold<int>(0, (sum, val) => sum + val);
    final maxCount = grades.values.isEmpty ? 1 : grades.values.reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Grade Distribution',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...['A', 'B', 'C', 'D', 'F'].map((grade) {
          final count = grades[grade] ?? 0;
          final percentage = total == 0 ? 0.0 : (count / total) * 100;
          final barWidth = maxCount == 0 ? 0.0 : (count / maxCount) * 300;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Grade $grade',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '$count students (${percentage.toStringAsFixed(1)}%)',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    height: 24,
                    width: barWidth,
                    decoration: BoxDecoration(
                      color: _getGradeColor(grade),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: count > 0
                            ? Text(
                              count.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            )
                            : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
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
}

/// Score Range Filter
class ScoreRangeFilter extends StatefulWidget {
  final Function(double, double) onRangeChanged;
  final double maxScore;

  const ScoreRangeFilter({
    required this.onRangeChanged,
    required this.maxScore,
  });

  @override
  State<ScoreRangeFilter> createState() => _ScoreRangeFilterState();
}

class _ScoreRangeFilterState extends State<ScoreRangeFilter> {
  late RangeValues _rangeValues;

  @override
  void initState() {
    super.initState();
    _rangeValues = RangeValues(0, widget.maxScore);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Filter by Score Range',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        RangeSlider(
          values: _rangeValues,
          min: 0,
          max: widget.maxScore,
          divisions: (widget.maxScore * 2).toInt(),
          labels: RangeLabels(
            _rangeValues.start.toStringAsFixed(1),
            _rangeValues.end.toStringAsFixed(1),
          ),
          onChanged: (RangeValues newValues) {
            setState(() {
              _rangeValues = newValues;
            });
            widget.onRangeChanged(_rangeValues.start, _rangeValues.end);
          },
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Min: ${_rangeValues.start.toStringAsFixed(1)}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              Text(
                'Max: ${_rangeValues.end.toStringAsFixed(1)}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Student Search Bar
class StudentSearchBar extends StatefulWidget {
  final Function(String) onSearchChanged;

  const StudentSearchBar({required this.onSearchChanged});

  @override
  State<StudentSearchBar> createState() => _StudentSearchBarState();
}

class _StudentSearchBarState extends State<StudentSearchBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: 'Search by matrix number or name...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _controller.clear();
                widget.onSearchChanged('');
              },
            )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onChanged: (value) {
        setState(() {});
        widget.onSearchChanged(value);
      },
    );
  }
}

/// Skeleton Loading Widget
class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade200,
                Colors.grey.shade300,
              ],
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Histogram Widget
class HistogramChart extends StatelessWidget {
  final List<Map<String, dynamic>> distribution;
  final double maxScore;

  const HistogramChart({
    required this.distribution,
    required this.maxScore,
  });

  @override
  Widget build(BuildContext context) {
    if (distribution.isEmpty) {
      return const Center(
        child: Text('No data available'),
      );
    }

    final maxCount = distribution.fold<int>(
      0,
      (max, entry) => max > (int.tryParse(entry['count'].toString()) ?? 0)
          ? max
          : (int.tryParse(entry['count'].toString()) ?? 0),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Score Distribution Histogram',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 250,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: distribution.map((entry) {
              final score = entry['score'].toString();
              final count = int.tryParse(entry['count'].toString()) ?? 0;
              final height = maxCount == 0 ? 0.0 : (count / maxCount) * 200;

              return Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      count.toString(),
                      style: const TextStyle(fontSize: 10),
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      child: Container(
                        width: 30,
                        height: height,
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.7),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      score,
                      style: const TextStyle(fontSize: 9),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

/// Export Options Menu
class ExportOptionsMenu extends StatelessWidget {
  final VoidCallback onPDFTap;
  final VoidCallback onCSVTap;
  final VoidCallback onJSONTap;
  final VoidCallback onEmailTap;

  const ExportOptionsMenu({
    required this.onPDFTap,
    required this.onCSVTap,
    required this.onJSONTap,
    required this.onEmailTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Export Options',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildExportOption(
            icon: Icons.picture_as_pdf,
            label: 'Export as PDF',
            color: Colors.red,
            onTap: onPDFTap,
          ),
          const SizedBox(height: 8),
          _buildExportOption(
            icon: Icons.table_chart,
            label: 'Export as CSV',
            color: Colors.green,
            onTap: onCSVTap,
          ),
          const SizedBox(height: 8),
          _buildExportOption(
            icon: Icons.code,
            label: 'Export as JSON',
            color: Colors.blue,
            onTap: onJSONTap,
          ),
          const SizedBox(height: 8),
          _buildExportOption(
            icon: Icons.email,
            label: 'Share via Email',
            color: Colors.orange,
            onTap: onEmailTap,
          ),
        ],
      ),
    );
  }

  Widget _buildExportOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}

/// Animated Statistics Card
class AnimatedStatCard extends StatefulWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;

  const AnimatedStatCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
  });

  @override
  State<AnimatedStatCard> createState() => _AnimatedStatCardState();
}

class _AnimatedStatCardState extends State<AnimatedStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (_animation.value * 0.2),
          child: Opacity(
            opacity: _animation.value,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade400,
                    Colors.blue.shade600,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(widget.icon, color: Colors.white, size: 28),
                  const SizedBox(height: 8),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        widget.value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.unit,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
