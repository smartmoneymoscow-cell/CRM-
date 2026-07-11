import 'package:flutter/material.dart';

import '../data/demo_data.dart';
import '../models/catch_row.dart';

class CatchRowTile extends StatelessWidget {
  final CatchRow row;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  const CatchRowTile({
    super.key,
    required this.row,
    required this.onChanged,
    required this.onRemove,
  });

  String _money(num n) {
    final rounded = n.round();
    final s = rounded.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]} ',
        );
    return '$s ₽';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Порода — цена всегда фиксированная и подставляется автоматически.
          Expanded(
            flex: 13,
            child: _Field(
              label: 'Порода',
              child: DropdownButtonFormField<String>(
                value: row.species,
                isExpanded: true,
                decoration: _decoration(),
                items: kSpecies
                    .map((s) => DropdownMenuItem(value: s, child: Text(s, overflow: TextOverflow.ellipsis)))
                    .toList(),
                onChanged: (v) {
                  if (v == null) return;
                  row.species = v;
                  row.pricePerKg = kSpeciesPrice[v] ?? row.pricePerKg;
                  onChanged();
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 7,
            child: _Field(
              label: 'Кг',
              child: TextFormField(
                initialValue: row.kg == row.kg.roundToDouble() ? row.kg.toInt().toString() : row.kg.toString(),
                keyboardType: const TextInputType.numberWithOptions(decimal: false),
                decoration: _decoration(),
                onChanged: (v) {
                  row.kg = double.tryParse(v) ?? 0;
                  onChanged();
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 7,
            child: _Field(
              label: 'Грамм',
              child: TextFormField(
                initialValue: row.grams.toString(),
                keyboardType: TextInputType.number,
                decoration: _decoration(),
                onChanged: (v) {
                  var g = int.tryParse(v) ?? 0;
                  if (g > 999) g = 999;
                  if (g < 0) g = 0;
                  row.grams = g;
                  onChanged();
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 9,
            child: _Field(
              label: 'Сумма',
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  _money(row.sum),
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                  textAlign: TextAlign.right,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Color(0xFFB4483A)),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }

  InputDecoration _decoration() => InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        filled: true,
        fillColor: const Color(0xFFF3EEE4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      );
}

class _Field extends StatelessWidget {
  final String label;
  final Widget child;
  const _Field({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(fontSize: 10, color: Color(0xFF9C9484), letterSpacing: .3),
        ),
        const SizedBox(height: 4),
        child,
      ],
    );
  }
}
