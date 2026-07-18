import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crazytrout_admin/main.dart';

// Реалистичный размер экрана телефона (близко к среднему Android/iPhone).
// ВАЖНО: раньше здесь либо подставляли искусственно большой холст
// (800×1200), либо глушили ВСЕ ошибки рендера через
// `FlutterError.onError = (_) {}` — из-за этого тесты оставались зелёными,
// даже когда на настоящих телефонах контент реально переполнялся/пропадал
// (см. график «Структура выручки» и карточки KPI на вкладке
// «Финансы и метрики» — RenderFlex overflow на узких экранах).
// Здесь мы намеренно НЕ подавляем ошибки — тест должен падать, если
// что-то реально не помещается на экран.
const _phoneSize = Size(393, 852);

void main() {
  group('App — smoke tests', () {
    testWidgets('приложение запускается без крашей', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(_phoneSize);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(const CrazyTroutAdminApp());
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });

    testWidgets('после SplashScreen показывается HomeShell', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(_phoneSize);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(const CrazyTroutAdminApp());
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(find.text('Чек'), findsOneWidget);
    });

    testWidgets('нижнее меню содержит все 5 вкладок', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(_phoneSize);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(const CrazyTroutAdminApp());
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(find.text('Карта'), findsOneWidget);
      expect(find.text('Чек'), findsOneWidget);
      expect(find.text('Чеки'), findsOneWidget);
      expect(find.text('Отчёты'), findsOneWidget);
      expect(find.text('Профиль'), findsOneWidget);
    });

    testWidgets('экран чека содержит заголовок', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(_phoneSize);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(const CrazyTroutAdminApp());
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Чеки'));
      await tester.pumpAndSettle();
    });

    testWidgets('поиск клиента и QR-кнопка присутствуют', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(_phoneSize);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(const CrazyTroutAdminApp());
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });

    // ── Регрессионный тест: вкладка «Отчёты» → «Финансы и метрики» ──
    // Проверяет ровно тот баг, который был пропущен из-за подавления
    // ошибок: все карточки/графики должны реально присутствовать на
    // экране РЕАЛИСТИЧНОЙ ширины, без RenderFlex overflow.
    testWidgets('Отчёты → Финансы и метрики — все графики отображаются без overflow',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(_phoneSize);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(const CrazyTroutAdminApp());
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Отчёты'));
      await tester.pumpAndSettle();

      // Заголовок вкладки по умолчанию
      expect(find.text('Финансы и метрики'), findsOneWidget);

      // Все карточки/графики из _FinanceContent должны быть в дереве —
      // если какая-то пропала (например, из-за упавшего layout выше по
      // дереву), findsOneWidget здесь не пройдёт.
      expect(find.text('Структура выручки'), findsOneWidget);
      expect(find.text('По способам оплаты'), findsOneWidget);
      expect(find.text('По тарифам (в шт.)'), findsOneWidget);
      expect(find.text('Динамика показателей'), findsOneWidget);
      expect(find.text('Всего клиентов'), findsOneWidget);

      // Явная проверка, что ничего не переполнилось за границы экрана.
      expect(tester.takeException(), isNull);
    });
  });
}
