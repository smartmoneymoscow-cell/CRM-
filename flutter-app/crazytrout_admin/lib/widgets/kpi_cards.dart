import 'package:flutter/material.dart';

// ============================================================================
// KpiCards — карточки ключевых метрик для экрана «Финансы»
//
//   ┌─────────────────────┬─────────────────────┐
//   │ 🧾 Средний чек      │ 📊 LT / LTV         │
//   │    3 280 ₽          │    4.7 / 18 760 ₽   │
//   │    126 оплат         │    среднее на клиента│
//   ├─────────────────────┼─────────────────────┤
//   │ 👥 Всего клиентов   │ ⭐ Оценка сервиса    │
//   │    847              │    4.6               │
//   │    73% возвращаются │    128 отзывов       │
//   ├─────────────────────┴─────────────────────┤
//   │ 🐟 Средний улов на клиента                │
//   │    3,6 кг  ·  +9,7% к прошлому периоду    │
//   └───────────────────────────────────────────┘
// ============================================================================

const _ink = Color(0xFF14130F);
const _paper = Color(0xFFFBF6EC);
const _fill = Color(0xFFF3EEE4);
const _orange = Color(0xFFE8912B);
const _hairline2 = Color(0xFFE7E0D1);
const _muted = Color(0xFF8C8576);
const _muted2 = Color(0xFF9C9484);
const _green = Color(0xFF4F9D75);
const _greenLight = Color(0xFFE8F5EE);

class KpiCards extends StatelessWidget {
  const KpiCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Ряд 1: Средний чек + LT/LTV ──
        Row(
          children: [
            Expanded(
              child: _KpiCard(
                icon: Icons.receipt_long_outlined,
                iconColor: _orange,
                title: 'Средний чек',
                value: '3 280 ₽',
                subtitle: '126 оплат',
                delta: '+4,3%',
                deltaPositive: true,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _KpiCard(
                icon: Icons.calendar_month_outlined,
                iconColor: const Color(0xFF4A7C59),
                title: 'LT / LTV',
                value: '4.7 / 18 760 ₽',
                subtitle: 'среднее на клиента',
                delta: '+18,3%',
                deltaPositive: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // ── Ряд 2: Всего клиентов + Оценка сервиса ──
        Row(
          children: [
            Expanded(
              child: _KpiCard(
                icon: Icons.people_outline,
                iconColor: const Color(0xFF6B4226),
                title: 'Всего клиентов',
                value: '847',
                subtitle: '73% возвращаются',
                delta: '+12',
                deltaPositive: true,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _KpiCard(
                icon: Icons.star_rounded,
                iconColor: const Color(0xFFE8912B),
                title: 'Оценка сервиса',
                value: '4.6',
                subtitle: '128 отзывов',
                delta: null,
                deltaPositive: true,
                stars: 4.6,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // ── Ряд 3: Средний улов (на всю ширину) ──
        _KpiCard(
          icon: Icons.set_meal_outlined,
          iconColor: const Color(0xFF4A7C59),
          title: 'Средний улов на клиента',
          value: '3,6 кг',
          subtitle: null,
          delta: '+9,7%',
          deltaPositive: true,
          wide: true,
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String? subtitle;
  final String? delta;
  final bool deltaPositive;
  final double? stars;
  final bool wide;

  const _KpiCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    this.subtitle,
    this.delta,
    this.deltaPositive = true,
    this.stars,
    this.wide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _paper,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _hairline2, width: 0.5),
      ),
      child: wide ? _buildWide() : _buildCompact(),
    );
  }

  Widget _buildCompact() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Иконка + заголовок
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _muted,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Значение
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: _ink,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 6),

        // Подпись + дельта
        Row(
          children: [
            if (subtitle != null)
              Expanded(
                child: Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: _muted2,
                  ),
                ),
              ),
            if (delta != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: deltaPositive ? _greenLight : const Color(0xFFFDEAEA),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  delta!,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: deltaPositive ? _green : const Color(0xFFC0392B),
                  ),
                ),
              ),
          ],
        ),

        // Звёзды (если есть)
        if (stars != null) ...[
          const SizedBox(height: 8),
          _StarRating(rating: stars!),
        ],
      ],
    );
  }

  Widget _buildWide() {
    return Row(
      children: [
        // Иконка
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 22, color: iconColor),
        ),
        const SizedBox(width: 14),

        // Текст
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _muted,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: _ink,
                      letterSpacing: -0.3,
                    ),
                  ),
                  if (delta != null) ...[
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: deltaPositive ? _greenLight : const Color(0xFFFDEAEA),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        delta!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: deltaPositive ? _green : const Color(0xFFC0392B),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'к прошлому периоду',
                      style: TextStyle(
                        fontSize: 11,
                        color: _muted2,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Виджет звёздного рейтинга ──────────────────────────────────────────────
class _StarRating extends StatelessWidget {
  final double rating;
  const _StarRating({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        final filled = rating - i;
        return Padding(
          padding: const EdgeInsets.only(right: 2),
          child: Icon(
            filled >= 0.75
                ? Icons.star_rounded
                : filled >= 0.25
                    ? Icons.star_half_rounded
                    : Icons.star_border_rounded,
            size: 18,
            color: filled > 0 ? _orange : _muted2,
          ),
        );
      }),
    );
  }
}
