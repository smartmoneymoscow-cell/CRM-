import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../data/demo_finance_stats.dart';
import '../utils/format.dart';

// ============================================================================
// FinancePieChart — круговая диаграмма «Структура выручки».
//
//   ┌─────────────────────────────────────┐
//   │  Структура выручки                  │
//   │        ╭──────╮                     │
//   │      ╱  Зел.  ╲  45,1%             │
//   │    ╱   Маржа    ╲                   │
//   │    ╲   Расходы  ╱  54,9%           │
//   │      ╲  Красн. ╱                   │
//   │        ╰──────╯                     │
//   │  ● Маржинальная прибыль  186 240 ₽  │
//   │  ● Переменные расходы    226 560 ₽  │
//   └─────────────────────────────────────┘
//
// Цвета — из палитры приложения: бежевая, оранжевые акценты,
// зелёный/красный для сегментов.
// ============================================================================

const _paper = Color(0xFFFBF6EC);
const _fill = Color(0xFFF3EEE4);
const _ink = Color(0xFF14130F);
const _muted = Color(0xFF8C8576);
const _muted2 = Color(0xFF9C9484);

// Сегменты
const _segMargin = Color(0xFF2F8F5B);     // зелёный — маржа
const _segExpenses = Color(0xFFC0392B);   // красный — расходы
const _segTrack = Color(0xFFE1DCCF);      // фон кольца

class FinancePieChart extends StatelessWidget {
  final FinanceStats stats;
  const FinancePieChart({super.key, this.stats = kDemoFinanceStats});

  @override
  Widget build(BuildContext context) {
    final marginPct = stats.marginPct;
    final expensesPct = stats.expensesPct;

    return Container(
      decoration: BoxDecoration(
        color: _fill,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Заголовок ──
          const Text(
            'Структура выручки',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _ink,
            ),
          ),
          const SizedBox(height: 18),

          // ── Диаграмма + проценты ──
          Center(
            child: SizedBox(
              width: 160,
              height: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(160, 160),
                    painter: _PiePainter(
                      marginFrac: marginPct / 100,
                      expensesFrac: expensesPct / 100,
                    ),
                  ),
                  // Центральная сумма
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        money(stats.revenue),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: _ink,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'выручка',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: _muted2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),

          // ── Легенда ──
          _LegendRow(
            color: _segMargin,
            label: 'Маржинальная прибыль',
            value: money(stats.marginProfit),
            pct: '${_fmtPct(marginPct)}%',
          ),
          const SizedBox(height: 10),
          _LegendRow(
            color: _segExpenses,
            label: 'Переменные расходы',
            value: money(stats.variableExpenses),
            pct: '${_fmtPct(expensesPct)}%',
          ),
        ],
      ),
    );
  }
}

String _fmtPct(double v) => v.toStringAsFixed(1).replaceAll('.', ',');

// ─── Рисователь круговой диаграммы ──────────────────────────────────────────
class _PiePainter extends CustomPainter {
  final double marginFrac;  // 0..1
  final double expensesFrac;

  _PiePainter({required this.marginFrac, required this.expensesFrac});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    const strokeWidth = 22.0;

    // Фоновое кольцо
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = _segTrack
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    // Сегменты (начинаем сверху, -90°)
    const startAngle = -math.pi / 2;

    // Маржа (зелёный)
    final marginSweep = 2 * math.pi * marginFrac;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      marginSweep,
      false,
      Paint()
        ..color = _segMargin
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // Расходы (красный)
    final expensesSweep = 2 * math.pi * expensesFrac;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle + marginSweep,
      expensesSweep,
      false,
      Paint()
        ..color = _segExpenses
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _PiePainter old) =>
      old.marginFrac != marginFrac || old.expensesFrac != expensesFrac;
}

// ─── Строка легенды ─────────────────────────────────────────────────────────
class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  final String pct;

  const _LegendRow({
    required this.color,
    required this.label,
    required this.value,
    required this.pct,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: _ink,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          pct,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _muted,
          ),
        ),
      ],
    );
  }
}
