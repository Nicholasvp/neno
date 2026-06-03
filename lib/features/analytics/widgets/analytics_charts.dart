import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_theme.dart';
import '../bloc/analytics_state.dart';

class Last7DaysChart extends StatelessWidget {
  const Last7DaysChart({super.key, required this.buckets});
  final List<DayBucket> buckets;

  @override
  Widget build(BuildContext context) {
    if (buckets.isEmpty) {
      return const SizedBox(height: 180);
    }
    final maxY = buckets.map((b) => b.count).fold<int>(0, (a, b) => a > b ? a : b);
    final ceiling = (maxY == 0 ? 4 : maxY + 2).toDouble();
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: ceiling,
          minY: 0,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, _, rod, __) {
                final b = buckets[group.x.toInt()];
                return BarTooltipItem(
                  '${b.count} mov.',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: ceiling / 4,
                getTitlesWidget: (value, meta) {
                  if (value % 1 != 0) return const SizedBox.shrink();
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= buckets.length) return const SizedBox.shrink();
                  final label = DateFormat('E', 'pt_BR').format(buckets[i].date).substring(0, 3);
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      label,
                      style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: Colors.grey.shade200,
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            for (int i = 0; i < buckets.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: buckets[i].count.toDouble(),
                    color: AppTheme.primary,
                    width: 18,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class HourDistributionChart extends StatelessWidget {
  const HourDistributionChart({super.key, required this.buckets});
  final List<HourBucket> buckets;

  @override
  Widget build(BuildContext context) {
    final maxY = buckets.map((b) => b.count).fold<int>(0, (a, b) => a > b ? a : b);
    final ceiling = (maxY == 0 ? 2 : maxY + 1).toDouble();
    return SizedBox(
      height: 160,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceBetween,
          maxY: ceiling,
          minY: 0,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, _, rod, __) {
                final b = buckets[group.x.toInt()];
                return BarTooltipItem(
                  '${b.hour}h — ${b.count} mov.',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                interval: 3,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() % 3 != 0) return const SizedBox.shrink();
                  return Text(
                    '${value.toInt()}h',
                    style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                  );
                },
              ),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: [
            for (int i = 0; i < buckets.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: buckets[i].count.toDouble(),
                    color: AppTheme.primary.withValues(alpha: 0.7),
                    width: 8,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
