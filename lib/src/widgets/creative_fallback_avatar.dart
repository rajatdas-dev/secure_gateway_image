import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../models/creative_fallback_style.dart';
import '../utils/avatar_color_generator.dart';

/// A creative, aesthetically pleasing fallback avatar rendered when an image
/// fails to load and no user initials are provided.
class CreativeFallbackAvatar extends StatefulWidget {
  const CreativeFallbackAvatar({
    this.size,
    this.width,
    this.height,
    this.borderRadius,
    this.style = CreativeFallbackStyle.gradientGlow,
    this.icon,
    this.iconColor,
    this.backgroundColor,
    this.errorMessage,
    this.showErrorBadge = true,
    this.animate = true,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOutBack,
    this.seed,
    this.customBuilder,
    super.key,
  });

  /// Convenience property for square dimensions.
  final double? size;

  /// Explicit width.
  final double? width;

  /// Explicit height.
  final double? height;

  /// Corner radius for the avatar container.
  final BorderRadius? borderRadius;

  /// Creative visual styling mode.
  final CreativeFallbackStyle style;

  /// Icon rendered in the center of the creative avatar.
  final IconData? icon;

  /// Color of the center icon.
  final Color? iconColor;

  /// Primary background color or override.
  final Color? backgroundColor;

  /// Optional error message to display in the error badge / tooltip.
  final String? errorMessage;

  /// Whether to render a small status badge with a tooltip for the error.
  final bool showErrorBadge;

  /// Whether to animate the entrance of the fallback avatar.
  final bool animate;

  /// Duration of the entrance animation.
  final Duration duration;

  /// Easing curve of the entrance animation.
  final Curve curve;

  /// Optional seed string used for deterministic visual generation.
  final String? seed;

  /// Optional custom builder for full override.
  final Widget Function(BuildContext context, String? errorMessage)? customBuilder;

  @override
  State<CreativeFallbackAvatar> createState() => _CreativeFallbackAvatarState();
}

class _CreativeFallbackAvatarState extends State<CreativeFallbackAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: widget.animate ? 0 : 1,
    );

    if (widget.animate) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant CreativeFallbackAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
    if (oldWidget.animate != widget.animate) {
      if (widget.animate) {
        _controller
          ..value = 0
          ..forward();
      } else {
        _controller.value = 1;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.customBuilder != null) {
      return SizedBox(
        width: widget.width ?? widget.size,
        height: widget.height ?? widget.size,
        child: widget.customBuilder!(context, widget.errorMessage),
      );
    }

    final effectiveWidth = widget.width ?? widget.size ?? 80.0;
    final effectiveHeight = widget.height ?? widget.size ?? 80.0;
    final radius = widget.borderRadius ?? BorderRadius.circular(effectiveWidth * 0.28);

    final seedStr = widget.seed ?? widget.errorMessage ?? 'creative_fallback_seed';
    final baseColor = widget.backgroundColor ?? avatarColorFor(seedStr);

    final content = switch (widget.style) {
      CreativeFallbackStyle.gradientGlow => _buildGradientGlow(baseColor, effectiveWidth, effectiveHeight, radius),
      CreativeFallbackStyle.abstractPattern => _buildAbstractPattern(baseColor, effectiveWidth, effectiveHeight, radius),
      CreativeFallbackStyle.glassmorphic => _buildGlassmorphic(baseColor, effectiveWidth, effectiveHeight, radius),
      CreativeFallbackStyle.monogramMesh => _buildMonogramMesh(baseColor, effectiveWidth, effectiveHeight, radius),
    };

    final avatarWithBadge = Stack(
      clipBehavior: Clip.none,
      children: [
        content,
        if (widget.showErrorBadge && widget.errorMessage != null && widget.errorMessage!.isNotEmpty)
          Positioned(
            right: 0,
            bottom: 0,
            child: _buildErrorBadge(effectiveWidth),
          ),
      ],
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = CurvedAnimation(
          parent: _controller,
          curve: widget.curve,
        ).value;

        return Opacity(
          opacity: (0.3 + (progress * 0.7)).clamp(0.0, 1.0),
          child: Transform.scale(
            scale: (0.80 + (progress * 0.20)).clamp(0.0, 1.2),
            child: child,
          ),
        );
      },
      child: SizedBox(
        width: effectiveWidth,
        height: effectiveHeight,
        child: avatarWithBadge,
      ),
    );
  }

  Widget _buildGradientGlow(Color baseColor, double w, double h, BorderRadius radius) {
    final hsl = HSLColor.fromColor(baseColor);
    final secondaryColor = hsl
        .withHue((hsl.hue + 45) % 360)
        .withLightness((hsl.lightness + 0.15).clamp(0.0, 1.0))
        .toColor();
    final accentColor = hsl
        .withHue((hsl.hue + 180) % 360)
        .withSaturation(0.8)
        .withLightness(0.6)
        .toColor();

    final iconSize = (math.min(w, h) * 0.38).clamp(16.0, 56.0);

    return ClipRRect(
      borderRadius: radius,
      child: Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              baseColor,
              secondaryColor,
              accentColor.withValues(alpha: 0.85),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: baseColor.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Ambient inner glow ring
            Container(
              margin: EdgeInsets.all(w * 0.08),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.28),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
            // Glassmorphic icon backing pill
            Container(
              width: iconSize * 1.6,
              height: iconSize * 1.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.18),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Icon(
                  widget.icon ?? Icons.person_rounded,
                  size: iconSize,
                  color: widget.iconColor ?? Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAbstractPattern(Color baseColor, double w, double h, BorderRadius radius) {
    final iconSize = (math.min(w, h) * 0.34).clamp(14.0, 48.0);

    return ClipRRect(
      borderRadius: radius,
      child: Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: radius,
        ),
        child: CustomPaint(
          painter: _AbstractPatternPainter(baseColor: baseColor),
          child: Center(
            child: Container(
              padding: EdgeInsets.all(w * 0.12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: 0.22),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.5),
                  width: 1.2,
                ),
              ),
              child: Icon(
                widget.icon ?? Icons.auto_awesome_rounded,
                size: iconSize,
                color: widget.iconColor ?? Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassmorphic(Color baseColor, double w, double h, BorderRadius radius) {
    final iconSize = (math.min(w, h) * 0.38).clamp(16.0, 56.0);

    return ClipRRect(
      borderRadius: radius,
      child: Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1E1E2E).withValues(alpha: 0.92),
              const Color(0xFF11111B).withValues(alpha: 0.96),
            ],
          ),
          border: Border.all(
            color: baseColor.withValues(alpha: 0.6),
            width: 1.8,
          ),
          boxShadow: [
            BoxShadow(
              color: baseColor.withValues(alpha: 0.25),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Subtle diagonal shimmer line
            Positioned(
              top: -h * 0.2,
              left: -w * 0.2,
              child: Transform.rotate(
                angle: -0.6,
                child: Container(
                  width: w * 1.5,
                  height: h * 0.35,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.0),
                        baseColor.withValues(alpha: 0.18),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Icon(
              widget.icon ?? Icons.broken_image_rounded,
              size: iconSize,
              color: widget.iconColor ?? baseColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonogramMesh(Color baseColor, double w, double h, BorderRadius radius) {
    final hsl = HSLColor.fromColor(baseColor);
    final color1 = hsl.withHue((hsl.hue + 90) % 360).toColor();
    final color2 = hsl.withHue((hsl.hue + 210) % 360).toColor();

    final iconSize = (math.min(w, h) * 0.40).clamp(16.0, 56.0);

    return ClipRRect(
      borderRadius: radius,
      child: Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: SweepGradient(
            center: Alignment.center,
            colors: [
              baseColor,
              color1,
              color2,
              baseColor,
            ],
          ),
        ),
        child: Container(
          margin: EdgeInsets.all(w * 0.06),
          decoration: BoxDecoration(
            borderRadius: radius,
            color: Colors.black.withValues(alpha: 0.35),
          ),
          child: Center(
            child: Icon(
              widget.icon ?? Icons.account_circle_rounded,
              size: iconSize,
              color: widget.iconColor ?? Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBadge(double avatarWidth) {
    final badgeSize = (avatarWidth * 0.32).clamp(18.0, 32.0);

    return Tooltip(
      message: widget.errorMessage ?? 'Image could not be loaded after retrying',
      preferBelow: false,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      child: Container(
        width: badgeSize,
        height: badgeSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFFFF5252), Color(0xFFFF1744)],
          ),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.priority_high_rounded,
            size: badgeSize * 0.65,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _AbstractPatternPainter extends CustomPainter {
  const _AbstractPatternPainter({required this.baseColor});

  final Color baseColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.04
      ..color = Colors.white.withValues(alpha: 0.18);

    // Draw concentric arcs & decorative geometric circles
    final center = Offset(size.width * 0.5, size.height * 0.5);

    canvas.drawCircle(center, size.width * 0.35, paint);
    canvas.drawCircle(center, size.width * 0.22, paint);

    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withValues(alpha: 0.35);

    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.25), size.width * 0.04, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.75), size.width * 0.035, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.2), size.width * 0.03, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _AbstractPatternPainter oldDelegate) {
    return oldDelegate.baseColor != baseColor;
  }
}
