import 'package:flutter/material.dart';

// ─── Фильтры периода ────────────────────────────────────────────────────────
enum PeriodFilter { today, week, month, quarter, all }

extension PeriodFilterLabel on PeriodFilter {
  String get label => switch (this) {
        PeriodFilter.today => 'Сегодня',
        PeriodFilter.week => 'Неделя',
        PeriodFilter.month => 'Месяц',
        PeriodFilter.quarter => 'Квартал',
        PeriodFilter.all => 'Все вр.',
      };
}

DateTimeRange? periodToDateRange(PeriodFilter? period) {
  if (period == null || period == PeriodFilter.all) return null;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final start = switch (period) {
    PeriodFilter.today => today,
    PeriodFilter.week => today.subtract(const Duration(days: 7)),
    PeriodFilter.month => today.subtract(const Duration(days: 30)),
    PeriodFilter.quarter => today.subtract(const Duration(days: 90)),
    PeriodFilter.all => DateTime(0),
  };
  return DateTimeRange(start: start, end: today);
}

// ─── Фильтр типа чека ──────────────────────────────────────────────────────
enum TypeFilter { fiscal, nonfiscal }

extension TypeFilterLabel on TypeFilter {
  String get label => this == TypeFilter.fiscal ? 'С ФН' : 'Без ФН';
}
