import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/chart_data_service.dart';

/// Time of day drinking pattern bar chart
class TimeOfDayPatternChart extends StatelessWidget {
  final List<TimeOfDayData> data;
  
  const TimeOfDayPatternChart({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty || data.every((d) => d.drinkCount == 0)) {
      return _buildEmptyState();
    }

    final maxY = data.map((d) => d.drinkCount).reduce((a, b) => a > b ? a : b);
    final chartMaxY = maxY > 0 ? (maxY * 1.2).ceil().toDouble() : 10.0;

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: chartMaxY,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                if (groupIndex < data.length) {
                  final timeData = data[groupIndex];
                  return BarTooltipItem(
                    '${timeData.timeSlot}\n${timeData.drinkCount} drinks',
                    TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                }
                return null;
              },
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 35,
                getTitlesWidget: (value, meta) {
                  if (value % 1 == 0 && value >= 0) {
                    return Text(
                      value.toInt().toString(),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 35,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < data.length) {
                    final timeSlot = data[index].timeSlot;
                    // Shorten labels for mobile
                    final shortLabel = _getShortLabel(timeSlot);
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        shortLabel,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              left: BorderSide(color: Colors.grey.shade300),
              bottom: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: chartMaxY > 10 ? (chartMaxY / 5).ceil().toDouble() : 2,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.shade300,
                strokeWidth: 1,
              );
            },
          ),
          barGroups: data.asMap().entries.map((entry) {
            final index = entry.key;
            final timeData = entry.value;
            
            // Different colors for different times of day
            final barColor = _getTimeColor(timeData.timeSlot);
            
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: timeData.drinkCount.toDouble(),
                  color: barColor,
                  width: 22,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: chartMaxY,
                    color: Colors.grey.shade100,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getShortLabel(String timeSlot) {
    switch (timeSlot) {
      case 'Morning':
        return 'Morn';
      case 'Noon':
        return 'Noon';
      case 'Afternoon':
        return 'Aftn';
      case 'Evening':
        return 'Even';
      case 'Night':
        return 'Night';
      default:
        return timeSlot.substring(0, 4);
    }
  }

  Color _getTimeColor(String timeSlot) {
    switch (timeSlot) {
      case 'Morning':
        return Colors.yellow.shade600;  // Morning sun
      case 'Noon':
        return Colors.orange.shade600;  // Noon sun
      case 'Afternoon':
        return Colors.amber.shade600;   // Afternoon
      case 'Evening':
        return Colors.purple.shade600;  // Evening
      case 'Night':
        return Colors.indigo.shade600;  // Night
      default:
        return Colors.grey.shade600;
    }
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.access_time_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              'No time pattern data yet',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Log drinks to see when you drink most',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
