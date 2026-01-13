import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../../core/theme/budget_colors.dart';

/// Animated tree that grows/shrinks based on budget percentage.
class TreeAnimation extends StatefulWidget {
  const TreeAnimation({
    required this.percentage,
    this.size = 150,
    super.key,
  });

  /// Budget percentage (0.0 to 1.0).
  final double percentage;

  /// Size of the animation widget.
  final double size;

  @override
  State<TreeAnimation> createState() => _TreeAnimationState();
}

class _TreeAnimationState extends State<TreeAnimation>
    with TickerProviderStateMixin {
  late AnimationController _swayController;
  late AnimationController _levelController;
  late Animation<double> _levelAnimation;
  double _currentLevel = 0;

  @override
  void initState() {
    super.initState();

    // Tree sway animation
    _swayController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    // Level animation
    _levelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
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
  void didUpdateWidget(TreeAnimation oldWidget) {
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
    _swayController.dispose();
    _levelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_swayController, _levelController]),
      builder: (context, child) {
        final level = _levelAnimation.value;
        final sway = math.sin(_swayController.value * math.pi) * 0.02;

        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _TreePainter(
              level: level,
              sway: sway,
            ),
          ),
        );
      },
    );
  }
}

class _TreePainter extends CustomPainter {
  _TreePainter({
    required this.level,
    required this.sway,
  });

  final double level;
  final double sway;

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final groundY = size.height * 0.85;

    // Draw ground
    final groundPaint = Paint()
      ..color = Colors.brown.shade300
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, groundY + 5),
        width: size.width * 0.5,
        height: 15,
      ),
      groundPaint,
    );

    // Draw grass
    final grassPaint = Paint()
      ..color = Colors.green.shade600
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, groundY),
        width: size.width * 0.6,
        height: 12,
      ),
      grassPaint,
    );

    // Draw trunk
    final trunkHeight = size.height * 0.35;
    final trunkWidth = size.width * 0.08;

    final trunkPath = Path();
    trunkPath.moveTo(centerX - trunkWidth, groundY);
    trunkPath.lineTo(centerX - trunkWidth * 0.7, groundY - trunkHeight);
    trunkPath.lineTo(centerX + trunkWidth * 0.7, groundY - trunkHeight);
    trunkPath.lineTo(centerX + trunkWidth, groundY);
    trunkPath.close();

    final trunkPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.brown.shade700,
          Colors.brown.shade500,
          Colors.brown.shade700,
        ],
      ).createShader(Rect.fromLTWH(centerX - trunkWidth, groundY - trunkHeight, trunkWidth * 2, trunkHeight));

    canvas.drawPath(trunkPath, trunkPaint);

    // Draw foliage based on level
    final foliageY = groundY - trunkHeight;
    _drawFoliage(canvas, centerX, foliageY, size, level, sway);

    // Draw falling leaves if level is dropping
    if (level < 0.3) {
      _drawFallingLeaves(canvas, size, groundY, level);
    }
  }

  void _drawFoliage(Canvas canvas, double centerX, double baseY, Size size, double level, double sway) {
    if (level <= 0) return;

    // Calculate foliage size based on level
    final maxFoliageHeight = size.height * 0.55;
    final foliageHeight = maxFoliageHeight * (0.3 + level * 0.7);
    final foliageWidth = size.width * 0.7 * (0.3 + level * 0.7);

    // Foliage color based on level
    Color foliageColor;
    if (level > 0.5) {
      foliageColor = BudgetColors.ok;
    } else if (level > 0.3) {
      foliageColor = Color.lerp(Colors.yellow.shade600, BudgetColors.ok, (level - 0.3) / 0.2)!;
    } else if (level > 0.1) {
      foliageColor = Color.lerp(Colors.orange, Colors.yellow.shade600, (level - 0.1) / 0.2)!;
    } else {
      foliageColor = Colors.orange.shade800;
    }

    // Apply sway transformation
    canvas.save();
    canvas.translate(centerX, baseY);
    canvas.rotate(sway);
    canvas.translate(-centerX, -baseY);

    // Draw multiple layers of foliage
    for (int i = 0; i < 3; i++) {
      final layerScale = 1.0 - i * 0.25;
      final layerY = baseY - (foliageHeight * 0.3 * i);
      final layerColor = i == 0
          ? Color.lerp(foliageColor, Colors.black, 0.2)!
          : (i == 1 ? foliageColor : Color.lerp(foliageColor, Colors.white, 0.2)!);

      final foliagePath = Path();
      foliagePath.moveTo(centerX, layerY - foliageHeight * layerScale * 0.8);

      // Left side curve
      foliagePath.quadraticBezierTo(
        centerX - foliageWidth * layerScale * 0.5,
        layerY - foliageHeight * layerScale * 0.5,
        centerX - foliageWidth * layerScale * 0.4,
        layerY,
      );

      // Bottom curve
      foliagePath.quadraticBezierTo(
        centerX,
        layerY + foliageHeight * layerScale * 0.1,
        centerX + foliageWidth * layerScale * 0.4,
        layerY,
      );

      // Right side curve
      foliagePath.quadraticBezierTo(
        centerX + foliageWidth * layerScale * 0.5,
        layerY - foliageHeight * layerScale * 0.5,
        centerX,
        layerY - foliageHeight * layerScale * 0.8,
      );

      foliagePath.close();

      final foliagePaint = Paint()
        ..color = layerColor
        ..style = PaintingStyle.fill;

      canvas.drawPath(foliagePath, foliagePaint);
    }

    canvas.restore();

    // Draw some fruit/flowers if very healthy
    if (level > 0.8) {
      final fruitPaint = Paint()
        ..color = Colors.red.shade400
        ..style = PaintingStyle.fill;

      final random = math.Random(42);
      for (int i = 0; i < 5; i++) {
        final angle = random.nextDouble() * math.pi;
        final distance = foliageWidth * 0.3 * random.nextDouble();
        final fruitX = centerX + math.cos(angle) * distance * (random.nextBool() ? 1 : -1);
        final fruitY = baseY - foliageHeight * 0.3 - random.nextDouble() * foliageHeight * 0.4;

        canvas.drawCircle(Offset(fruitX, fruitY), 4, fruitPaint);
      }
    }
  }

  void _drawFallingLeaves(Canvas canvas, Size size, double groundY, double level) {
    final leafPaint = Paint()..style = PaintingStyle.fill;
    final random = math.Random((level * 1000).toInt());

    final numLeaves = ((1 - level) * 10).toInt();
    for (int i = 0; i < numLeaves; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height * 0.7 + size.height * 0.15;

      leafPaint.color = [
        Colors.orange,
        Colors.yellow.shade700,
        Colors.red.shade400,
        Colors.brown.shade400,
      ][random.nextInt(4)].withValues(alpha: 0.7);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(random.nextDouble() * math.pi * 2);

      final leafPath = Path();
      leafPath.moveTo(0, -4);
      leafPath.quadraticBezierTo(4, 0, 0, 4);
      leafPath.quadraticBezierTo(-4, 0, 0, -4);

      canvas.drawPath(leafPath, leafPaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_TreePainter oldDelegate) {
    return oldDelegate.level != level || oldDelegate.sway != sway;
  }
}
