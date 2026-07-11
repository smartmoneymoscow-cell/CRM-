import 'dart:convert';
import 'dart:typed_data';

import '../models/receipt.dart';

/// Строит байты ESC/POS для термопринтера — порт функции buildEscPos()
/// из веб-версии на Dart.
Uint8List buildEscPos(Receipt r) {
  final lines = <String>[];
  lines.add('CRAZY TROUT ARENA');
  lines.add('Chek No ${r.number}');
  lines.add('--------------------------------');
  for (final it in r.rows) {
    lines.add('${it.name} ${it.weight.toStringAsFixed(2)}kg x ${it.price.round()}');
    lines.add('  = ${it.sum.round()} RUB');
  }
  lines.add('--------------------------------');
  lines.add('ITOGO: ${r.total.round()} RUB');
  lines.add('OPLATA: ${r.payment.label}');
  lines.add('');
  lines.add('');

  final text = lines.join('\n');
  final body = utf8.encode(text);

  final init = <int>[0x1B, 0x40]; // ESC @ — сброс принтера
  final feed = <int>[0x0A, 0x0A, 0x0A];

  return Uint8List.fromList([...init, ...body, ...feed]);
}
