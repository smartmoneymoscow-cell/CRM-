// ============================================================================
// report_finance_order_test.dart — Тесты: порядок графиков + KPI + фильтры
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crazytrout_admin/screens/report_screen.dart';
import 'package:crazytrout_admin/widgets/finance_dashboard_card.dart';
import 'package:crazytrout_admin/widgets/finance_pie_chart.dart';
import 'package:crazytrout_admin/widgets/kpi_cards.dart';
import 'package:crazytrout_admin/widgets/payment_tariff_card.dart';
import 'package:crazytrout_admin/widgets/revenue_dynamics_chart.dart';

const _phoneSize = Size(393, 852);
const _tabletSize = Size(800, 1280);

Future<void> _goToReports(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: Scaffold(body: ReportScreen())));
  await tester.pumpAndSettle();
}

/// Открывает dropdown фильтра и выбирает пункт [label]
Future<void> _selectFilter(WidgetTester tester, String label) async {
  // Находим контейнер с текстом "Период" или текущим значением фильтра
  final filterText = find.text('Период');
  expect(filterText, findsWidgets, reason: 'Текст "Период" не найден');
  // Тапаем по GestureDetector над текстом
  final gesture = find.ancestor(
    of: filterText,
    matching: find.byType(GestureDetector),
  );
  await tester.tap(gesture.first);
  await tester.pumpAndSettle();

  // Тапаем по нужному пункту в overlay
  final option = find.text(label).last;
  await tester.tap(option);
  await tester.pumpAndSettle();
}

void main() {
  group('БАГ 3.1 — Порядок и наложение графиков', () {
    testWidgets('RevenueDynamicsChart — последний (5-й) виджет',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(_phoneSize);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await _goToReports(tester);

      final d = tester.getRect(find.byType(FinanceDashboardCard));
      final pie = tester.getRect(find.byType(FinancePieChart));
      final kpi = tester.getRect(find.byType(KpiCards));
      final pay = tester.getRect(find.byType(PaymentTariffCard));
      final dyn = tester.getRect(find.byType(RevenueDynamicsChart));

      expect(d.top, lessThan(pie.top));
      expect(pie.top, lessThan(kpi.top));
      expect(kpi.top, lessThan(pay.top));
      expect(pay.top, lessThan(dyn.top));
    });

    testWidgets('Нет наложения Dashboard ↔ Dynamics (телефон)',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(_phoneSize);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await _goToReports(tester);
      expect(
        tester.getRect(find.byType(FinanceDashboardCard))
            .overlaps(tester.getRect(find.byType(RevenueDynamicsChart))),
        isFalse,
      );
    });

    testWidgets('Нет наложения на планшете',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(_tabletSize);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await _goToReports(tester);
      expect(
        tester.getRect(find.byType(FinanceDashboardCard))
            .overlaps(tester.getRect(find.byType(RevenueDynamicsChart))),
        isFalse,
      );
    });

    testWidgets('Все 5 блоков присутствуют',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(_phoneSize);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await _goToReports(tester);
      expect(find.byType(FinanceDashboardCard), findsOneWidget);
      expect(find.byType(FinancePieChart), findsOneWidget);
      expect(find.byType(KpiCards), findsOneWidget);
      expect(find.byType(PaymentTariffCard), findsOneWidget);
      expect(find.byType(RevenueDynamicsChart), findsOneWidget);
    });

    testWidgets('DynamicsChart видим после скролла',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(_phoneSize);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await _goToReports(tester);
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -2000));
      await tester.pumpAndSettle();
      expect(tester.getRect(find.byType(RevenueDynamicsChart)).top, greaterThanOrEqualTo(0));
    });
  });

  group('KpiCards — все 5 карточек', () {
    testWidgets('Все 5 KPI-заголовков видны',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(_phoneSize);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await _goToReports(tester);
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -1500));
      await tester.pumpAndSettle();

      expect(find.text('Средний чек'), findsOneWidget);
      expect(find.text('LT / LTV'), findsOneWidget);
      expect(find.text('Всего клиентов'), findsOneWidget);
      expect(find.text('Средний улов на клиента'), findsOneWidget);
      expect(find.text('Оценка сервиса'), findsOneWidget);
    });

    testWidgets('KpiCards высота > 100px (все карточки)',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(_phoneSize);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await _goToReports(tester);
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -1500));
      await tester.pumpAndSettle();
      expect(tester.getRect(find.byType(KpiCards)).height, greaterThan(100));
    });
  });

  group('Фильтры — наложение при разных периодах', () {
    testWidgets('Нет наложения при фильтре "Сегодня"',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(_phoneSize);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await _goToReports(tester);
      await _selectFilter(tester, 'Сегодня');

      final d = tester.getRect(find.byType(FinanceDashboardCard));
      final r = tester.getRect(find.byType(RevenueDynamicsChart));
      expect(d.overlaps(r), isFalse, reason: 'С "Сегодня" нет наложения');
    });

    testWidgets('Нет наложения при фильтре "За неделю"',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(_phoneSize);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await _goToReports(tester);
      await _selectFilter(tester, 'За неделю');

      final d = tester.getRect(find.byType(FinanceDashboardCard));
      final r = tester.getRect(find.byType(RevenueDynamicsChart));
      expect(d.overlaps(r), isFalse, reason: 'С "За неделю" нет наложения');
    });

    testWidgets('Нет наложения при фильтре "За месяц"',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(_phoneSize);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await _goToReports(tester);
      await _selectFilter(tester, 'За месяц');

      final d = tester.getRect(find.byType(FinanceDashboardCard));
      final r = tester.getRect(find.byType(RevenueDynamicsChart));
      expect(d.overlaps(r), isFalse, reason: 'С "За месяц" нет наложения');
    });

    testWidgets('Нет наложения при фильтре "За квартал"',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(_phoneSize);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await _goToReports(tester);
      await _selectFilter(tester, 'За квартал');

      final d = tester.getRect(find.byType(FinanceDashboardCard));
      final r = tester.getRect(find.byType(RevenueDynamicsChart));
      expect(d.overlaps(r), isFalse, reason: 'С "За квартал" нет наложения');
    });

    testWidgets('Нет наложения при фильтре "За все время"',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(_phoneSize);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await _goToReports(tester);
      await _selectFilter(tester, 'За все время');

      final d = tester.getRect(find.byType(FinanceDashboardCard));
      final r = tester.getRect(find.byType(RevenueDynamicsChart));
      expect(d.overlaps(r), isFalse, reason: 'С "За все время" нет наложения');
    });
  });
}
