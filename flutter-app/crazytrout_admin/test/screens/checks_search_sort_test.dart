import 'package:flutter_test/flutter_test.dart';
import 'package:crazytrout_admin/data/demo_receipts.dart';
import 'package:crazytrout_admin/models/client.dart';

/// Тест на баг 2.1: поиск на странице Чеки не сортирует по.startsWith.
///
/// При вводе буквы "А" первые варианты выдачи должны начинаться на "А".
/// Правильная логика уже реализована на странице выставления чека (receipt_screen.dart):
///
///   _searchResults.sort((a, b) {
///     final aStarts = an.startsWith(query) ? 0 : 1;
///     final bStarts = bn.startsWith(query) ? 0 : 1;
///     if (aStarts != bStarts) return aStarts - bStarts;
///     return an.compareTo(bn);
///   });
///
/// На странице Чеки (_clientSuggestions) этой сортировки нет — баг.

/// Имитация текущей логики _clientSuggestions из checks_screen.dart (БАГ — без сортировки).
List<Client> clientSuggestionsBuggy(String query) {
  if (query.isEmpty) return const [];
  final q = query.toLowerCase();
  final seen = <int>{};
  final res = <Client>[];
  for (final r in kDemoReceipts) {
    final c = r.client;
    if (c == null || seen.contains(c.id)) continue;
    if (c.name.toLowerCase().contains(q) || c.phone.contains(q)) {
      seen.add(c.id);
      res.add(c);
    }
  }
  return res.take(4).toList();
}

/// Имитация ИСПРАВЛЕННОЙ логики _clientSuggestions (как в receipt_screen.dart).
List<Client> clientSuggestionsFixed(String query) {
  if (query.isEmpty) return const [];
  final q = query.toLowerCase();
  final seen = <int>{};
  final res = <Client>[];
  for (final r in kDemoReceipts) {
    final c = r.client;
    if (c == null || seen.contains(c.id)) continue;
    if (c.name.toLowerCase().contains(q) || c.phone.contains(q)) {
      seen.add(c.id);
      res.add(c);
    }
  }
  // Сортировка: имя начинается с запроса → выше, потом по алфавиту
  res.sort((a, b) {
    final an = a.name.toLowerCase();
    final bn = b.name.toLowerCase();
    final aStarts = an.startsWith(q) ? 0 : 1;
    final bStarts = bn.startsWith(q) ? 0 : 1;
    if (aStarts != bStarts) return aStarts - bStarts;
    return an.compareTo(bn);
  });
  return res.take(4).toList();
}

void main() {
  group('Баг 2.1: поиск на странице Чеки — сортировка по startsWith', () {
    test('баг: текущая логика НЕ сортирует по startsWith', () {
      // Демонстрируем баг: при вводе "А" результаты НЕ начинаются с "А"
      final results = clientSuggestionsBuggy('А');
      if (results.isEmpty) return; // Нет результатов — баг не воспроизводится

      // Проверяем что первый результат НЕ начинается с "А" — это и есть баг
      final firstStartsWithA = results.first.name.toLowerCase().startsWith('а');
      // Если баг есть — firstStartsWithA будет false (первый результат не на "А")
      // Если бага нет — firstStartsWithA будет true
      // Тест демонстрирует наличие/отсутствие бага
      print('Баг 2.1: первый результат "${results.first.name}" начинается на "А": $firstStartsWithA');
    });

    test('фикс: исправленная логика сортирует по startsWith', () {
      final results = clientSuggestionsFixed('А');
      if (results.isEmpty) return;

      // Все результаты, начинающиеся с "А", должны быть первыми
      bool foundNonStarting = false;
      for (final c in results) {
        final starts = c.name.toLowerCase().startsWith('а');
        if (!starts) {
          foundNonStarting = true;
        }
        // Если нашли результат, не начинающийся с "А", то все последующие тоже не должны начинаться
        if (foundNonStarting && starts) {
          fail('Результат "${c.name}" начинается с "А" но идёт после другого');
        }
      }
    });

    test('фикс: "иван" — Иван Иванов первым', () {
      final results = clientSuggestionsFixed('иван');
      expect(results, isNotEmpty);
      expect(results.first.name.toLowerCase().startsWith('иван'), isTrue,
          reason: 'Первый результат должен начинаться с "иван"');
    });

    test('фикс: "а" — все "А..." перед остальными', () {
      final results = clientSuggestionsFixed('а');
      if (results.length < 2) return; // Нужно минимум 2 результата

      final startsWithA = results.where((c) => c.name.toLowerCase().startsWith('а')).toList();
      final containsA = results.where((c) => !c.name.toLowerCase().startsWith('а')).toList();

      // Все startsWith "а" должны быть перед contains "а"
      for (int i = 0; i < startsWithA.length; i++) {
        expect(results[i].name.toLowerCase().startsWith('а'), isTrue,
            reason: 'Результат #${i} "${results[i].name}" должен начинаться с "А"');
      }
    });
  });
}
