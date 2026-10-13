import 'dart:async';
import 'dart:ui' as ui show Codec;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'image_loader.dart';
import 'multi_image_stream_completer.dart';

/// An [ImageProvider] that downloads and caches images from the network
/// using [BaseCacheManager], matching the caching mechanism of `cached_network_image`.
@immutable
class SecureGatewayCachedImageProvider
    extends ImageProvider<SecureGatewayCachedImageProvider> {
  const SecureGatewayCachedImageProvider(
    this.url, {
    this.cacheKey,
    this.scale = 1.0,
    this.headers,
    this.cacheManager,
    this.maxHeight,
    this.maxWidth,
    this.errorListener,
  });

  /// The remote web URL of the image.
  final String url;

  /// Custom cache key. If null, [url] is used as the cache key.
  final String? cacheKey;

  /// The scale to place in the [ImageInfo] object of the image.
  final double scale;

  /// Optional HTTP headers sent with the network request.
  final Map<String, String>? headers;

  /// Optional [BaseCacheManager] to manage caching. If null, [defaultCacheManager] is used.
  final BaseCacheManager? cacheManager;

  /// Optional maximum height for resizing on disk when using an [ImageCacheManager].
  final int? maxHeight;

  /// Optional maximum width for resizing on disk when using an [ImageCacheManager].
  final int? maxWidth;

  /// Optional listener called when image loading fails.
  final ValueChanged<Object>? errorListener;

  /// Default cache manager used across all providers when none is specified.
  static BaseCacheManager? _defaultCacheManager;

  /// Gets or sets the default [BaseCacheManager].
  static BaseCacheManager get defaultCacheManager {
    return _defaultCacheManager ??= DefaultCacheManager();
  }

  static set defaultCacheManager(BaseCacheManager manager) {
    _defaultCacheManager = manager;
  }

  /// Evicts the specified image from both Flutter's [ImageCache] and disk cache.
  static Future<void> evictFromCache(
    String url, {
    String? cacheKey,
    BaseCacheManager? cacheManager,
    double scale = 1.0,
  }) async {
    final provider = SecureGatewayCachedImageProvider(
      url,
      cacheKey: cacheKey,
      cacheManager: cacheManager,
      scale: scale,
    );
    PaintingBinding.instance.imageCache.evict(provider);
    final key = cacheKey ?? url;
    final manager = cacheManager ?? defaultCacheManager;
    await manager.removeFile(key);
  }

  /// Evicts this image from Flutter's in-memory [ImageCache].
  bool evictFromMemory() {
    return PaintingBinding.instance.imageCache.evict(this);
  }

  @override
  Future<SecureGatewayCachedImageProvider> obtainKey(
    ImageConfiguration configuration,
  ) {
    return SynchronousFuture<SecureGatewayCachedImageProvider>(this);
  }

  @override
  ImageStreamCompleter loadImage(
    SecureGatewayCachedImageProvider key,
    ImageDecoderCallback decode,
  ) {
    final chunkEvents = StreamController<ImageChunkEvent>();
    final imageStreamCompleter = MultiImageStreamCompleter(
      codec: _loadImageAsync(key, chunkEvents, decode),
      chunkEvents: chunkEvents.stream,
      scale: key.scale,
      debugLabel: key.url,
      informationCollector: () => <DiagnosticsNode>[
        DiagnosticsProperty<ImageProvider>('Image provider', this),
        DiagnosticsProperty<SecureGatewayCachedImageProvider>('Image key', key),
      ],
    );

    if (errorListener != null) {
      imageStreamCompleter.addListener(
        ImageStreamListener(
          (image, synchronousCall) {},
          onError: (Object error, StackTrace? trace) {
            errorListener?.call(error);
          },
        ),
      );
    }

    return imageStreamCompleter;
  }

  Stream<ui.Codec> _loadImageAsync(
    SecureGatewayCachedImageProvider key,
    StreamController<ImageChunkEvent> chunkEvents,
    ImageDecoderCallback decode,
  ) {
    assert(key == this);
    return loadImageFromCache(
      url: url,
      cacheKey: cacheKey,
      chunkEvents: chunkEvents,
      decode: decode,
      cacheManager: cacheManager,
      maxHeight: maxHeight,
      maxWidth: maxWidth,
      headers: headers,
      evictImage: () => PaintingBinding.instance.imageCache.evict(key),
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is SecureGatewayCachedImageProvider) {
      return ((cacheKey ?? url) == (other.cacheKey ?? other.url)) &&
          scale == other.scale &&
          maxHeight == other.maxHeight &&
          maxWidth == other.maxWidth;
    }
    return false;
  }

  @override
  int get hashCode => Object.hash(cacheKey ?? url, scale, maxHeight, maxWidth);

  @override
  String toString() =>
      'SecureGatewayCachedImageProvider("$url", scale: $scale)';
}
