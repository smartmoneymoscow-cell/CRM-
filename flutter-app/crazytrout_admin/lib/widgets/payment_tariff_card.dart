import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../data/payment_tariff_stats.dart';
import '../utils/format.dart';

// ============================================================================
// PaymentTariffCard — две диаграммы на одной строке:
//   Слева: столбчатая — выручка по способам оплаты
//   Справа: кольцевая — выручка по тарифам
//
//   ┌─────────────────────┬────────────────────┐
//   │ По способам оплаты  │  По тарифам        │
//   │                     │                    │
//   │  Картой    ████████ │    ╭───────╮       │
//   │  Наличными ████     │   ╱ Станд. ╲      │
//   │  Счёт      ██       │  │  Гостев.  │     │
//   │                     │   ╲ Пенсион.╱      │
//   │                     │    ╰───────╯       │
//   └─────────────────────┴────────────────────┘
// ============================================================================

// ── Цвета приложения ──
const _ink = Color(0xFF14130F);
const _paper = Color(0xFFFBF6EC);
const _fill = Color(0xFFF3EEE4);
const _orange = Color(0xFFE8912B);
const _hairline2 = Color(0xFFE7E0D1);
const _muted = Color(0xFF8C8576);
const _muted2 = Color(0xFF9C9484);

// ── Палитра столбцов (оплата) ──
const _barColors = <Color>[
  Color(0xFFE8912B), // оранжевый — Картой
  Color(0xFF4A7C59), // зелёный — Наличными
  Color(0xFF8B6F47), // золотой — Счёт заведения
];

// Градиенты для столбцов
const _barGradients = <List<Color>>[
  [Color(0xFFE8912B), Color(0xFFF2A84D)],
  [Color(0xFF4A7C59), Color(0xFF5FA87A)],
  [Color(0xFF8B6F47), Color(0xFFA88960)],
];

// ── Палитра сегментов (тарифы) ──
const _tarColors = <Color>[
  Color(0xFFE8912B), // оранжевый — Стандарт
  Color(0xFFD4C4A8), // бежевый — Гостевой
  Color(0xFFB8B0A2), // серый — Пенсионер
];

// Градиенты для сегментов тарифов
const _tarGradients = <List<Color>>[
  [Color(0xFFE8912B), Color(0xFFF2A84D)],
  [Color(0xFFD4C4A8), Color(0xFFE0D4BA)],
  [Color(0xFFB8B0A2), Color(0xFFC8C0B4)],
];

class PaymentTariffCard extends StatelessWidget {
  final PaymentTariffStats stats;
  const PaymentTariffCard({super.key, required this.stats});

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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Слева: столбцы (оплата) ──
          Expanded(
            child: _PaymentBars(payments: stats.payments),
          ),

          const SizedBox(width: 14),

          // ── Справа: кольцо (тарифы) ──
          Expanded(
            child: _TariffDonut(tariffs: stats.tariffs),
          ),
        ],
      ),
    );
  }
}

// ─── Столбчатая диаграмма способов оплаты ───────────────────────────────────
class _PaymentBars extends StatelessWidget {
  final List<PaymentBreakdown> payments;
  const _PaymentBars({required this.payments});

  @override
  Widget build(BuildContext context) {
    if (payments.isEmpty) return const SizedBox.shrink();

    final maxAmount = payments.map((e) => e.amount).reduce(math.max);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'По способам оплаты',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
        ),
        const SizedBox(height: 14),
        for (int i = 0; i < payments.length; i++) ...[
          _BarRow(
            label: payments[i].label,
            amount: payments[i].amount,
            fraction: maxAmount > 0 ? payments[i].amount / maxAmount : 0,
            color: _barColors[i % _barColors.length],
            gradient: _barGradients[i % _barGradients.length],
          ),
          if (i < payments.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _BarRow extends StatelessWidget {
  final String label;
  final double amount;
  final double fraction; // 0..1
  final Color color;
  final List<Color> gradient;

  const _BarRow({
    required this.label,
    required this.amount,
    required this.fraction,
    required this.color,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Название + сумма
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: _ink,
              ),
            ),
            Text(
              money(amount),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _ink,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Столбец
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: SizedBox(
            height: 10,
            child: LayoutBuilder(
              builder: (context, constraints) => Stack(
                children: [
                  Container(color: _fill),
                  Container(
                    width: constraints.maxWidth * fraction.clamp(0.0, 1.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      gradient: LinearGradient(colors: gradient),
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

// ─── Кольцевая диаграмма тарифов ────────────────────────────────────────────
class _TariffDonut extends StatelessWidget {
  final List<TariffBreakdown> tariffs;
  const _TariffDonut({required this.tariffs});

  @override
  Widget build(BuildContext context) {
    final total = tariffs.fold<double>(0, (s, e) => s + e.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'По тарифам',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: SizedBox(
            width: 110,
            height: 110,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(110, 110),
                  painter: _DonutPainter(
                    tariffs: tariffs,
                    colors: _tarColors,
                    total: total,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      money(total),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: _ink,
                      ),
                    ),
                    const Text(
                      'всего',
                      style: TextStyle(
                        fontSize: 9,
                        color: _muted2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Легенда
        for (int i = 0; i < tariffs.length; i++) ...[
          _LegendDot(
            color: _tarColors[i % _tarColors.length],
            label: tariffs[i].label,
            pct: total > 0
                ? '${(tariffs[i].amount / total * 100).toStringAsFixed(0).replaceAll('.', ',')}%'
                : '0%',
            count: tariffs[i].count,
          ),
          if (i < tariffs.length - 1) const SizedBox(height: 6),
        ],
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<TariffBreakdown> tariffs;
  final List<Color> colors;
  final double total;

  _DonutPainter({
    required this.tariffs,
    required this.colors,
    required this.total,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    const strokeWidth = 20.0;

    if (total <= 0 || tariffs.isEmpty) {
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

    for (int i = 0; i < tariffs.length; i++) {
      if (tariffs[i].amount <= 0) continue;
      final sweep = 2 * math.pi * (tariffs[i].amount / total);
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
      if (sweep > 0.03) {
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
            ..color = const Color(0xFFFBF6EC)
            ..strokeWidth = 2.5
            ..strokeCap = StrokeCap.round,
        );
      }

      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.tariffs != tariffs || old.total != total;
}

// ─── Легенда с точкой ──────────────────────────────────────────────────────
class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final String pct;
  final int count;

  const _LegendDot({
    required this.color,
    required this.label,
    required this.pct,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
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
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: _ink,
            ),
          ),
        ),
        Text(
          pct,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _muted,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '($count)',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: _muted2,
          ),
        ),
      ],
    );
  }
}
