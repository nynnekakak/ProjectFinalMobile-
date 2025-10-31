import 'package:flutter/material.dart';
import '../../core/utils/format.dart';
import 'dart:math';

class SpendingChartPage extends StatefulWidget {
  const SpendingChartPage({super.key});
  @override
  State<SpendingChartPage> createState() => _SpendingChartPageState();
}

enum Period { week, month, year }

class _SpendingChartPageState extends State<SpendingChartPage> {
  Period period = Period.week;

  @override
  Widget build(BuildContext context) {
    final series = _mockSeries(period);
    final total = series.fold<int>(0, (p, e) => p + e);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SegmentedButton<Period>(
          segments: const [
            ButtonSegment(value: Period.week, label: Text('Tuần')),
            ButtonSegment(value: Period.month, label: Text('Tháng')),
            ButtonSegment(value: Period.year, label: Text('Năm')),
          ],
          selected: {period},
          onSelectionChanged: (s) => setState(() => period = s.first),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.trending_down),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tổng chi',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
                Text(
                  '-${fmMoney(total)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          child: SizedBox(height: 200, child: _Bars(series: series)),
        ),
      ],
    );
  }

  List<int> _mockSeries(Period p) {
    if (p == Period.week)
      return [120000, 80000, 50000, 220000, 90000, 0, 30000];
    if (p == Period.month) return List.generate(30, (i) => (i % 5) * 20000);
    return List.generate(12, (i) => (i % 4) * 150000);
  }
}

class _Bars extends StatelessWidget {
  final List<int> series;
  const _Bars({required this.series});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return CustomPaint(painter: _BarsPainter(color, series));
  }
}

class _BarsPainter extends CustomPainter {
  final Color color;
  final List<int> series;
  _BarsPainter(this.color, this.series);

  @override
  void paint(Canvas canvas, Size size) {
    final maxV = series.isEmpty ? 0 : series.reduce(max);
    final paint = Paint()..color = color.withOpacity(0.65);
    const vPad = 12.0, hPad = 16.0;
    final availH = size.height - vPad * 2;
    final n = max(1, series.length);
    final gap = (n <= 12) ? 8.0 : 2.0;
    final barW = (size.width - hPad * 2 - gap * (n - 1)) / n;

    for (int i = 0; i < n; i++) {
      final v = series.isEmpty ? 0 : series[i];
      final h = (maxV == 0 ? 0 : (v / maxV) * availH) * 1.0;
      final x = hPad + i * (barW + gap);
      final y = size.height - vPad - h;
      final r = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barW, h),
        const Radius.circular(6),
      );
      canvas.drawRRect(r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BarsPainter old) =>
      old.color != color || old.series != series;
}
