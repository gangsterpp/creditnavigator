import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SimpleMonthlyPaymentsChart extends StatefulWidget {
  final List<double> monthlyPayments;

  const SimpleMonthlyPaymentsChart({
    super.key,
    required this.monthlyPayments,
  });

  @override
  State<SimpleMonthlyPaymentsChart> createState() => _SimpleMonthlyPaymentsChartState();
}

class _SimpleMonthlyPaymentsChartState extends State<SimpleMonthlyPaymentsChart> {
  late List<FlSpot> spots;
  double minY = 0;
  double maxY = 0;
  double horizontalInterval = 1;

  @override
  void initState() {
    super.initState();
    _recalculateData();
  }

  void _recalculateData() {
    spots = List.generate(
      widget.monthlyPayments.length,
      (index) => FlSpot(index + 1.0, widget.monthlyPayments[index]),
    );
    if (widget.monthlyPayments.isNotEmpty) {
      double computedMinY = widget.monthlyPayments.reduce((a, b) => a < b ? a : b);
      double computedMaxY = widget.monthlyPayments.reduce((a, b) => a > b ? a : b);
      if ((computedMaxY - computedMinY).abs() < 1e-6) {
        computedMinY = computedMinY - 1;
        computedMaxY = computedMaxY + 1;
      } else {
        final margin = (computedMaxY - computedMinY) * 0.1;
        computedMinY -= margin;
        computedMaxY += margin;
      }
      setState(() {
        minY = computedMinY;
        maxY = computedMaxY;
        horizontalInterval = (maxY - minY) / 5;
        if (horizontalInterval == 0) {
          horizontalInterval = 1;
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant SimpleMonthlyPaymentsChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    _recalculateData();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.6,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LineChart(
          LineChartData(
            minX: 1,
            maxX: widget.monthlyPayments.length.toDouble(),
            minY: minY,
            maxY: maxY,
            // Отключаем линии сетки
            gridData: FlGridData(
              show: false,
            ),
            titlesData: FlTitlesData(
              show: true,
              // Нижняя ось: подписываем месяцы
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    final int month = value.toInt();
                    final int totalMonths = widget.monthlyPayments.length;
                    // Если месяцев больше 12, показываем только первый, средний и последний
                    if (totalMonths > 12) {
                      final int midMonth = (totalMonths / 2).round();
                      if (month == 1 || month == midMonth || month == totalMonths) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            month.toString(),
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    }
                    // Иначе показываем все месяцы
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        month.toString(),
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  },
                ),
              ),
              // Левая ось: величина платежа
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  interval: horizontalInterval,
                  getTitlesWidget: (value, meta) => Text(
                    value.toStringAsFixed(0),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(
              show: true,
              border: const Border(
                bottom: BorderSide(color: Colors.black),
                left: BorderSide(color: Colors.black),
                right: BorderSide(color: Colors.transparent),
                top: BorderSide(color: Colors.transparent),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: false,
                color: Colors.blue,
                barWidth: 2,
                dotData: FlDotData(show: true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
