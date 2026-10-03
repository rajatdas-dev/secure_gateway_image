import 'package:flutter/material.dart';

import '../models/gateway_image_stage.dart';
import 'initials_avatar.dart';

/// Error-resilient image widget.
///
/// Fallback order:
///
/// ```text
/// Network
///    ↓
/// Local ImageProvider
///    ↓
/// Asset
///    ↓
/// Animated initials avatar
/// ```
class SecureGatewayImage extends StatefulWidget {
  const SecureGatewayImage({
    this.networkUrl,
    this.cachedImage,
    this.assetPath,
    this.initials = '?',
    this.width,
    this.height,
    this.size,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.borderRadius,
    this.headers,
    this.cacheWidth,
    this.cacheHeight,
    this.backgroundColor,
    this.avatarTextStyle,
    this.animateAvatar = true,
    this.avatarAnimationDuration = const Duration(milliseconds: 550),
    this.avatarAnimationCurve = Curves.easeOutBack,
    this.fadeInDuration = const Duration(milliseconds: 180),
    this.fadeInCurve = Curves.easeOut,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    this.filterQuality = FilterQuality.medium,
    this.onStageChanged,
    this.placeholder,
    this.avatarBuilder,
    super.key,
  });

  /// Primary remote image URL.
  final String? networkUrl;

  /// Local cached image.
  ///
  /// Examples:
  ///
  /// ```dart
  /// FileImage(file)
  /// MemoryImage(bytes)
  /// ```
  ///
  /// The widget itself does not manage the cache.
  final ImageProvider<Object>? cachedImage;

  /// Asset path used after network and cache fail.
  final String? assetPath;

  /// Name or initials used by the final avatar.
  final String initials;

  /// Explicit width.
  final double? width;

  /// Explicit height.
  final double? height;

  /// Convenience property for square images.
  final double? size;

  /// How the image should fit inside its bounds.
  final BoxFit fit;

  /// Image alignment.
  final AlignmentGeometry alignment;

  /// Border radius applied to the complete widget.
  final BorderRadius? borderRadius;

  /// HTTP headers used by the network image.
  final Map<String, String>? headers;

  /// Width used when decoding the image.
  final int? cacheWidth;

  /// Height used when decoding the image.
  final int? cacheHeight;

  /// Avatar background color.
  final Color? backgroundColor;

  /// Avatar text style.
  final TextStyle? avatarTextStyle;

  /// Whether the final avatar should animate.
  final bool animateAvatar;

  /// Avatar animation duration.
  final Duration avatarAnimationDuration;

  /// Avatar animation curve.
  final Curve avatarAnimationCurve;

  /// Duration used for image fade-in.
  final Duration fadeInDuration;

  /// Curve used for image fade-in.
  final Curve fadeInCurve;

  /// Accessibility semantic label.
  final String? semanticLabel;

  /// Whether the image should be excluded from semantics.
  final bool excludeFromSemantics;

  /// Image filtering quality.
  final FilterQuality filterQuality;

  /// Called when the fallback stage changes.
  final ValueChanged<GatewayImageStage>? onStageChanged;

  /// Widget displayed while an image source is loading.
  final WidgetBuilder? placeholder;

  /// Custom final avatar builder.
  final Widget Function(BuildContext context, String initials)? avatarBuilder;

  @override
  State<SecureGatewayImage> createState() => _SecureGatewayImageState();
}

class _SecureGatewayImageState extends State<SecureGatewayImage> {
  late GatewayImageStage _stage;

  bool _transitionScheduled = false;

  @override
  void initState() {
    super.initState();

    _stage = _initialStage();
  }

  @override
  void didUpdateWidget(covariant SecureGatewayImage oldWidget) {
    super.didUpdateWidget(oldWidget);

    final nextStage = _initialStage();

    if (nextStage != _stage) {
      _setStage(nextStage);
    }
  }

  GatewayImageStage _initialStage() {
    if (_hasNetwork) {
      return GatewayImageStage.network;
    }

    if (_hasCache) {
      return GatewayImageStage.cache;
    }

    if (_hasAsset) {
      return GatewayImageStage.asset;
    }

    return GatewayImageStage.avatar;
  }

  bool get _hasNetwork {
    final url = widget.networkUrl;

    return url != null && url.trim().isNotEmpty;
  }

  bool get _hasCache {
    return widget.cachedImage != null;
  }

  bool get _hasAsset {
    final asset = widget.assetPath;

    return asset != null && asset.trim().isNotEmpty;
  }

  void _setStage(GatewayImageStage stage) {
    if (!mounted || stage == _stage) {
      return;
    }

    setState(() {
      _stage = stage;
    });

    widget.onStageChanged?.call(stage);
  }

  void _advance() {
    if (_transitionScheduled || !mounted) {
      return;
    }

    _transitionScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _transitionScheduled = false;

      if (!mounted) {
        return;
      }

      switch (_stage) {
        case GatewayImageStage.network:
          if (_hasCache) {
            _setStage(GatewayImageStage.cache);
          } else if (_hasAsset) {
            _setStage(GatewayImageStage.asset);
          } else {
            _setStage(GatewayImageStage.avatar);
          }

        case GatewayImageStage.cache:
          if (_hasAsset) {
            _setStage(GatewayImageStage.asset);
          } else {
            _setStage(GatewayImageStage.avatar);
          }

        case GatewayImageStage.asset:
          _setStage(GatewayImageStage.avatar);

        case GatewayImageStage.avatar:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final child = switch (_stage) {
      GatewayImageStage.network => _buildNetwork(),
      GatewayImageStage.cache => _buildCache(),
      GatewayImageStage.asset => _buildAsset(),
      GatewayImageStage.avatar => _buildAvatar(),
    };

    return ClipRRect(
      borderRadius: widget.borderRadius ?? BorderRadius.zero,
      child: child,
    );
  }

  Widget _buildNetwork() {
    return Image.network(
      widget.networkUrl!,
      width: widget.width ?? widget.size,
      height: widget.height ?? widget.size,
      fit: widget.fit,
      alignment: widget.alignment,
      headers: widget.headers,
      cacheWidth: widget.cacheWidth,
      cacheHeight: widget.cacheHeight,
      semanticLabel: widget.semanticLabel,
      excludeFromSemantics: widget.excludeFromSemantics,
      filterQuality: widget.filterQuality,
      frameBuilder: _frameBuilder,
      errorBuilder:
          (BuildContext context, Object error, StackTrace? stackTrace) {
            _advance();

            return _buildLoadingPlaceholder();
          },
    );
  }

  Widget _buildCache() {
    final provider = widget.cachedImage;

    if (provider == null) {
      _advance();

      return _buildLoadingPlaceholder();
    }

    return Image(
      image: provider,
      width: widget.width ?? widget.size,
      height: widget.height ?? widget.size,
      fit: widget.fit,
      alignment: widget.alignment,
      semanticLabel: widget.semanticLabel,
      excludeFromSemantics: widget.excludeFromSemantics,
      filterQuality: widget.filterQuality,
      frameBuilder: _frameBuilder,
      errorBuilder:
          (BuildContext context, Object error, StackTrace? stackTrace) {
            _advance();

            return _buildLoadingPlaceholder();
          },
    );
  }

  Widget _buildAsset() {
    return Image.asset(
      widget.assetPath!,
      width: widget.width ?? widget.size,
      height: widget.height ?? widget.size,
      fit: widget.fit,
      alignment: widget.alignment,
      cacheWidth: widget.cacheWidth,
      cacheHeight: widget.cacheHeight,
      semanticLabel: widget.semanticLabel,
      excludeFromSemantics: widget.excludeFromSemantics,
      filterQuality: widget.filterQuality,
      frameBuilder: _frameBuilder,
      errorBuilder:
          (BuildContext context, Object error, StackTrace? stackTrace) {
            _advance();

            return _buildLoadingPlaceholder();
          },
    );
  }

  Widget _buildAvatar() {
    final builder = widget.avatarBuilder;

    if (builder != null) {
      return SizedBox(
        width: widget.width ?? widget.size,
        height: widget.height ?? widget.size,
        child: builder(context, widget.initials),
      );
    }

    return InitialsAvatar(
      initials: widget.initials,
      size: widget.size,
      backgroundColor: widget.backgroundColor,
      textStyle: widget.avatarTextStyle,
      borderRadius: widget.borderRadius,
      animate: widget.animateAvatar,
      duration: widget.avatarAnimationDuration,
      curve: widget.avatarAnimationCurve,
    );
  }

  Widget _buildLoadingPlaceholder() {
    return widget.placeholder?.call(context) ??
        SizedBox(
          width: widget.width ?? widget.size,
          height: widget.height ?? widget.size,
        );
  }

  Widget _frameBuilder(
    BuildContext context,
    Widget child,
    int? frame,
    bool wasSynchronouslyLoaded,
  ) {
    if (wasSynchronouslyLoaded) {
      return child;
    }

    return AnimatedOpacity(
      opacity: frame == null ? 0 : 1,
      duration: widget.fadeInDuration,
      curve: widget.fadeInCurve,
      child: child,
    );
  }
}
