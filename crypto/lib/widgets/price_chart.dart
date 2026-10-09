import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../model/price_point.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';

/// Bright-green line chart with gradient fill, touch tooltip,
/// dashed MIN line and MAX/MIN labels like the reference design.
class PriceChart extends StatelessWidget {
  final List<PricePoint> points;
  const PriceChart({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const SizedBox(
        height: 220,
        child: Center(child: Text('No chart data yet', style: TextStyle(color: AppColors.muted))),
      );
    }
    final spots = [for (var i = 0; i < points.length; i++) FlSpot(i.toDouble(), points[i].price)];
    double minY = spots.first.y, maxY = spots.first.y;
    for (final s in spots) {
      if (s.y < minY) minY = s.y;
      if (s.y > maxY) maxY = s.y;
    }
    final pad = (maxY - minY).abs() < 1e-9 ? maxY * 0.01 : (maxY - minY) * 0.08;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Text('MAX ${fmtPrice(maxY)}',
              style: const TextStyle(color: AppColors.muted, fontSize: 12)),
        ),
        SizedBox(
          height: 220,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 16, 8),
            child: LineChart(
              LineChartData(
                minY: minY - pad,
                maxY: maxY + pad,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: const FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: minY,
                      color: AppColors.muted.withValues(alpha: 0.7),
                      strokeWidth: 1,
                      dashArray: [6, 5],
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.centerRight,
                        style: const TextStyle(color: AppColors.muted, fontSize: 11),
                        labelResolver: (_) => 'MIN ${fmtPrice(minY)}',
                      ),
                    ),
                  ],
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    tooltipRoundedRadius: 12,
                    getTooltipItems: (touched) => touched
                        .map((s) => LineTooltipItem(fmtPrice(s.y),
                            const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)))
                        .toList(),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.chartLine,
                    barWidth: 2.5,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [AppColors.chartLine.withValues(alpha: 0.35), Colors.transparent],
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
      ],
    );
  }
}
