import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'image_loader_stub.dart'
    if (dart.library.io) 'image_loader_io.dart'
    if (dart.library.js_interop) 'image_loader_web.dart'
    if (dart.library.html) 'image_loader_web.dart' as loader;

Stream<ui.Codec> loadImageFromCache({
  required String url,
  required String? cacheKey,
  required StreamController<ImageChunkEvent> chunkEvents,
  required ImageDecoderCallback decode,
  required BaseCacheManager? cacheManager,
  required int? maxHeight,
  required int? maxWidth,
  required Map<String, String>? headers,
  required VoidCallback evictImage,
}) {
  return loader.loadImageFromCache(
    url: url,
    cacheKey: cacheKey,
    chunkEvents: chunkEvents,
    decode: decode,
    cacheManager: cacheManager,
    maxHeight: maxHeight,
    maxWidth: maxWidth,
    headers: headers,
    evictImage: evictImage,
  );
}
