import 'dart:math' as math;
import 'package:flutter/material.dart';

// ============================================================================
// RevenueDynamicsChart — график динамики выручки, маржи и расходов
//
//   ┌──────────────────────────────────────────┐
//   │  Динамика показателей                    │
//   │                                          │
//   │  ── Выручка          350k ────────────   │
//   │  ── Маржинальная     200k ────────       │
//   │  ── Переменные       150k ──────         │
//   │                                          │
//   │  [По месяцам] [По неделям]               │
//   └──────────────────────────────────────────┘
// ============================================================================

const _ink = Color(0xFF14130F);
const _paper = Color(0xFFFBF6EC);
const _fill = Color(0xFFF3EEE4);
const _orange = Color(0xFFE8912B);
const _hairline2 = Color(0xFFE7E0D1);
const _muted = Color(0xFF8C8576);
const _muted2 = Color(0xFF9C9484);

// ── Демо-данные по месяцам ──
class MonthlyData {
  final String label; // Янв, Фев, ...
  final double revenue;
  final double margin;
  final double expenses;

  const MonthlyData({
    required this.label,
    required this.revenue,
    required this.margin,
    required this.expenses,
  });
}

const _monthlyData = <MonthlyData>[
  MonthlyData(label: 'Янв', revenue: 280000, margin: 126000, expenses: 154000),
  MonthlyData(label: 'Фев', revenue: 310000, margin: 139500, expenses: 170500),
  MonthlyData(label: 'Мар', revenue: 340000, margin: 153000, expenses: 187000),
  MonthlyData(label: 'Апр', revenue: 295000, margin: 132750, expenses: 162250),
  MonthlyData(label: 'Май', revenue: 380000, margin: 171000, expenses: 209000),
  MonthlyData(label: 'Июн', revenue: 420000, margin: 189000, expenses: 231000),
  MonthlyData(label: 'Июл', revenue: 412800, margin: 186240, expenses: 226560),
];

const _weeklyData = <MonthlyData>[
  MonthlyData(label: '1', revenue: 85000, margin: 38250, expenses: 46750),
  MonthlyData(label: '2', revenue: 92000, margin: 41400, expenses: 50600),
  MonthlyData(label: '3', revenue: 110000, margin: 49500, expenses: 60500),
  MonthlyData(label: '4', revenue: 98000, margin: 44100, expenses: 53900),
  MonthlyData(label: '5', revenue: 105000, margin: 47250, expenses: 57750),
  MonthlyData(label: '6', revenue: 120000, margin: 54000, expenses: 66000),
  MonthlyData(label: '7', revenue: 115000, margin: 51750, expenses: 63250),
  MonthlyData(label: '8', revenue: 95000, margin: 42750, expenses: 52250),
  MonthlyData(label: '9', revenue: 108000, margin: 48600, expenses: 59400),
  MonthlyData(label: '10', revenue: 102000, margin: 45900, expenses: 56100),
  MonthlyData(label: '11', revenue: 125000, margin: 56250, expenses: 68750),
  MonthlyData(label: '12', revenue: 130000, margin: 58500, expenses: 71500),
];

class RevenueDynamicsChart extends StatefulWidget {
  const RevenueDynamicsChart({super.key});

  @override
  State<RevenueDynamicsChart> createState() => _RevenueDynamicsChartState();
}

class _RevenueDynamicsChartState extends State<RevenueDynamicsChart> {
  bool _monthly = true;

  List<MonthlyData> get _data => _monthly ? _monthlyData : _weeklyData;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _paper,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _hairline2, width: 0.5),
      ),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Заголовок ──
          const Text(
            'Динамика показателей',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _ink,
            ),
          ),
          const SizedBox(height: 16),

          // ── Легенда ──
          Row(
            children: [
              _legendDot(const Color(0xFFE8912B), 'Выручка'),
              const SizedBox(width: 16),
              _legendDot(const Color(0xFF4A7C59), 'Маржа'),
              const SizedBox(width: 16),
              _legendDot(const Color(0xFFC0392B), 'Расходы'),
            ],
          ),
          const SizedBox(height: 16),

          // ── График ──
          SizedBox(
            height: 180,
            child: CustomPaint(
              size: const Size(double.infinity, 180),
              painter: _ChartPainter(data: _data),
            ),
          ),
          const SizedBox(height: 12),

          // ── Подписи оси X ──
          SizedBox(
            height: 20,
            child: Row(
              children: _data.map((d) {
                return Expanded(
                  child: Text(
                    d.label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 10,
                      color: _muted2,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // ── Переключатель ──
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: _fill,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(3),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _toggleBtn('По месяцам', _monthly, () {
                    setState(() => _monthly = true);
                  }),
                  _toggleBtn('По неделям', !_monthly, () {
                    setState(() => _monthly = false);
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: _ink,
          ),
        ),
      ],
    );
  }

  Widget _toggleBtn(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: active ? _ink : _muted2,
          ),
        ),
      ),
    );
  }
}

// ─── Рисователь графика ─────────────────────────────────────────────────────
class _ChartPainter extends CustomPainter {
  final List<MonthlyData> data;

  _ChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final allValues = <double>[];
    for (final d in data) {
      allValues.addAll([d.revenue, d.margin, d.expenses]);
    }
    final maxVal = allValues.reduce(math.max);
    final minVal = 0.0;
    final range = maxVal - minVal;
    if (range <= 0) return;

    final chartLeft = 40.0;
    final chartRight = size.width - 8;
    final chartTop = 8.0;
    final chartBottom = size.height - 8;
    final chartW = chartRight - chartLeft;
    final chartH = chartBottom - chartTop;

    // Горизонтальные линии сетки
    final gridPaint = Paint()
      ..color = const Color(0xFFEFE8D8)
      ..strokeWidth = 0.5;

    for (int i = 0; i <= 4; i++) {
      final y = chartTop + chartH * i / 4;
      canvas.drawLine(
        Offset(chartLeft, y),
        Offset(chartRight, y),
        gridPaint,
      );

      // Подписи Y
      final val = maxVal - (maxVal * i / 4);
      final tp = TextPainter(
        text: TextSpan(
          text: _fmtShort(val),
          style: const TextStyle(fontSize: 9, color: Color(0xFF9C9484)),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(chartLeft - tp.width - 4, y - tp.height / 2));
    }

    // Рисуем линии
    _drawLine(canvas, data.map((d) => d.revenue).toList(), const Color(0xFFE8912B),
        chartLeft, chartTop, chartW, chartH, maxVal, minVal);
    _drawLine(canvas, data.map((d) => d.margin).toList(), const Color(0xFF4A7C59),
        chartLeft, chartTop, chartW, chartH, maxVal, minVal);
    _drawLine(canvas, data.map((d) => d.expenses).toList(), const Color(0xFFC0392B),
        chartLeft, chartTop, chartW, chartH, maxVal, minVal);
  }

  void _drawLine(Canvas canvas, List<double> values, Color color,
      double left, double top, double w, double h, double maxVal, double minVal) {
    if (values.length < 2) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final range = maxVal - minVal;
    final dx = w / (values.length - 1);

    Offset toOffset(int i) => Offset(
          left + i * dx,
          top + h - ((values[i] - minVal) / range) * h,
        );

    final path = Path()..moveTo(toOffset(0).dx, toOffset(0).dy);
    for (int i = 0; i < values.length - 1; i++) {
      final p0 = toOffset(i);
      final p1 = toOffset(i + 1);
      final mid = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
      path.quadraticBezierTo(p0.dx, p0.dy, mid.dx, mid.dy);
      if (i == values.length - 2) path.lineTo(p1.dx, p1.dy);
    }

    canvas.drawPath(path, paint);

    // Точки на линии
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    for (int i = 0; i < values.length; i++) {
      canvas.drawCircle(toOffset(i), 3, dotPaint);
    }
  }

  String _fmtShort(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).round()}k';
    return v.round().toString();
  }

  @override
  bool shouldRepaint(covariant _ChartPainter old) => old.data != data;
}
