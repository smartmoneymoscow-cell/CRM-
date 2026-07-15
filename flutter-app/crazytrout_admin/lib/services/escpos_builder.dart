import 'dart:convert';
import 'dart:typed_data';

import '../models/receipt.dart';

/// Строит байты ESC/POS для термопринтера.
///
/// Пробует UTF-8 (ESCP/POS UTF-8 режим) — поддерживается большинством
/// современных Bluetooth-принтеров. Если принтер не поддерживает UTF-8,
/// fallback на CP866 (классический ESC/POS).
Uint8List buildEscPos(Receipt r) {
  // Пробуем UTF-8 — современные BT-принтеры поддерживают
  final utf8Data = _buildUtf8(r);
  // Если не сработает, можно вернуть CP866:
  // return _buildCp866(r);
  return utf8Data;
}

/// UTF-8 вариант — для современных принтеров с поддержкой Unicode.
Uint8List _buildUtf8(Receipt r) {
  final raw = <int>[];

  // Инициализация
  raw.addAll([0x1B, 0x40]); // ESC @

  // Включаем UTF-8 режим (ESCP/POS)
  raw.addAll([0x1B, 0x74, 0x52]); // ESC t 82 (UTF-8 code page)

  // ─── Заголовок ───
  raw.addAll([0x1B, 0x61, 0x01]); // центрирование
  raw.addAll([0x1B, 0x45, 0x01]); // жирный
  raw.addAll([0x1B, 0x21, 0x30]); // двойной размер
  raw.addAll(utf8.encode('CRAZY TROUT ARENA'));
  raw.addAll([0x0A]);
  raw.addAll([0x1B, 0x21, 0x00]); // сброс размера
  raw.addAll([0x1B, 0x45, 0x00]); // сброс жирного

  // Название документа (54-ФЗ)
  raw.addAll(utf8.encode(r.fiscal ? 'КАССОВЫЙ ЧЕК (${r.operationType.label})' : 'ЧЕК (без ФН)'));
  raw.addAll([0x0A]);

  raw.addAll([0x1B, 0x61, 0x00]); // выравнивание влево

  // Разделитель
  raw.addAll(utf8.encode('--------------------------------'));
  raw.addAll([0x0A]);

  // ─── Реквизиты продавца (54-ФЗ) ───
  raw.addAll(utf8.encode('Продавец: ${r.sellerName}'));
  raw.addAll([0x0A]);
  raw.addAll(utf8.encode('ИНН: ${r.sellerINN}'));
  raw.addAll([0x0A]);
  raw.addAll(utf8.encode('Адрес: ${r.sellerAddress}'));
  raw.addAll([0x0A]);

  // ─── Дата, время, номер чека ───
  final dd = _two(r.date.day);
  final mm = _two(r.date.month);
  final hh = _two(r.date.hour);
  final mi = _two(r.date.minute);
  raw.addAll(utf8.encode('Дата: $dd.$mm.${r.date.year}  Время: $hh:$mi'));
  raw.addAll([0x0A]);
  raw.addAll(utf8.encode('Чек №${r.number}  Смена №${r.shiftNumber}'));
  raw.addAll([0x0A]);

  // Система налогообложения (54-ФЗ)
  raw.addAll(utf8.encode('СНО: ${r.taxSystem.label}'));
  raw.addAll([0x0A]);

  // Разделитель
  raw.addAll(utf8.encode('--------------------------------'));
  raw.addAll([0x0A]);

  // Клиент
  raw.addAll(utf8.encode('Клиент: ${r.clientLine}'));
  raw.addAll([0x0A]);
  raw.addAll(utf8.encode('Тариф ${r.tariffLabel}: ${r.tariffPrice} руб.'));
  raw.addAll([0x0A]);
  raw.addAll(utf8.encode('--------------------------------'));
  raw.addAll([0x0A]);

  // ─── Товары (54-ФЗ: наименование, количество, цена, сумма) ───
  for (final it in r.rows) {
    raw.addAll(utf8.encode(
      '${it.name} ${it.weight.toStringAsFixed(2)}кг × ${it.price.round()} = ${it.sum.round()} руб.',
    ));
    raw.addAll([0x0A]);
  }

  // ─── Итого ───
  raw.addAll(utf8.encode('--------------------------------'));
  raw.addAll([0x0A]);
  raw.addAll([0x1B, 0x45, 0x01]);
  raw.addAll([0x1B, 0x21, 0x10]);
  raw.addAll(utf8.encode('ИТОГО: ${r.total.round()} руб.'));
  raw.addAll([0x0A]);
  raw.addAll([0x1B, 0x21, 0x00]);
  raw.addAll([0x1B, 0x45, 0x00]);

  // НДС (54-ФЗ)
  if (r.ndsRate > 0) {
    raw.addAll(utf8.encode('НДС ${r.ndsRate.round()}%: ${r.ndsSum.round()} руб.'));
  } else {
    raw.addAll(utf8.encode('НДС не облагается'));
  }
  raw.addAll([0x0A]);

  // Форма оплаты
  raw.addAll(utf8.encode('Оплата: ${r.payment.label}'));
  raw.addAll([0x0A]);

  // Разделитель
  raw.addAll(utf8.encode('--------------------------------'));
  raw.addAll([0x0A]);

  // ─── Фискальные реквизиты (54-ФЗ) ───
  if (r.fiscal) {
    raw.addAll(utf8.encode('ККТ: ${r.kktNumber}'));
    raw.addAll([0x0A]);
    raw.addAll(utf8.encode('ФН: ${r.fnNumber}'));
    raw.addAll([0x0A]);
    raw.addAll(utf8.encode('ФД №: ${r.fdNumber}'));
    raw.addAll([0x0A]);
    raw.addAll(utf8.encode('ФПД: ${r.fpd}'));
    raw.addAll([0x0A]);
    raw.addAll(utf8.encode('Проверка: nalog.ru'));
    raw.addAll([0x0A]);
    if (r.buyerEmail != null && r.buyerEmail!.isNotEmpty) {
      raw.addAll(utf8.encode('Email покупателя: ${r.buyerEmail}'));
      raw.addAll([0x0A]);
    }
    if (r.sellerEmail != null && r.sellerEmail!.isNotEmpty) {
      raw.addAll(utf8.encode('Email продавца: ${r.sellerEmail}'));
      raw.addAll([0x0A]);
    }
  } else {
    raw.addAll(utf8.encode('Чек без фискального накопителя'));
    raw.addAll([0x0A]);
  }

  // Пробелы перед отрезом
  raw.addAll([0x0A, 0x0A, 0x0A]);

  // Команда отреза бумаги (GS V 1 — partial cut)
  raw.addAll([0x1D, 0x56, 0x01]);

  return Uint8List.fromList(raw);
}

String _two(int n) => n.toString().padLeft(2, '0');
