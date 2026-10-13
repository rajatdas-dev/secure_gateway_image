import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

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
}) =>
    throw UnsupportedError('Platform not supported');
