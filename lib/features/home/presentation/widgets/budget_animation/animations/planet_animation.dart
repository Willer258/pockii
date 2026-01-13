import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../../core/theme/budget_colors.dart';

/// Animated planet that shrinks/grows based on budget percentage.
class PlanetAnimation extends StatefulWidget {
  const PlanetAnimation({
    required this.percentage,
    this.size = 150,
    super.key,
  });

  /// Budget percentage (0.0 to 1.0).
  final double percentage;

  /// Size of the animation widget.
  final double size;

  @override
  State<PlanetAnimation> createState() => _PlanetAnimationState();
}

class _PlanetAnimationState extends State<PlanetAnimation>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _levelController;
  late AnimationController _starsController;
  late Animation<double> _levelAnimation;
  double _currentLevel = 0;

  @override
  void initState() {
    super.initState();

    // Planet rotation
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Stars twinkling
    _starsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

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
  }

  @override
  void didUpdateWidget(PlanetAnimation oldWidget) {
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
    _rotationController.dispose();
    _levelController.dispose();
    _starsController.dispose();
    super.dispose();
  }

  Color _getPlanetColor(double percentage) {
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
      animation: Listenable.merge([_rotationController, _levelController, _starsController]),
      builder: (context, child) {
        final level = _levelAnimation.value;
        final planetColor = _getPlanetColor(level);

        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _PlanetPainter(
              level: level,
              planetColor: planetColor,
              rotation: _rotationController.value * 2 * math.pi,
              starsTwinkle: _starsController.value,
            ),
          ),
        );
      },
    );
  }
}

class _PlanetPainter extends CustomPainter {
  _PlanetPainter({
    required this.level,
    required this.planetColor,
    required this.rotation,
    required this.starsTwinkle,
  });

  final double level;
  final Color planetColor;
  final double rotation;
  final double starsTwinkle;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2 - 15;

    // Draw stars in background
    _drawStars(canvas, size);

    // Planet radius based on level (min 30% of max)
    final planetRadius = maxRadius * (0.3 + level * 0.7);

    // Draw planet glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          planetColor.withValues(alpha: 0.3),
          planetColor.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: planetRadius + 15));

    canvas.drawCircle(center, planetRadius + 15, glowPaint);

    // Draw planet base
    final planetPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        colors: [
          Color.lerp(planetColor, Colors.white, 0.3)!,
          planetColor,
          Color.lerp(planetColor, Colors.black, 0.3)!,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: planetRadius));

    canvas.drawCircle(center, planetRadius, planetPaint);

    // Draw continents/features on planet
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.translate(-center.dx, -center.dy);

    final featurePaint = Paint()
      ..color = Color.lerp(planetColor, Colors.green.shade800, 0.5)!.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    // Draw some "continents"
    final random = math.Random(42);
    for (int i = 0; i < 5; i++) {
      final angle = random.nextDouble() * 2 * math.pi;
      final distance = random.nextDouble() * planetRadius * 0.6;
      final featureSize = planetRadius * (0.15 + random.nextDouble() * 0.2);

      final featureCenter = Offset(
        center.dx + math.cos(angle) * distance,
        center.dy + math.sin(angle) * distance,
      );

      // Only draw if within planet bounds
      if ((featureCenter - center).distance + featureSize < planetRadius) {
        canvas.drawOval(
          Rect.fromCenter(
            center: featureCenter,
            width: featureSize * 1.5,
            height: featureSize,
          ),
          featurePaint,
        );
      }
    }

    canvas.restore();

    // Draw atmosphere rim
    final atmospherePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.transparent,
          Colors.white.withValues(alpha: 0.1),
          Colors.lightBlue.withValues(alpha: 0.2),
        ],
        stops: const [0.85, 0.95, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: planetRadius));

    canvas.drawCircle(center, planetRadius, atmospherePaint);

    // Draw ring if budget is healthy (> 70%)
    if (level > 0.7) {
      _drawRing(canvas, center, planetRadius);
    }

    // Draw danger indicators if low budget
    if (level < 0.2) {
      _drawMeteors(canvas, size, center, planetRadius);
    }
  }

  void _drawStars(Canvas canvas, Size size) {
    final starPaint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(123);

    for (int i = 0; i < 20; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final starSize = random.nextDouble() * 2 + 1;
      final twinkleOffset = random.nextDouble();
      final alpha = 0.3 + (starsTwinkle + twinkleOffset).remainder(1.0) * 0.5;

      starPaint.color = Colors.white.withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), starSize, starPaint);
    }
  }

  void _drawRing(Canvas canvas, Offset center, double planetRadius) {
    final ringPaint = Paint()
      ..color = Colors.amber.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(1, 0.3); // Flatten for 3D effect
    canvas.translate(-center.dx, -center.dy);

    canvas.drawCircle(center, planetRadius + 20, ringPaint);

    ringPaint
      ..color = Colors.amber.withValues(alpha: 0.2)
      ..strokeWidth = 8;
    canvas.drawCircle(center, planetRadius + 25, ringPaint);

    canvas.restore();
  }

  void _drawMeteors(Canvas canvas, Size size, Offset center, double planetRadius) {
    final meteorPaint = Paint()
      ..color = Colors.red.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    final random = math.Random(456);
    final time = rotation; // Use rotation as time for animation

    for (int i = 0; i < 3; i++) {
      final startAngle = random.nextDouble() * 2 * math.pi + time * (i + 1) * 0.5;
      final distance = size.width * 0.4;

      final meteorX = center.dx + math.cos(startAngle) * distance;
      final meteorY = center.dy + math.sin(startAngle) * distance;

      if (meteorX > 0 && meteorX < size.width && meteorY > 0 && meteorY < size.height) {
        // Meteor head
        canvas.drawCircle(Offset(meteorX, meteorY), 4, meteorPaint);

        // Meteor tail
        final tailPaint = Paint()
          ..shader = LinearGradient(
            colors: [
              Colors.orange.withValues(alpha: 0.6),
              Colors.red.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromPoints(
            Offset(meteorX, meteorY),
            Offset(meteorX - math.cos(startAngle) * 20, meteorY - math.sin(startAngle) * 20),
          ));

        canvas.drawLine(
          Offset(meteorX, meteorY),
          Offset(meteorX - math.cos(startAngle) * 20, meteorY - math.sin(startAngle) * 20),
          tailPaint..strokeWidth = 3,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_PlanetPainter oldDelegate) {
    return oldDelegate.level != level ||
        oldDelegate.planetColor != planetColor ||
        oldDelegate.rotation != rotation ||
        oldDelegate.starsTwinkle != starsTwinkle;
  }
}
