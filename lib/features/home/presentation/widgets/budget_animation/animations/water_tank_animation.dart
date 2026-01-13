import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/budget_colors.dart';

/// Animated water tank that fills/empties based on budget percentage.
class WaterTankAnimation extends StatefulWidget {
  const WaterTankAnimation({
    required this.percentage,
    this.size = 150,
    super.key,
  });

  /// Budget percentage (0.0 to 1.0).
  final double percentage;

  /// Size of the animation widget.
  final double size;

  @override
  State<WaterTankAnimation> createState() => _WaterTankAnimationState();
}

class _WaterTankAnimationState extends State<WaterTankAnimation>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _levelController;
  late Animation<double> _levelAnimation;
  double _currentLevel = 0;

  @override
  void initState() {
    super.initState();

    // Wave animation (continuous)
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Level animation (when percentage changes)
    _levelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _currentLevel = widget.percentage;
    _levelAnimation = Tween<double>(
      begin: _currentLevel,
      end: widget.percentage,
    ).animate(CurvedAnimation(
      parent: _levelController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(WaterTankAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.percentage != widget.percentage) {
      _levelAnimation = Tween<double>(
        begin: _currentLevel,
        end: widget.percentage,
      ).animate(CurvedAnimation(
        parent: _levelController,
        curve: Curves.easeInOut,
      ));
      _levelController.forward(from: 0).then((_) {
        _currentLevel = widget.percentage;
      });
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _levelController.dispose();
    super.dispose();
  }

  Color _getWaterColor(double percentage) {
    if (percentage > 0.5) {
      return BudgetColors.ok;
    } else if (percentage > 0.3) {
      return BudgetColors.warning;
    } else if (percentage > 0.1) {
      return Colors.orange;
    } else {
      return BudgetColors.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_waveController, _levelController]),
      builder: (context, child) {
        final level = _levelAnimation.value;
        final waterColor = _getWaterColor(level);

        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _WaterTankPainter(
              waterLevel: level,
              wavePhase: _waveController.value * 2 * math.pi,
              waterColor: waterColor,
            ),
          ),
        );
      },
    );
  }
}

class _WaterTankPainter extends CustomPainter {
  _WaterTankPainter({
    required this.waterLevel,
    required this.wavePhase,
    required this.waterColor,
  });

  final double waterLevel;
  final double wavePhase;
  final Color waterColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // Draw tank background (glass effect)
    final tankPaint = Paint()
      ..color = AppColors.surfaceVariant
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, tankPaint);

    // Draw tank border
    final borderPaint = Paint()
      ..color = AppColors.outlineVariant
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(center, radius, borderPaint);

    // Clip to circle for water
    canvas.save();
    final clipPath = Path()..addOval(Rect.fromCircle(center: center, radius: radius - 2));
    canvas.clipPath(clipPath);

    // Calculate water height
    final waterHeight = size.height * waterLevel;
    final waterTop = size.height - waterHeight;

    // Draw water with waves
    final waterPath = Path();
    waterPath.moveTo(0, size.height);

    // Create wave effect
    for (double x = 0; x <= size.width; x += 1) {
      final waveHeight = 4 * math.sin((x / size.width * 4 * math.pi) + wavePhase);
      final waveHeight2 = 2 * math.sin((x / size.width * 6 * math.pi) + wavePhase * 1.5);
      final y = waterTop + waveHeight + waveHeight2;
      waterPath.lineTo(x, y);
    }

    waterPath.lineTo(size.width, size.height);
    waterPath.close();

    // Water gradient
    final waterPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          waterColor.withValues(alpha: 0.7),
          waterColor,
        ],
      ).createShader(Rect.fromLTWH(0, waterTop, size.width, waterHeight));

    canvas.drawPath(waterPath, waterPaint);

    // Draw bubbles
    if (waterLevel > 0.1) {
      final bubblePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;

      final random = math.Random(42);
      for (int i = 0; i < 5; i++) {
        final bubbleX = random.nextDouble() * size.width * 0.6 + size.width * 0.2;
        final bubbleBaseY = size.height - (random.nextDouble() * waterHeight * 0.7);
        final bubbleY = bubbleBaseY - (wavePhase / (2 * math.pi) * 20) % (waterHeight * 0.5);
        final bubbleRadius = random.nextDouble() * 3 + 2;

        if (bubbleY > waterTop && bubbleY < size.height) {
          canvas.drawCircle(Offset(bubbleX, bubbleY), bubbleRadius, bubblePaint);
        }
      }
    }

    canvas.restore();

    // Draw shine effect on glass
    final shinePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.3),
          Colors.white.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    final shinePath = Path();
    shinePath.addArc(
      Rect.fromCircle(center: Offset(center.dx - radius * 0.3, center.dy - radius * 0.3), radius: radius * 0.4),
      -math.pi / 2,
      math.pi,
    );
    canvas.drawPath(shinePath, shinePaint);
  }

  @override
  bool shouldRepaint(_WaterTankPainter oldDelegate) {
    return oldDelegate.waterLevel != waterLevel ||
        oldDelegate.wavePhase != wavePhase ||
        oldDelegate.waterColor != waterColor;
  }
}
