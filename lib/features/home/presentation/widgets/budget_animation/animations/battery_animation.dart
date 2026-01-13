import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/budget_colors.dart';

/// Animated battery that fills/empties based on budget percentage.
class BatteryAnimation extends StatefulWidget {
  const BatteryAnimation({
    required this.percentage,
    this.size = 150,
    super.key,
  });

  /// Budget percentage (0.0 to 1.0).
  final double percentage;

  /// Size of the animation widget.
  final double size;

  @override
  State<BatteryAnimation> createState() => _BatteryAnimationState();
}

class _BatteryAnimationState extends State<BatteryAnimation>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _levelController;
  late Animation<double> _levelAnimation;
  late Animation<double> _pulseAnimation;
  double _currentLevel = 0;

  @override
  void initState() {
    super.initState();

    // Pulse animation for low battery
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 0.5).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Level animation
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

    _updatePulse();
  }

  void _updatePulse() {
    if (widget.percentage <= 0.1) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
      _pulseController.value = 0;
    }
  }

  @override
  void didUpdateWidget(BatteryAnimation oldWidget) {
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
      _updatePulse();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _levelController.dispose();
    super.dispose();
  }

  Color _getBatteryColor(double percentage) {
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
      animation: Listenable.merge([_pulseController, _levelController]),
      builder: (context, child) {
        final level = _levelAnimation.value;
        final batteryColor = _getBatteryColor(level);
        final opacity = level <= 0.1 ? _pulseAnimation.value : 1.0;

        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _BatteryPainter(
              level: level,
              batteryColor: batteryColor,
              opacity: opacity,
            ),
          ),
        );
      },
    );
  }
}

class _BatteryPainter extends CustomPainter {
  _BatteryPainter({
    required this.level,
    required this.batteryColor,
    required this.opacity,
  });

  final double level;
  final Color batteryColor;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final batteryWidth = size.width * 0.6;
    final batteryHeight = size.height * 0.8;
    final left = (size.width - batteryWidth) / 2;
    final top = (size.height - batteryHeight) / 2 + 8;
    final cornerRadius = 12.0;

    // Battery body background
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, batteryWidth, batteryHeight),
      Radius.circular(cornerRadius),
    );

    final bodyPaint = Paint()
      ..color = AppColors.surfaceVariant
      ..style = PaintingStyle.fill;

    canvas.drawRRect(bodyRect, bodyPaint);

    // Battery border
    final borderPaint = Paint()
      ..color = AppColors.outlineVariant
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawRRect(bodyRect, borderPaint);

    // Battery cap (top)
    final capWidth = batteryWidth * 0.3;
    final capHeight = 8.0;
    final capLeft = left + (batteryWidth - capWidth) / 2;
    final capTop = top - capHeight;

    final capRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(capLeft, capTop, capWidth, capHeight + 4),
      topLeft: Radius.circular(4),
      topRight: Radius.circular(4),
    );

    canvas.drawRRect(capRect, bodyPaint);
    canvas.drawRRect(capRect, borderPaint);

    // Battery fill
    final fillPadding = 6.0;
    final fillWidth = batteryWidth - fillPadding * 2;
    final maxFillHeight = batteryHeight - fillPadding * 2;
    final fillHeight = maxFillHeight * level;
    final fillLeft = left + fillPadding;
    final fillTop = top + fillPadding + (maxFillHeight - fillHeight);

    if (level > 0) {
      final fillRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(fillLeft, fillTop, fillWidth, fillHeight),
        Radius.circular(cornerRadius - fillPadding),
      );

      // Gradient fill
      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            batteryColor.withValues(alpha: 0.8 * opacity),
            batteryColor.withValues(alpha: opacity),
          ],
        ).createShader(Rect.fromLTWH(fillLeft, fillTop, fillWidth, fillHeight));

      canvas.drawRRect(fillRect, fillPaint);

      // Shine effect on fill
      final shinePaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.white.withValues(alpha: 0.3 * opacity),
            Colors.white.withValues(alpha: 0),
            Colors.white.withValues(alpha: 0),
          ],
          stops: const [0.0, 0.3, 1.0],
        ).createShader(Rect.fromLTWH(fillLeft, fillTop, fillWidth, fillHeight));

      canvas.drawRRect(fillRect, shinePaint);
    }

    // Draw segments
    final segmentPaint = Paint()
      ..color = AppColors.outlineVariant.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 1; i < 4; i++) {
      final y = top + fillPadding + (maxFillHeight / 4) * i;
      canvas.drawLine(
        Offset(fillLeft + 4, y),
        Offset(fillLeft + fillWidth - 4, y),
        segmentPaint,
      );
    }

    // Lightning bolt for charging effect (when > 80%)
    if (level > 0.8) {
      final boltPath = Path();
      final boltCenterX = size.width / 2;
      final boltCenterY = size.height / 2;
      final boltSize = 20.0;

      boltPath.moveTo(boltCenterX + boltSize * 0.1, boltCenterY - boltSize * 0.5);
      boltPath.lineTo(boltCenterX - boltSize * 0.3, boltCenterY + boltSize * 0.1);
      boltPath.lineTo(boltCenterX, boltCenterY);
      boltPath.lineTo(boltCenterX - boltSize * 0.1, boltCenterY + boltSize * 0.5);
      boltPath.lineTo(boltCenterX + boltSize * 0.3, boltCenterY - boltSize * 0.1);
      boltPath.lineTo(boltCenterX, boltCenterY);
      boltPath.close();

      final boltPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.8)
        ..style = PaintingStyle.fill;

      canvas.drawPath(boltPath, boltPaint);
    }
  }

  @override
  bool shouldRepaint(_BatteryPainter oldDelegate) {
    return oldDelegate.level != level ||
        oldDelegate.batteryColor != batteryColor ||
        oldDelegate.opacity != opacity;
  }
}
