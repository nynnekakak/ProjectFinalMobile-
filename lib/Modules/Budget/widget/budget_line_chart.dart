import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class BudgetLineChart extends StatelessWidget {
  final Map<DateTime, double> spendingData;
  final DateTime startDate;
  final DateTime endDate;
  final double budgetAmount;

  const BudgetLineChart({
    super.key,
    required this.spendingData,
    required this.startDate,
    required this.endDate,
    required this.budgetAmount,
  });

  @override
  Widget build(BuildContext context) {
    // Define colors to match app style
    final primaryBlue = const Color(0xFF0040FF);
    final lightBlue = const Color(0xFFE3EAFF);

    final totalDays = endDate.difference(startDate).inDays + 1;

    final List<FlSpot> actualSpots = [];

    double cumulativeSpending = 0;
    for (int i = 0; i < totalDays; i++) {
      final currentDate = startDate.add(Duration(days: i));
      final dailySpending = spendingData[currentDate] ?? 0;
      cumulativeSpending = dailySpending;
      actualSpots.add(FlSpot(i.toDouble(), cumulativeSpending));
    }

    // Calculate the width for scrolling - show maximum 10 days at once
    final maxVisibleDays = min(10, totalDays);
    final chartWidth = MediaQuery.of(context).size.width;
    final totalChartWidth = totalDays > maxVisibleDays
        ? (chartWidth * totalDays) / maxVisibleDays
        : chartWidth;

    return Container(
      height: 250,
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Expanded(
          //padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: totalChartWidth,
              child: LineChart(
                LineChartData(
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        reservedSize: 30,
                        interval: 1,
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= totalDays) return const Text('');
                          final day =
                              startDate.add(Duration(days: value.toInt()));
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              '${day.day}/${day.month}',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        interval: null, // Allow automatic interval calculation
                        getTitlesWidget: (value, meta) {
                          // Skip the topmost valueAdd commentMore actions
                          if (meta.max == value) return const SizedBox.shrink();
                          if (value == 0) return const Text('0');
                          if (value >= 1000) {
                            return Text(
                              '${(value / 1000).toStringAsFixed(1)}k',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          }
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  minX: 0,
                  maxX: totalDays.toDouble() - 1,
                  minY: 0,
                  maxY: max(
                          budgetAmount,
                          actualSpots.isNotEmpty
                              ? actualSpots.map((spot) => spot.y).reduce(max)
                              : 0) *
                      1.2,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    drawHorizontalLine: true,
                    //horizontalInterval: budgetAmount / 5,
                    //verticalInterval: max(1, totalDays / 10).toDouble(),
                    getDrawingHorizontalLine: (value) {
                      // Budget threshold line
                      if (value.toInt() == budgetAmount.toInt()) {
                        return FlLine(
                          color: Colors.redAccent,
                          strokeWidth: 1,
                          dashArray: [5, 5],
                        );
                      }
                      return FlLine(
                        color: Colors.grey.withOpacity(0.2),
                        strokeWidth: 0.8,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.2),
                        strokeWidth: 0.8,
                      );
                    },
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  lineBarsData: [
                    // Budget line (optional)
                    LineChartBarData(
                      spots: [
                        FlSpot(0, budgetAmount),
                        FlSpot(totalDays.toDouble() - 1, budgetAmount),
                      ],
                      isCurved: false,
                      color: Colors.red.withOpacity(0.5),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      dashArray: [5, 5],
                    ),
                    // Actual spending line
                    LineChartBarData(
                      spots: actualSpots,
                      isCurved: true,
                      color: primaryBlue,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 3,
                            color: primaryBlue,
                            strokeWidth: 1,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: lightBlue.withOpacity(0.5),
                        gradient: LinearGradient(
                          colors: [
                            primaryBlue.withOpacity(0.4),
                            primaryBlue.withOpacity(0.1),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
