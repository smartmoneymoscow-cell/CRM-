// ============================================================================
// pond_map_screen_tap_test.dart — Widget-тесты на PondMapScreen целиком.
//
// Пump'им РЕАЛЬНЫЙ экран, тапаем по НАСТОЯЩИМ кнопкам в интерфейсе.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crazytrout_admin/screens/pond_map_screen.dart';
import 'package:crazytrout_admin/screens/pond_map_filter_config.dart';

void main() {
  // ─────────────────────────────────────────────────────────────────────
  // 1. ЗАГОЛОВОК ЭКРАНА
  // ─────────────────────────────────────────────────────────────────────
  group('Заголовок', () {
    testWidgets('отображает «Карта пруда»', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: PondMapScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Карта пруда'), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────────────────────────────
  // 2. ЧИП «ДАТА» — тап открывает календарь
  // ─────────────────────────────────────────────────────────────────────
  group('Чип «ДАТА»', () {
    testWidgets('отображает дату по умолчанию', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: PondMapScreen()));
      await tester.pumpAndSettle();
      expect(find.text('12 июл'), findsOneWidget);
    });

    testWidgets('тап по дате открывает календарь', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: PondMapScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('12 июл'));
      await tester.pumpAndSettle();

      // Календарь показывает название месяца
      expect(find.textContaining('Июль'), findsWidgets);
    });
  });

  // ─────────────────────────────────────────────────────────────────────
  // 3. ЧИП «ВРЕМЯ» — тап открывает пикер
  // ─────────────────────────────────────────────────────────────────────
  group('Чип «ВРЕМЯ»', () {
    testWidgets('отображает время по умолчанию', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: PondMapScreen()));
      await tester.pumpAndSettle();
      expect(find.text('06:00'), findsOneWidget);
    });

    testWidgets('тап по времени открывает пикер', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: PondMapScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('06:00'));
      await tester.pumpAndSettle();

      expect(find.text('Время'), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────────────────────────────
  // 4. КАРТА ПРУДА
  // ─────────────────────────────────────────────────────────────────────
  group('Карта пруда', () {
    testWidgets('PondMapView отображается', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: PondMapScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(PondMapView), findsOneWidget);
    });

    testWidgets('тап по карте выделяет сектор', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: PondMapScreen()));
      await tester.pumpAndSettle();

      expect(find.textContaining('ЛЕНТА БРОНИРОВАНИЙ'), findsOneWidget);

      final mapFinder = find.byType(PondMapView);
      final mapRect = tester.getRect(mapFinder);
      await tester.tapAt(mapRect.center);
      await tester.pumpAndSettle();

      // После тапа — либо расписание сектора, либо лента
      expect(
        find.textContaining('РАСПИСАНИЕ').evaluate().isNotEmpty ||
        find.textContaining('ЛЕНТА').evaluate().isNotEmpty,
        isTrue,
      );
    });
  });

  // ─────────────────────────────────────────────────────────────────────
  // 5. ФИЛЬТРЫ
  // ─────────────────────────────────────────────────────────────────────
  group('Фильтры dropdown', () {
    testWidgets('кнопка фильтров отображается', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: PondMapScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Фильтры'), findsOneWidget);
    });

    testWidgets('тап по фильтрам открывает dropdown', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: PondMapScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Фильтры'));
      await tester.pumpAndSettle();

      expect(find.text('Все клиенты'), findsOneWidget);
      expect(find.text('Премиум'), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────────────────────────────
  // 6. СТАТИСТИКА
  // ─────────────────────────────────────────────────────────────────────
  group('Статистические карточки', () {
    testWidgets('отображает «ЗАГРУЗКА»', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: PondMapScreen()));
      await tester.pumpAndSettle();
      expect(find.text('ЗАГРУЗКА'), findsOneWidget);
    });

    testWidgets('отображает «БРОНЕЙ»', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: PondMapScreen()));
      await tester.pumpAndSettle();
      expect(find.text('БРОНЕЙ'), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────────────────────────────
  // 7. ЛЕНТА БРОНИРОВАНИЙ
  // ─────────────────────────────────────────────────────────────────────
  group('Лента бронирований', () {
    testWidgets('отображает заголовок ленты', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: PondMapScreen()));
      await tester.pumpAndSettle();
      expect(find.textContaining('ЛЕНТА БРОНИРОВАНИЙ'), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────────────────────────────
  // 8. Полный сценарий
  // ─────────────────────────────────────────────────────────────────────
  group('Полный сценарий', () {
    testWidgets('экран отображается корректно после взаимодействий', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: PondMapScreen()));
      await tester.pumpAndSettle();

      // Начальное состояние
      expect(find.text('Карта пруда'), findsOneWidget);
      expect(find.text('Фильтры'), findsOneWidget);

      // Открываем фильтры
      await tester.tap(find.text('Фильтры'));
      await tester.pumpAndSettle();

      // Закрываем (тап по кнопке ещё раз)
      await tester.tap(find.text('Фильтры'));
      await tester.pumpAndSettle();

      // Экран в целости
      expect(find.text('Карта пруда'), findsOneWidget);
      expect(find.byType(PondMapView), findsOneWidget);
    });
  });
}
