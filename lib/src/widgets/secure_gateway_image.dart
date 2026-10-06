import 'dart:async';
import 'package:flutter/material.dart';

import '../models/creative_fallback_style.dart';
import '../models/gateway_image_error.dart';
import '../models/gateway_image_stage.dart';
import 'creative_fallback_avatar.dart';
import 'initials_avatar.dart';

/// Error-resilient image widget with intelligent retry logic and multi-tier fallbacks.
///
/// Fallback order:
///
/// ```text
/// Network (with max 3s retry by default)
///    ↓
/// Local ImageProvider
///    ↓
/// Asset
///    ↓
/// User Initials Avatar / Creative Fallback Avatar
/// ```
class SecureGatewayImage extends StatefulWidget {
  const SecureGatewayImage({
    this.networkUrl,
    this.cachedImage,
    this.assetPath,
    this.initials,
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
    this.enableRetry = true,
    this.retryDuration = const Duration(seconds: 3),
    this.retryInterval = const Duration(milliseconds: 1000),
    this.maxRetries,
    this.onError,
    this.onImageError,
    this.onRetry,
    this.retryingPlaceholder,
    this.creativeFallbackStyle = CreativeFallbackStyle.gradientGlow,
    this.fallbackIcon,
    this.fallbackIconColor,
    this.showErrorBadge = true,
    this.creativeFallbackBuilder,
    this.customErrorMessage,
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

  /// Name or initials set by the user used by the final avatar.
  /// If not provided, empty, or '?', the widget renders a creative fallback avatar.
  final String? initials;

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

  /// Whether to automatically retry loading failed network image sources.
  final bool enableRetry;

  /// Maximum time window during which retries will be attempted before failing.
  /// Defaults to 3 seconds.
  final Duration retryDuration;

  /// Delay between retry attempts. Defaults to 1 second.
  final Duration retryInterval;

  /// Maximum number of retry attempts. If null, retries continue until [retryDuration] is exceeded.
  final int? maxRetries;

  /// Callback invoked with error message and details when a source permanently fails after retrying.
  final void Function(String message, Object? error, StackTrace? stackTrace)? onError;

  /// Typed error callback providing rich [GatewayImageError] metadata.
  final void Function(GatewayImageError error)? onImageError;

  /// Callback invoked on each retry attempt.
  final void Function(int attempt, Duration elapsed)? onRetry;

  /// Optional widget displayed while retrying image load.
  final Widget Function(BuildContext context, int attempt)? retryingPlaceholder;

  /// Styling mode for the creative fallback avatar when initials are not set.
  final CreativeFallbackStyle creativeFallbackStyle;

  /// Custom center icon for the creative fallback avatar.
  final IconData? fallbackIcon;

  /// Custom center icon color for the creative fallback avatar.
  final Color? fallbackIconColor;

  /// Whether to render a small warning badge with tooltip on the creative avatar.
  final bool showErrorBadge;

  /// Custom builder for creative fallback when initials are not set.
  final Widget Function(BuildContext context, String? errorMessage)? creativeFallbackBuilder;

  /// Custom override for the error message.
  final String? customErrorMessage;

  @override
  State<SecureGatewayImage> createState() => _SecureGatewayImageState();
}

class _SecureGatewayImageState extends State<SecureGatewayImage> {
  late GatewayImageStage _stage;

  bool _transitionScheduled = false;

  int _retryAttempt = 0;
  Duration _accumulatedRetryDuration = Duration.zero;
  Timer? _retryTimer;
  Key _networkKey = UniqueKey();
  final Key _cacheKey = UniqueKey();
  final Key _assetKey = UniqueKey();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _stage = _initialStage();
  }

  @override
  void didUpdateWidget(covariant SecureGatewayImage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.networkUrl != widget.networkUrl ||
        oldWidget.cachedImage != widget.cachedImage ||
        oldWidget.assetPath != widget.assetPath) {
      _retryTimer?.cancel();
      _retryTimer = null;
      _retryAttempt = 0;
      _accumulatedRetryDuration = Duration.zero;
      _errorMessage = null;

      final nextStage = _initialStage();
      if (nextStage != _stage) {
        _setStage(nextStage);
      }
    }
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    super.dispose();
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

      _retryTimer?.cancel();
      _retryTimer = null;
      _retryAttempt = 0;
      _accumulatedRetryDuration = Duration.zero;

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
      key: _networkKey,
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
      errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
        final maxDuration = widget.retryDuration;
        final canRetry = widget.enableRetry &&
            maxDuration > Duration.zero &&
            _accumulatedRetryDuration < maxDuration &&
            (widget.maxRetries == null || _retryAttempt < widget.maxRetries!);

        if (canRetry) {
          if (_retryTimer == null || !_retryTimer!.isActive) {
            final remaining = maxDuration - _accumulatedRetryDuration;
            final delay = widget.retryInterval < remaining ? widget.retryInterval : remaining;

            _retryTimer = Timer(delay, () {
              if (!mounted || _stage != GatewayImageStage.network) {
                return;
              }
              _retryAttempt++;
              _accumulatedRetryDuration += delay;
              _networkKey = ValueKey('network-${widget.networkUrl}-attempt-$_retryAttempt');
              PaintingBinding.instance.imageCache.evict(
                NetworkImage(widget.networkUrl!, headers: widget.headers),
              );
              widget.onRetry?.call(_retryAttempt, _accumulatedRetryDuration);
              if (mounted) {
                setState(() {});
              }
            });
          }

          return _buildRetryingPlaceholder();
        }

        // Retries exhausted or retrying disabled
        _retryTimer?.cancel();
        _retryTimer = null;

        final formattedMessage = widget.customErrorMessage ??
            (widget.enableRetry && _retryAttempt > 0
                ? 'Failed to load network image from "${widget.networkUrl}" after $_retryAttempt retry attempt(s) (${_accumulatedRetryDuration.inMilliseconds}ms): $error'
                : 'Failed to load network image from "${widget.networkUrl}": $error');

        _errorMessage = formattedMessage;

        final errorInfo = GatewayImageError(
          message: formattedMessage,
          error: error,
          stackTrace: stackTrace,
          stage: GatewayImageStage.network,
          source: widget.networkUrl,
          retryAttempts: _retryAttempt,
          totalRetryDuration: _accumulatedRetryDuration,
        );

        widget.onError?.call(formattedMessage, error, stackTrace);
        widget.onImageError?.call(errorInfo);

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
      key: _cacheKey,
      width: widget.width ?? widget.size,
      height: widget.height ?? widget.size,
      fit: widget.fit,
      alignment: widget.alignment,
      semanticLabel: widget.semanticLabel,
      excludeFromSemantics: widget.excludeFromSemantics,
      filterQuality: widget.filterQuality,
      frameBuilder: _frameBuilder,
      errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
        final msg = widget.customErrorMessage ?? 'Failed to load cached image: $error';
        _errorMessage = msg;

        final errorInfo = GatewayImageError(
          message: msg,
          error: error,
          stackTrace: stackTrace,
          stage: GatewayImageStage.cache,
          source: provider.toString(),
        );

        widget.onError?.call(msg, error, stackTrace);
        widget.onImageError?.call(errorInfo);

        _advance();
        return _buildLoadingPlaceholder();
      },
    );
  }

  Widget _buildAsset() {
    return Image.asset(
      widget.assetPath!,
      key: _assetKey,
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
      errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
        final msg = widget.customErrorMessage ?? 'Failed to load asset image "${widget.assetPath}": $error';
        _errorMessage = msg;

        final errorInfo = GatewayImageError(
          message: msg,
          error: error,
          stackTrace: stackTrace,
          stage: GatewayImageStage.asset,
          source: widget.assetPath,
        );

        widget.onError?.call(msg, error, stackTrace);
        widget.onImageError?.call(errorInfo);

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
        child: builder(context, widget.initials ?? '?'),
      );
    }

    final hasUserInitials = widget.initials != null &&
        widget.initials!.trim().isNotEmpty &&
        widget.initials!.trim() != '?';

    if (hasUserInitials) {
      return InitialsAvatar(
        initials: widget.initials!,
        size: widget.size,
        width: widget.width,
        height: widget.height,
        backgroundColor: widget.backgroundColor,
        textStyle: widget.avatarTextStyle,
        borderRadius: widget.borderRadius,
        animate: widget.animateAvatar,
        duration: widget.avatarAnimationDuration,
        curve: widget.avatarAnimationCurve,
      );
    }

    return CreativeFallbackAvatar(
      size: widget.size,
      width: widget.width,
      height: widget.height,
      borderRadius: widget.borderRadius,
      style: widget.creativeFallbackStyle,
      icon: widget.fallbackIcon,
      iconColor: widget.fallbackIconColor,
      backgroundColor: widget.backgroundColor,
      errorMessage: _errorMessage,
      showErrorBadge: widget.showErrorBadge,
      animate: widget.animateAvatar,
      duration: widget.avatarAnimationDuration,
      curve: widget.avatarAnimationCurve,
      seed: widget.networkUrl ?? widget.assetPath ?? widget.initials,
      customBuilder: widget.creativeFallbackBuilder,
    );
  }

  Widget _buildLoadingPlaceholder() {
    return widget.placeholder?.call(context) ??
        SizedBox(
          width: widget.width ?? widget.size,
          height: widget.height ?? widget.size,
        );
  }

  Widget _buildRetryingPlaceholder() {
    if (widget.retryingPlaceholder != null) {
      return SizedBox(
        width: widget.width ?? widget.size,
        height: widget.height ?? widget.size,
        child: widget.retryingPlaceholder!(context, _retryAttempt),
      );
    }

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
