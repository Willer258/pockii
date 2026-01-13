import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Animated cat whose emotions change based on budget percentage.
/// - Happy cat (>50%): Joyful, content
/// - Worried cat (20-50%): Thinking, concerned
/// - Sad cat (<20%): Crying, distressed
class CatAnimation extends StatefulWidget {
  const CatAnimation({
    required this.percentage,
    this.size = 150,
    super.key,
  });

  /// Budget percentage (0.0 to 1.0).
  final double percentage;

  /// Size of the animation widget.
  final double size;

  @override
  State<CatAnimation> createState() => _CatAnimationState();
}

class _CatAnimationState extends State<CatAnimation>
    with SingleTickerProviderStateMixin {
  late String _currentAnimation;
  String? _previousAnimation;

  // Lottie animation URLs from LottieFiles
  static const String _happyCatUrl =
      'https://lottie.host/f69bea67-6c95-4e86-9292-b53fcf932f34/wJB3QhKh2O.json';
  static const String _worriedCatUrl =
      'https://lottie.host/87be64d3-2f52-4a48-8a2e-5bef11f70e14/lU1QnXGHY0.json';
  static const String _sadCatUrl =
      'https://lottie.host/9d8bc4d9-5d09-4c5a-9b5a-b0e0e9c69f57/7kLqx3DFFs.json';

  @override
  void initState() {
    super.initState();
    _currentAnimation = _getAnimationUrl(widget.percentage);
  }

  @override
  void didUpdateWidget(CatAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newAnimation = _getAnimationUrl(widget.percentage);
    if (newAnimation != _currentAnimation) {
      setState(() {
        _previousAnimation = _currentAnimation;
        _currentAnimation = newAnimation;
      });
    }
  }

  String _getAnimationUrl(double percentage) {
    if (percentage > 0.5) {
      return _happyCatUrl;
    } else if (percentage > 0.2) {
      return _worriedCatUrl;
    } else {
      return _sadCatUrl;
    }
  }

  String _getEmotionLabel(double percentage) {
    if (percentage > 0.5) {
      return 'Content';
    } else if (percentage > 0.2) {
      return 'Inquiet';
    } else {
      return 'Triste';
    }
  }

  Color _getEmotionColor(double percentage) {
    if (percentage > 0.5) {
      return Colors.green;
    } else if (percentage > 0.2) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Cat animation
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: Lottie.network(
              _currentAnimation,
              key: ValueKey(_currentAnimation),
              width: widget.size,
              height: widget.size,
              fit: BoxFit.contain,
              repeat: true,
              animate: true,
              errorBuilder: (context, error, stackTrace) {
                // Fallback to emoji if network fails
                return _buildFallbackEmoji();
              },
              frameBuilder: (context, child, composition) {
                if (composition == null) {
                  return _buildLoadingIndicator();
                }
                return child;
              },
            ),
          ),
        ),
        const SizedBox(height: 4),
        // Emotion label
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: _getEmotionColor(widget.percentage).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _getEmotionLabel(widget.percentage),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: _getEmotionColor(widget.percentage),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFallbackEmoji() {
    String emoji;
    if (widget.percentage > 0.5) {
      emoji = '😺';
    } else if (widget.percentage > 0.2) {
      emoji = '😿';
    } else {
      emoji = '🙀';
    }
    return Center(
      child: Text(
        emoji,
        style: TextStyle(fontSize: widget.size * 0.5),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: SizedBox(
        width: 30,
        height: 30,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: _getEmotionColor(widget.percentage),
        ),
      ),
    );
  }
}
