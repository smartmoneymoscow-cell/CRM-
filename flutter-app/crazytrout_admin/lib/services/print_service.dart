import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/receipt.dart';
import 'escpos_builder.dart';

/// Стандартный сервис Bluetooth Serial Port Profile для термопринтеров чеков
/// (используется большинством ESC/POS-принтеров).
final Guid _printServiceUuid = Guid('000018f0-0000-1000-8000-00805f9b34fb');
final Guid _printCharUuid = Guid('00002af1-0000-1000-8000-00805f9b34fb');

class PrintService {
  /// Аналог кнопки «Печать через AirPrint»: рендерит чек в PDF и показывает
  /// системный диалог печати. На iOS это открывает AirPrint, на Android —
  /// системную службу печати.
  static Future<void> printViaSystemDialog(Receipt r) async {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Text(
                'CRAZY TROUT ARENA',
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Center(
              child: pw.Text('Чек № ${r.number} · ${_fmtDate(r.date)}', style: const pw.TextStyle(fontSize: 9)),
            ),
            pw.Divider(),
            pw.Text('Клиент: ${r.clientLine}', style: const pw.TextStyle(fontSize: 10)),
            pw.Text('Тариф · ${r.tariffLabel}: ${r.tariffPrice} ₽', style: const pw.TextStyle(fontSize: 10)),
            pw.Divider(),
            ...r.rows.map(
              (it) => pw.Text(
                '${it.name} ${it.weight.toStringAsFixed(2)}кг × ${it.price.round()} = ${it.sum.round()} ₽',
                style: const pw.TextStyle(fontSize: 10),
              ),
            ),
            pw.Divider(),
            pw.Text(
              'ИТОГО: ${r.total.round()} ₽',
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text('Оплата: ${r.payment.label}', style: const pw.TextStyle(fontSize: 10)),
            pw.Text(
              r.fiscal ? 'Фискальный чек ${r.fiscalDoc ?? ""}' : 'Без ФН',
              style: const pw.TextStyle(fontSize: 10),
            ),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => doc.save(),
      name: 'Чек №${r.number}',
    );
  }

  /// Аналог кнопки «Найти принтер и распечатать»: сканирует ближайшие
  /// Bluetooth-устройства, даёт пользователю выбрать принтер из списка
  /// (диалог строим сами — Flutter не показывает системный пикер, как это
  /// делает Web Bluetooth в Chrome) и отправляет байты чека через ESC/POS.
  static Future<void> printViaBluetooth(BuildContext context, Receipt r) async {
    if (await FlutterBluePlus.isSupported == false) {
      _toast(context, 'Bluetooth не поддерживается на этом устройстве');
      return;
    }

    await FlutterBluePlus.adapterState.firstWhere((s) => s == BluetoothAdapterState.on).timeout(
          const Duration(seconds: 5),
          onTimeout: () => BluetoothAdapterState.unknown,
        );

    final found = <ScanResult>[];
    late StreamSubscription<List<ScanResult>> sub;
    final completer = Completer<ScanResult?>();

    sub = FlutterBluePlus.scanResults.listen((results) {
      found
        ..clear()
        ..addAll(results.where((r) => r.device.platformName.isNotEmpty));
    });

    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));

    if (!context.mounted) return;

    final chosen = await showModalBottomSheet<ScanResult>(
      context: context,
      builder: (ctx) {
        return StreamBuilder<List<ScanResult>>(
          stream: FlutterBluePlus.scanResults,
          initialData: found,
          builder: (ctx, snapshot) {
            final devices = (snapshot.data ?? []).where((d) => d.device.platformName.isNotEmpty).toList();
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Выберите принтер', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  if (devices.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('Поиск устройств рядом…'),
                    ),
                  ...devices.map(
                    (d) => ListTile(
                      title: Text(d.device.platformName),
                      subtitle: Text(d.device.remoteId.toString()),
                      onTap: () => Navigator.of(ctx).pop(d),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );

    await FlutterBluePlus.stopScan();
    await sub.cancel();
    if (!completer.isCompleted) completer.complete(chosen);

    if (chosen == null) {
      if (context.mounted) _toast(context, 'Принтер не выбран');
      return;
    }

    if (context.mounted) _toast(context, 'Подключение к «${chosen.device.platformName}»…');

    try {
      final device = chosen.device;
      await device.connect(timeout: const Duration(seconds: 8));
      final services = await device.discoverServices();

      final service = services.firstWhere(
        (s) => s.uuid == _printServiceUuid,
        orElse: () => services.first,
      );
      final char = service.characteristics.firstWhere(
        (c) => c.uuid == _printCharUuid,
        orElse: () => service.characteristics.first,
      );

      final data = buildEscPos(r);
      const chunkSize = 20;
      for (var i = 0; i < data.length; i += chunkSize) {
        final chunk = data.sublist(i, i + chunkSize > data.length ? data.length : i + chunkSize);
        await char.write(chunk, withoutResponse: char.properties.writeWithoutResponse);
        await Future.delayed(const Duration(milliseconds: 20));
      }

      if (context.mounted) _toast(context, 'Чек отправлен на принтер');
      await device.disconnect();
    } catch (e) {
      if (context.mounted) _toast(context, 'Ошибка печати: $e');
    }
  }

  static void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));
  }

  static String _fmtDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}.${two(d.month)}.${d.year} ${two(d.hour)}:${two(d.minute)}';
  }
}
