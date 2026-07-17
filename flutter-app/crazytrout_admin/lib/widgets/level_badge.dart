// ============================================================================
// level_badge.dart — бейдж уровня клиента (медаль + лейбл).
//
// Ранее дублировался в report_screen.dart и checks_screen.dart.
// Включает: LevelBadge, Medal, MedalPainter.
// ============================================================================

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LevelBadge extends StatelessWidget {
  final LevelKey level;
  final bool compact;
  final double? sizeOverride;
  const LevelBadge({super.key, required this.level, this.compact = false, this.sizeOverride});

  @override
  Widget build(BuildContext context) {
    final l = kLevelStyles[level]!;
    final size = sizeOverride ?? (compact ? 16.0 : 18.0);
    final medal = Medal(style: l, size: size);
    if (compact) return medal;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: l.color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        medal,
        const SizedBox(width: 4),
        Text(l.label,
            style: TextStyle(
                color: l.color,
                fontSize: 12,
                fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

class Medal extends StatelessWidget {
  final LevelStyle style;
  final double size;
  const Medal({super.key, required this.style, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: MedalPainter(style: style)),
    );
  }
}

class MedalPainter extends CustomPainter {
  final LevelStyle style;
  MedalPainter({required this.style});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: r);
    canvas.drawCircle(
        center,
        r,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.3, -0.4),
            radius: 0.75,
            colors: [style.medalTop, style.medalMid, style.medalBottom],
            stops: const [0, 0.55, 1],
          ).createShader(rect));
    final tp = TextPainter(
      text: TextSpan(
          text: style.letter,
          style: TextStyle(
            color: style.letterColor,
            fontWeight: FontWeight.w800,
            fontSize: size.width * 0.52,
          )),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas,
        Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant MedalPainter old) => old.style != style;
}
