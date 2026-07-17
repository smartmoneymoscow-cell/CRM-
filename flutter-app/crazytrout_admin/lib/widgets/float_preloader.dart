import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Анимированный поплавок-бобber с анимацией поклёвки.
///
/// Использование:
/// ```dart
/// FloatPreloader(
///   label: 'Ищем принтеры…',
///   progress: null, // indeterminate
/// )
/// ```
///
/// Для анимации поклёвки:
/// ```dart
/// final key = GlobalKey<FloatPreloaderState>();
/// FloatPreloader(key: key, ...)
/// key.currentState?.triggerBite();
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
  FloatPreloaderState createState() => FloatPreloaderState();
}

class FloatPreloaderState extends State<FloatPreloader>
    with TickerProviderStateMixin {
  late final AnimationController _bobController;
  late final AnimationController _progressController;
  late final AnimationController _biteController;

  @override
  void initState() {
    super.initState();
    _bobController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _progressController = AnimationController(
      vsync: this,
      duration: widget.cycleDuration,
    )..repeat();

    _biteController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
  }

  @override
  void dispose() {
    _bobController.dispose();
    _progressController.dispose();
    _biteController.dispose();
    super.dispose();
  }

  /// Запускает анимацию поклёвки.
  void triggerBite() {
    if (_biteController.isAnimating) return;
    _biteController.forward(from: 0).then((_) {
      _biteController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    const double width = 160;
    const double height = 140;

    return SizedBox(
      width: width,
      height: height,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: width,
            height: 90,
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _bobController,
                _biteController,
              ]),
              builder: (context, _) {
                return CustomPaint(
                  size: const Size(width, 90),
                  painter: _FloatPainter(
                    bobPhase: _bobController.value,
                    biteValue: _biteController.value,
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
    const barWidth = 130.0;
    const barHeight = 4.0;

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

    return AnimatedBuilder(
      animation: _progressController,
      builder: (context, _) {
        final t = _progressController.value;
        return Container(
          width: barWidth,
          height: barHeight,
          decoration: BoxDecoration(
            color: const Color(0xFFF3EEE4),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: barWidth * t,
              height: barHeight,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFD4A85A), Color(0xFFE89829)],
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Painter: классический bobber + анимация поклёвки.
class _FloatPainter extends CustomPainter {
  final double bobPhase;
  final double biteValue; // 0=idle, 0..1=bite animation cycle

  _FloatPainter({
    required this.bobPhase,
    required this.biteValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final waterY = size.height * 0.58;
    final bob = sin(bobPhase * pi) * 6.0;

    // Bite animation offsets
    double dipOffset = 0;
    double tilt = 0;
    if (biteValue > 0) {
      if (biteValue < 0.12) {
        // Quick dip
        final t = _easeOutCubic(biteValue / 0.12);
        dipOffset = t * 20;
        tilt = t * 0.12;
      } else if (biteValue < 0.3) {
        // Submerge
        final t = _easeInOutCubic((biteValue - 0.12) / 0.18);
        dipOffset = 20 + t * 20;
        tilt = 0.12 + t * 0.08;
      } else if (biteValue < 0.6) {
        // Rise with bounce
        final t = _easeOutBounce((biteValue - 0.3) / 0.3);
        dipOffset = 40 * (1 - t);
        tilt = 0.2 * (1 - t);
      } else {
        // Wobble settle
        final t = (biteValue - 0.6) / 0.4;
        dipOffset = sin(t * pi * 6) * 3 * (1 - t);
        tilt = sin(t * pi * 5) * 0.02 * (1 - t);
      }
    }

    // === Water — simple straight line ===
    canvas.drawRect(
      Rect.fromLTWH(0, waterY, size.width, size.height - waterY),
      Paint()..color = const Color(0xFF2A6A7E).withOpacity(0.08),
    );
    canvas.drawLine(
      Offset(0, waterY),
      Offset(size.width, waterY),
      Paint()
        ..color = const Color(0xFF2A6A7E).withOpacity(0.25)
        ..strokeWidth = 1,
    );

    // === Float ===
    canvas.save();
    canvas.translate(cx, waterY - 2 + bob + dipOffset);
    canvas.rotate(tilt);

    // --- Keel (draw first, behind body) ---
    canvas.drawLine(
      const Offset(0, 26),
      const Offset(0, 42),
      Paint()
        ..color = const Color(0xFF6B5B3A)
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );
    // Keel weight — tapered oval
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 44), width: 6, height: 10),
      Paint()..color = const Color(0xFF4A3D28),
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 44), width: 6, height: 10),
      Paint()
        ..color = Colors.black.withOpacity(0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );

    // --- Body: realistic pear shape ---
    // White bottom portion (below waterline)
    final whitePath = Path()
      ..moveTo(0, -6)
      ..cubicTo(7, -2, 11, 10, 9, 22)
      ..cubicTo(7, 26, 3, 26, 0, 26)
      ..cubicTo(-3, 26, -7, 26, -9, 22)
      ..cubicTo(-11, 10, -7, -2, 0, -6)
      ..close();
    final whiteShader = ui.Gradient.linear(
      const Offset(-10, 0),
      const Offset(10, 0),
      [const Color(0xFFE8E0D0), const Color(0xFFFAF5EA), const Color(0xFFFAF5EA), const Color(0xFFD8D0C0)],
      [0.0, 0.3, 0.7, 1.0],
    );
    canvas.drawPath(whitePath, Paint()..shader = whiteShader);
    canvas.drawPath(
      whitePath,
      Paint()
        ..color = Colors.black.withOpacity(0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7,
    );

    // Red top portion (above waterline)
    final redPath = Path()
      ..moveTo(0, -22)
      ..cubicTo(5, -20, 8, -14, 7, -6)
      ..lineTo(-7, -6)
      ..cubicTo(-8, -14, -5, -20, 0, -22)
      ..close();
    final redShader = ui.Gradient.linear(
      const Offset(-8, -14),
      const Offset(8, -14),
      [const Color(0xFFA02020), const Color(0xFFD43838), const Color(0xFFE04040), const Color(0xFFA02020)],
      [0.0, 0.3, 0.6, 1.0],
    );
    canvas.drawPath(redPath, Paint()..shader = redShader);
    canvas.drawPath(
      redPath,
      Paint()
        ..color = Colors.black.withOpacity(0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7,
    );

    // Glossy highlight on red
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-2, -14), width: 4, height: 12),
      Paint()..color = Colors.white.withOpacity(0.3),
    );

    // Waterline ring
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, -6), width: 15, height: 3),
      Paint()
        ..color = const Color(0xFF645032).withOpacity(0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    // --- Antenna ---
    const double stickW = 1.8;
    const double antTop = -70;
    const double antBase = -22;

    // Tapered stick
    final stickPath = Path()
      ..moveTo(-stickW / 2 - 0.3, antBase)
      ..lineTo(-stickW / 2, antTop + 8)
      ..lineTo(stickW / 2, antTop + 8)
      ..lineTo(stickW / 2 + 0.3, antBase)
      ..close();
    canvas.drawPath(stickPath, Paint()..color = const Color(0xFFE04040));

    // White band
    const double bandY = antTop + (antBase - antTop) * 0.5;
    canvas.drawRect(
      Rect.fromLTWH(-stickW / 2 - 0.2, bandY, stickW + 0.4, 4),
      Paint()..color = const Color(0xFFF5F0E3),
    );

    // Ball on top
    final ballShader = ui.Gradient.radial(
      Offset(-1, antTop + 6.5),
      0.5,
      [const Color(0xFFFF6060), const Color(0xFFD43838), const Color(0xFFA02020)],
      [0.0, 0.5, 1.0],
    );
    canvas.drawCircle(
      Offset(0, antTop + 8),
      3.8,
      Paint()..shader = ballShader,
    );
    // Highlight
    canvas.drawCircle(
      Offset(-1.2, antTop + 6.5),
      1.2,
      Paint()..color = Colors.white.withOpacity(0.5),
    );

    canvas.restore();
  }

  double _easeOutCubic(double t) => 1 - pow(1 - t, 3).toDouble();
  double _easeInOutCubic(double t) =>
      t < 0.5 ? 4 * t * t * t : 1 - pow(-2 * t + 2, 3) / 2;
  double _easeOutBounce(double t) {
    if (t < 1 / 2.75) return 7.5625 * t * t;
    if (t < 2 / 2.75) {
      t -= 1.5 / 2.75;
      return 7.5625 * t * t + 0.75;
    }
    if (t < 2.5 / 2.75) {
      t -= 2.25 / 2.75;
      return 7.5625 * t * t + 0.9375;
    }
    t -= 2.625 / 2.75;
    return 7.5625 * t * t + 0.984375;
  }

  @override
  bool shouldRepaint(covariant _FloatPainter old) =>
      old.bobPhase != bobPhase ||
      old.biteValue != biteValue;
}
