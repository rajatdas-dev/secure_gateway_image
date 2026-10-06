import 'package:flutter/material.dart';

import '../utils/avatar_color_generator.dart';
import '../utils/initials_generator.dart';

class InitialsAvatar extends StatefulWidget {
  const InitialsAvatar({
    required this.initials,
    this.size,
    this.width,
    this.height,
    this.backgroundColor,
    this.textStyle,
    this.borderRadius,
    this.animate = true,
    this.duration = const Duration(milliseconds: 550),
    this.curve = Curves.easeOutBack,
    super.key,
  });

  final String initials;

  final double? size;

  final double? width;

  final double? height;

  final Color? backgroundColor;

  final TextStyle? textStyle;

  final BorderRadius? borderRadius;

  final bool animate;

  final Duration duration;

  final Curve curve;

  @override
  State<InitialsAvatar> createState() => _InitialsAvatarState();
}

class _InitialsAvatarState extends State<InitialsAvatar>
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
  void didUpdateWidget(covariant InitialsAvatar oldWidget) {
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
    final label = generateInitials(widget.initials);

    final baseColor =
        widget.backgroundColor ??
        avatarColorFor(widget.initials.isEmpty ? label : widget.initials);

    final radius = widget.borderRadius ?? BorderRadius.circular(999);
    final effectiveWidth = widget.width ?? widget.size;
    final effectiveHeight = widget.height ?? widget.size;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = CurvedAnimation(
          parent: _controller,
          curve: widget.curve,
        ).value;

        return Opacity(
          opacity: (0.55 + (progress * 0.45)).clamp(0.0, 1.0),
          child: Transform.scale(scale: 0.82 + (progress * 0.18), child: child),
        );
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              baseColor,
              HSLColor.fromColor(baseColor)
                  .withLightness(
                    (HSLColor.fromColor(baseColor).lightness + 0.12)
                        .clamp(0.0, 1.0)
                        .toDouble(),
                  )
                  .toColor(),
            ],
          ),
        ),
        child: SizedBox(
          width: effectiveWidth,
          height: effectiveHeight,
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style:
                  widget.textStyle ??
                  TextStyle(
                    color: Colors.white,
                    fontSize: effectiveWidth == null
                        ? 20
                        : (effectiveWidth * 0.36).clamp(12.0, 40.0),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
