import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EarningChart extends StatelessWidget {
  const EarningChart({super.key, required this.data});

  final List<Map<String, dynamic>> data;

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        //using slightly higher maxY to show top border of the highest bar
        //and slightly lower minY to show bottom border of the lowest bar
        maxY: 1500.01,
        minY: -0.01,
        barTouchData: BarTouchData(enabled: true),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 300,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: Colors.white10, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 300,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(
                '\$${value.toInt()}',
                style: TextStyle(color: Colors.white, fontSize: 10.sp),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index >= 0 && index < data.length) {
                  return SideTitleWidget(
                    meta: meta,
                    space: 8,
                    child: Text(
                      data[index]['month'] ?? '',
                      style: TextStyle(color: Colors.white, fontSize: 10.sp),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: data.asMap().entries.map((e) {
          final double rawAmount =
              (e.value['amount'] as num?)?.toDouble() ?? 0.0;
          // Show a minimal bar for $0 values so the chart doesn't look empty
          //final double displayAmount = rawAmount == 0 ? 100.0 : rawAmount;

          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                //toY: displayAmount,
                toY: rawAmount,
                width: 16.w,
                gradient: const LinearGradient(
                  colors: [Colors.redAccent, Color(0xFF8E0E00)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(0),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
