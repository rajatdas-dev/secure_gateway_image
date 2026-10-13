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
}) async* {
  try {
    final manager = cacheManager ?? DefaultCacheManager();
    final stream = manager.getFileStream(
      url,
      withProgress: true,
      headers: headers,
      key: cacheKey,
    );

    await for (final result in stream) {
      if (result is DownloadProgress) {
        chunkEvents.add(
          ImageChunkEvent(
            cumulativeBytesLoaded: result.downloaded,
            expectedTotalBytes: result.totalSize,
          ),
        );
      }
      if (result is FileInfo) {
        final bytes = await result.file.readAsBytes();
        final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
        final codec = await decode(buffer);
        yield codec;
      }
    }
  } on Object catch (error, stackTrace) {
    scheduleMicrotask(evictImage);
    yield* Stream.error(error, stackTrace);
  } finally {
    await chunkEvents.close();
  }
}
