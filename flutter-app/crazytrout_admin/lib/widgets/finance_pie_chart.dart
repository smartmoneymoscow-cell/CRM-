import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../data/sales_decomposition.dart';

// ============================================================================
// FinancePieChart — круговая диаграмма «Декомпозиция продаж».
//
// Легенда слева, кольцевая диаграмма справа.
// Стиль: flat, тонкие белые разделители, палитра приложения.
//
//   ┌──────────────────────────────────────────┐
//   │  Декомпозиция продаж                     │
//   │                                          │
//   │  ● Осётр        36%   148 800 ₽   ╭───╮│
//   │  ● Форель       28%   115 200 ₽ ╭╯   ╰╮│
//   │  ● Карп         18%    74 400 ₽ │     ││
//   │  ● Амур         ...   ...     ╰╮   ╭╯│
//   │  ● Линь         ...   ...      ╰───╯ │
//   │  ● Вход на пруд ...   ...             │
//   └──────────────────────────────────────────┘
// ============================================================================

// ── Цветовые константы (единые с приложением) ──
const _ink = Color(0xFF14130F);
const _paper = Color(0xFFFBF6EC);
const _fill = Color(0xFFF3EEE4);
const _orange = Color(0xFFE8912B);
const _hairline2 = Color(0xFFE7E0D1);
const _muted = Color(0xFF8C8576);
const _muted2 = Color(0xFF9C9484);
const _white = Color(0xFFFFFFFF);

// ── Палитра сегментов (тёплая, как в примере) ──
const _segColors = <Color>[
  Color(0xFFE8912B), // оранжевый — Осётр (главный)
  Color(0xFF6B4226), // тёмно-коричневый — Форель
  Color(0xFF9C5A3C), // каштановый — Карп
  Color(0xFF4A7C59), // зелёный — Амур
  Color(0xFF8B7355), // охра — Линь
  Color(0xFFD4C4A8), // бежевый — Вход на пруд
];

class FinancePieChart extends StatelessWidget {
  final SalesDecomposition data;
  const FinancePieChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _paper,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _hairline2, width: 0.5),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Заголовок ──
          const Text(
            'Декомпозиция продаж',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _ink,
            ),
          ),
          const SizedBox(height: 16),

          // ── Легенда + Диаграмма ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Легенда (слева) ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < data.segments.length; i++) ...[
                      _LegendRow(
                        color: _segColors[i % _segColors.length],
                        label: data.segments[i].label,
                        pct: '${_fmtPct(data.pct(data.segments[i]))}%',
                        amount: '${_fmtAmount(data.segments[i].amount)} ₽',
                      ),
                      if (i < data.segments.length - 1)
                        const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // ── Кольцевая диаграмма (справа) ──
              SizedBox(
                width: 140,
                height: 140,
                child: CustomPaint(
                  painter: _DonutPainter(
                    segments: data.segments,
                    colors: _segColors,
                    total: data.total,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _fmtPct(double v) => v.toStringAsFixed(1).replaceAll('.', ',');

String _fmtAmount(double v) {
  final s = v.round().toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
    buf.write(s[i]);
  }
  return buf.toString();
}

// ─── Рисователь кольцевой диаграммы ─────────────────────────────────────────
class _DonutPainter extends CustomPainter {
  final List<SalesSegment> segments;
  final List<Color> colors;
  final double total;

  _DonutPainter({
    required this.segments,
    required this.colors,
    required this.total,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    const strokeWidth = 26.0;

    if (total <= 0 || segments.isEmpty) {
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = const Color(0xFFE1DCCF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth,
      );
      return;
    }

    double startAngle = -math.pi / 2;

    for (int i = 0; i < segments.length; i++) {
      final sweep = 2 * math.pi * (segments[i].amount / total);
      final color = colors[i % colors.length];

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.butt,
      );

      // Белый разделитель
      if (sweep > 0.02) {
        final sepAngle = startAngle + sweep;
        final inner = center + Offset(
          math.cos(sepAngle) * (radius - strokeWidth / 2 - 1),
          math.sin(sepAngle) * (radius - strokeWidth / 2 - 1),
        );
        final outer = center + Offset(
          math.cos(sepAngle) * (radius + strokeWidth / 2 + 1),
          math.sin(sepAngle) * (radius + strokeWidth / 2 + 1),
        );
        canvas.drawLine(
          inner,
          outer,
          Paint()
            ..color = _white
            ..strokeWidth = 2.5
            ..strokeCap = StrokeCap.round,
        );
      }

      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.segments != segments || old.total != total;
}

// ─── Строка легенды ─────────────────────────────────────────────────────────
class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final String pct;
  final String amount;

  const _LegendRow({
    required this.color,
    required this.label,
    required this.pct,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          // Цветная точка
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 8),
          // Название
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
          // Процент
          SizedBox(
            width: 42,
            child: Text(
              pct,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _muted,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Сумма
          SizedBox(
            width: 74,
            child: Text(
              amount,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
