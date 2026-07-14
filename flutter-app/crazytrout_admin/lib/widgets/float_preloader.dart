import 'dart:math';
import 'package:flutter/material.dart';

/// Анимированный поплавок на волнах — прелоадер поиска Bluetooth-принтеров.
/// Поплавок качается на волнах, под ним — прогресс-бар (заполняется слева направо).
///
/// Использование:
/// ```dart
/// FloatPreloader(
///   progress: 0.6,        // 0.0 → 1.0, null = indeterminate
///   label: 'Ищем прUreтеры…',
/// )
/// ```
class FloatPreloader extends StatefulWidget {
  final String label;
  final double? progress;
  final Duration cycleDuration;

  const FloatPreloader({
    super.key,
    this.label = 'Ищем принтеры…',
    this.progress,
    this.cycleDuration = const Duration(seconds: 4),
  });

  @override
  State<FloatPreloader> createState() => _FloatPreloaderState();
}

class _FloatPreloaderState extends State<FloatPreloader>
    with TickerProviderStateMixin {
  late final AnimationController _bobController;
  late final AnimationController _waveController;
  late final AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _bobController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _progressController = AnimationController(
      vsync: this,
      duration: widget.cycleDuration,
    )..repeat();
  }

  @override
  void dispose() {
    _bobController.dispose();
    _waveController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double width = 220;
    const double height = 170;

    return SizedBox(
      width: width,
      height: height,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: width,
            height: 110,
            child: AnimatedBuilder(
              animation: Listenable.merge([_bobController, _waveController]),
              builder: (context, _) {
                return CustomPaint(
                  size: const Size(width, 110),
                  painter: _FloatPainter(
                    bobPhase: _bobController.value,
                    wavePhase: _waveController.value,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          _buildProgressBar(),
          const SizedBox(height: 8),
          Text(
            widget.label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8C8576),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    const barWidth = 180.0;
    const barHeight = 6.0;

    if (widget.progress != null) {
      return Container(
        width: barWidth,
        height: barHeight,
        decoration: BoxDecoration(
          color: const Color(0xFFF3EEE4),
          borderRadius: BorderRadius.circular(3),
        ),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: widget.progress!.clamp(0.0, 1.0),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFD4A85A), Color(0xFFE89829)],
              ),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      );
    }

    // Indeterminate — заполняется слева направо, потом сбрасывается
    return AnimatedBuilder(
      animation: _progressController,
      builder: (context, _) {
        final t = _progressController.value;
        // Плавное заполнение 0→1, затем быстрый сброс
        final fill = t < 0.85 ? (t / 0.85) : 1.0;
        final opacity = t < 0.85 ? 1.0 : 1.0 - ((t - 0.85) / 0.15);
        return Container(
          width: barWidth,
          height: barHeight,
          decoration: BoxDecoration(
            color: const Color(0xFFF3EEE4),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Opacity(
              opacity: opacity.clamp(0.0, 1.0),
              child: Container(
                width: barWidth * fill,
                height: barHeight,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD4A85A), Color(0xFFE89829)],
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Painter: реалистичный поплавок + одна линия воды.
class _FloatPainter extends CustomPainter {
  final double bobPhase;
  final double wavePhase;

  _FloatPainter({required this.bobPhase, required this.wavePhase});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final waterY = size.height * 0.62;
    final bob = sin(bobPhase * pi) * 8.0;

    // === Water surface — single line ===
    final wavePath = Path();
    for (double x = 0; x <= size.width; x += 1) {
      final y = waterY +
          sin((x / size.width) * 3 * pi + wavePhase * 2 * pi) * 3.0 +
          sin((x / size.width) * 5 * pi - wavePhase * 1.4 * pi) * 1.5;
      if (x == 0) {
        wavePath.moveTo(x, y);
      } else {
        wavePath.lineTo(x, y);
      }
    }
    canvas.drawPath(
      wavePath,
      Paint()
        ..color = const Color(0xFF2A6A7E).withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    // Water fill below surface
    final fillPath = Path.from(wavePath);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();
    canvas.drawPath(
      fillPath,
      Paint()..color = const Color(0xFF2A6A7E).withValues(alpha: 0.08),
    );

    // === Float ===
    final fx = cx;
    final fy = waterY - 8 + bob;

    // --- Stem (rod) ---
    final stemTop = fy - 50;
    final stemBottom = fy - 12;
    canvas.drawLine(
      Offset(fx, stemTop),
      Offset(fx, stemBottom),
      Paint()
        ..color = const Color(0xFF6B5B3A)
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );

    // --- Flag ---
    final flagPath = Path()
      ..moveTo(fx + 1, stemTop)
      ..lineTo(fx + 16, stemTop + 8)
      ..lineTo(fx + 1, stemTop + 16)
      ..close();
    canvas.drawPath(flagPath, Paint()..color = const Color(0xFFC9302C));

    // --- Upper body (red, tapered) ---
    final bodyTop = fy - 15;
    final bodyBottom = fy + 4;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(fx, (bodyTop + bodyBottom) / 2),
        width: 18,
        height: bodyBottom - bodyTop,
      ),
      Paint()..color = const Color(0xFFC9302C),
    );
    // Highlight
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(fx - 3, (bodyTop + bodyBottom) / 2 - 2),
        width: 6,
        height: 12,
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.28),
    );

    // --- Lower body (orange, tapered) ---
    final lowerTop = fy + 2;
    final lowerBottom = fy + 20;
    final lowerPath = Path()
      ..moveTo(fx - 7, lowerTop)
      ..quadraticCurveTo(fx - 5, (lowerTop + lowerBottom) / 2, fx - 2.5, lowerBottom)
      ..quadraticCurveTo(fx, lowerBottom + 1.5, fx + 2.5, lowerBottom)
      ..quadraticCurveTo(fx + 5, (lowerTop + lowerBottom) / 2, fx + 7, lowerTop)
      ..close();
    canvas.drawPath(lowerPath, Paint()..color = const Color(0xFFE89829));

    // --- Keel ---
    final keelY = lowerBottom + 2;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(fx, keelY), width: 9, height: 7),
      Paint()..color = const Color(0xFF8C8576),
    );
    canvas.drawCircle(
      Offset(fx, keelY),
      3,
      Paint()
        ..color = const Color(0xFF6B5B3A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // --- Fishing line into water ---
    final linePaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.25)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    final linePath = Path();
    final dashCount = 8;
    for (int i = 0; i < dashCount; i++) {
      final y1 = keelY + 3 + i * 3.0;
      final y2 = y1 + 1.5;
      linePath.moveTo(fx, y1);
      linePath.lineTo(fx, y2);
    }
    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant _FloatPainter old) =>
      old.bobPhase != bobPhase || old.wavePhase != wavePhase;
}
