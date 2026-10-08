import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/market.dart';
import '../utils/format.dart';

class PriceChart extends StatelessWidget {
  final List<PricePoint> points;
  const PriceChart({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox(height: 220, child: Center(child: Text('No chart data yet')));
    final spots = [for (var i = 0; i < points.length; i++) FlSpot(i.toDouble(), points[i].price)];
    return SizedBox(
      height: 240,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: true),
            titlesData: const FlTitlesData(
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 56)),
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (touched) => touched
                    .map((s) => LineTooltipItem(fmtPrice(s.y), const TextStyle(fontWeight: FontWeight.bold)))
                    .toList(),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(show: true, color: Colors.deepPurple.withValues(alpha: 0.15)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
