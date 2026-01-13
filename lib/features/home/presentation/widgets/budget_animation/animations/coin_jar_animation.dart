import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/budget_colors.dart';

/// Animated coin jar that fills/empties based on budget percentage.
class CoinJarAnimation extends StatefulWidget {
  const CoinJarAnimation({
    required this.percentage,
    this.size = 150,
    super.key,
  });

  /// Budget percentage (0.0 to 1.0).
  final double percentage;

  /// Size of the animation widget.
  final double size;

  @override
  State<CoinJarAnimation> createState() => _CoinJarAnimationState();
}

class _CoinJarAnimationState extends State<CoinJarAnimation>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _levelController;
  late AnimationController _coinDropController;
  late Animation<double> _levelAnimation;
  double _currentLevel = 0;
  bool _showCoinDrop = false;

  @override
  void initState() {
    super.initState();

    // Shimmer animation
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Coin drop animation
    _coinDropController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
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
  }

  @override
  void didUpdateWidget(CoinJarAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.percentage != widget.percentage) {
      // Show coin drop animation if level increased
      if (widget.percentage > oldWidget.percentage) {
        _showCoinDrop = true;
        _coinDropController.forward(from: 0).then((_) {
          _showCoinDrop = false;
        });
      }

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
    _shimmerController.dispose();
    _levelController.dispose();
    _coinDropController.dispose();
    super.dispose();
  }

  Color _getCoinColor(double percentage) {
    if (percentage > 0.5) {
      return Colors.amber.shade600;
    } else if (percentage > 0.3) {
      return Colors.amber.shade400;
    } else if (percentage > 0.1) {
      return Colors.amber.shade300;
    } else {
      return Colors.grey.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_shimmerController, _levelController, _coinDropController]),
      builder: (context, child) {
        final level = _levelAnimation.value;
        final coinColor = _getCoinColor(level);

        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _CoinJarPainter(
              level: level,
              coinColor: coinColor,
              shimmerPhase: _shimmerController.value,
              coinDropProgress: _showCoinDrop ? _coinDropController.value : null,
            ),
          ),
        );
      },
    );
  }
}

class _CoinJarPainter extends CustomPainter {
  _CoinJarPainter({
    required this.level,
    required this.coinColor,
    required this.shimmerPhase,
    this.coinDropProgress,
  });

  final double level;
  final Color coinColor;
  final double shimmerPhase;
  final double? coinDropProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final jarWidth = size.width * 0.65;
    final jarHeight = size.height * 0.75;
    final jarTop = size.height * 0.18;
    final jarLeft = (size.width - jarWidth) / 2;

    // Draw jar background (glass)
    _drawJar(canvas, jarLeft, jarTop, jarWidth, jarHeight, size);

    // Draw coins inside jar
    _drawCoins(canvas, jarLeft, jarTop, jarWidth, jarHeight, level);

    // Draw jar front glass (overlay for 3D effect)
    _drawJarOverlay(canvas, jarLeft, jarTop, jarWidth, jarHeight);

    // Draw coin drop animation
    if (coinDropProgress != null) {
      _drawDroppingCoin(canvas, centerX, jarTop, coinDropProgress!);
    }

    // Draw jar lid
    _drawLid(canvas, centerX, jarTop, jarWidth);
  }

  void _drawJar(Canvas canvas, double left, double top, double width, double height, Size size) {
    final jarPath = Path();

    // Jar body
    jarPath.moveTo(left + 10, top + 20);
    jarPath.quadraticBezierTo(left, top + height * 0.3, left, top + height * 0.5);
    jarPath.lineTo(left, top + height - 15);
    jarPath.quadraticBezierTo(left, top + height, left + 15, top + height);
    jarPath.lineTo(left + width - 15, top + height);
    jarPath.quadraticBezierTo(left + width, top + height, left + width, top + height - 15);
    jarPath.lineTo(left + width, top + height * 0.5);
    jarPath.quadraticBezierTo(left + width, top + height * 0.3, left + width - 10, top + 20);
    jarPath.close();

    // Glass effect
    final glassPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.lightBlue.shade50.withValues(alpha: 0.3),
          Colors.white.withValues(alpha: 0.1),
          Colors.lightBlue.shade50.withValues(alpha: 0.3),
        ],
      ).createShader(Rect.fromLTWH(left, top, width, height));

    canvas.drawPath(jarPath, glassPaint);

    // Jar border
    final borderPaint = Paint()
      ..color = AppColors.outlineVariant
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(jarPath, borderPaint);
  }

  void _drawCoins(Canvas canvas, double jarLeft, double jarTop, double jarWidth, double jarHeight, double level) {
    if (level <= 0) return;

    final coinsHeight = jarHeight * 0.85 * level;
    final coinsTop = jarTop + jarHeight - coinsHeight - 5;
    final random = math.Random(42);

    // Clip to jar shape
    canvas.save();
    final clipPath = Path();
    clipPath.addRect(Rect.fromLTWH(jarLeft + 5, coinsTop, jarWidth - 10, coinsHeight + 5));
    canvas.clipPath(clipPath);

    // Draw coin layers
    final numLayers = (coinsHeight / 8).floor();
    for (int layer = 0; layer < numLayers; layer++) {
      final y = jarTop + jarHeight - 10 - layer * 8;
      final coinsInLayer = (jarWidth / 15).floor();

      for (int i = 0; i < coinsInLayer; i++) {
        final x = jarLeft + 10 + i * 14 + (layer.isOdd ? 7 : 0) + random.nextDouble() * 4 - 2;

        if (x < jarLeft + jarWidth - 15) {
          _drawCoin(canvas, x, y, 6, random.nextDouble() * 0.3);
        }
      }
    }

    // Draw top coins with more detail
    final topY = coinsTop + 5;
    for (int i = 0; i < 5; i++) {
      final x = jarLeft + 20 + i * 18 + random.nextDouble() * 10;
      if (x < jarLeft + jarWidth - 20) {
        _drawCoin(canvas, x, topY, 7, random.nextDouble() * 0.4, detailed: true);
      }
    }

    canvas.restore();
  }

  void _drawCoin(Canvas canvas, double x, double y, double radius, double tilt, {bool detailed = false}) {
    canvas.save();
    canvas.translate(x, y);

    // Coin face
    final coinPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(coinColor, Colors.white, 0.3)!,
          coinColor,
          Color.lerp(coinColor, Colors.brown, 0.3)!,
        ],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: radius));

    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: radius * 2, height: radius * 1.6),
      coinPaint,
    );

    // Coin edge
    final edgePaint = Paint()
      ..color = Color.lerp(coinColor, Colors.brown, 0.4)!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: radius * 2, height: radius * 1.6),
      edgePaint,
    );

    // Coin shine
    if (detailed) {
      final shinePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.4)
        ..style = PaintingStyle.fill;

      canvas.drawOval(
        Rect.fromCenter(center: Offset(-radius * 0.3, -radius * 0.2), width: radius * 0.5, height: radius * 0.3),
        shinePaint,
      );

      // F symbol for FCFA
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'F',
          style: TextStyle(
            color: Color.lerp(coinColor, Colors.brown, 0.5),
            fontSize: radius,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
    }

    canvas.restore();
  }

  void _drawJarOverlay(Canvas canvas, double left, double top, double width, double height) {
    // Shine effect on glass
    final shinePath = Path();
    shinePath.moveTo(left + 15, top + 25);
    shinePath.quadraticBezierTo(left + 10, top + height * 0.5, left + 15, top + height - 20);
    shinePath.lineTo(left + 25, top + height - 25);
    shinePath.quadraticBezierTo(left + 20, top + height * 0.5, left + 25, top + 30);
    shinePath.close();

    final shinePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.4),
          Colors.white.withValues(alpha: 0.1),
          Colors.white.withValues(alpha: 0.3),
        ],
      ).createShader(Rect.fromLTWH(left, top, 30, height));

    canvas.drawPath(shinePath, shinePaint);

    // Shimmer effect
    final shimmerX = left + (width * shimmerPhase);
    final shimmerPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0),
          Colors.white.withValues(alpha: 0.2),
          Colors.white.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromLTWH(shimmerX - 20, top, 40, height));

    canvas.drawRect(Rect.fromLTWH(shimmerX - 20, top, 40, height), shimmerPaint);
  }

  void _drawLid(Canvas canvas, double centerX, double jarTop, double jarWidth) {
    final lidWidth = jarWidth * 0.7;
    final lidHeight = 15.0;
    final lidLeft = centerX - lidWidth / 2;

    // Lid body
    final lidPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.amber.shade300,
          Colors.amber.shade600,
          Colors.amber.shade800,
        ],
      ).createShader(Rect.fromLTWH(lidLeft, jarTop - lidHeight, lidWidth, lidHeight));

    final lidRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(lidLeft, jarTop - lidHeight + 5, lidWidth, lidHeight),
      const Radius.circular(3),
    );

    canvas.drawRRect(lidRect, lidPaint);

    // Lid top
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, jarTop - lidHeight + 5),
        width: lidWidth,
        height: 10,
      ),
      Paint()..color = Colors.amber.shade400,
    );

    // Lid border
    final lidBorderPaint = Paint()
      ..color = Colors.amber.shade900
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawRRect(lidRect, lidBorderPaint);
  }

  void _drawDroppingCoin(Canvas canvas, double centerX, double jarTop, double progress) {
    final startY = jarTop - 40;
    final endY = jarTop + 20;
    final currentY = startY + (endY - startY) * Curves.bounceOut.transform(progress);

    // Coin shadow
    if (progress > 0.5) {
      final shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.2 * (1 - progress))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      canvas.drawOval(
        Rect.fromCenter(center: Offset(centerX, endY + 5), width: 15 * (1 - progress * 0.5), height: 5),
        shadowPaint,
      );
    }

    // Spinning coin
    canvas.save();
    canvas.translate(centerX, currentY);
    canvas.rotate(progress * math.pi * 4);

    final coinPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.amber.shade300,
          Colors.amber.shade600,
        ],
      ).createShader(const Rect.fromLTWH(-8, -8, 16, 16));

    canvas.drawCircle(Offset.zero, 8, coinPaint);

    // Coin edge
    canvas.drawCircle(
      Offset.zero,
      8,
      Paint()
        ..color = Colors.amber.shade800
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(_CoinJarPainter oldDelegate) {
    return oldDelegate.level != level ||
        oldDelegate.coinColor != coinColor ||
        oldDelegate.shimmerPhase != shimmerPhase ||
        oldDelegate.coinDropProgress != coinDropProgress;
  }
}
