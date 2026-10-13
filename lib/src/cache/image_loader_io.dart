import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
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
    BaseCacheManager? manager = cacheManager;
    if (manager == null) {
      if (Platform.environment.containsKey('FLUTTER_TEST')) {
        // In Flutter test environments without custom cacheManager,
        // DefaultCacheManager hangs due to unmocked path_provider/sqflite plugins.
        yield* _loadDirectHttp(url, headers, chunkEvents, decode, evictImage);
        return;
      }
      manager = DefaultCacheManager();
    }

    final stream = (manager is ImageCacheManager &&
            (maxWidth != null || maxHeight != null))
        ? manager.getImageFile(
            url,
            maxHeight: maxHeight,
            maxWidth: maxWidth,
            withProgress: true,
            headers: headers,
            key: cacheKey,
          )
        : manager.getFileStream(
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
        final file = result.file;
        final bytes = await file.readAsBytes();
        final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
        final codec = await decode(buffer);
        yield codec;
      }
    }
  } on MissingPluginException {
    yield* _loadDirectHttp(url, headers, chunkEvents, decode, evictImage);
  } on Object catch (error, stackTrace) {
    scheduleMicrotask(evictImage);
    yield* Stream.error(error, stackTrace);
  } finally {
    await chunkEvents.close();
  }
}

Stream<ui.Codec> _loadDirectHttp(
  String url,
  Map<String, String>? headers,
  StreamController<ImageChunkEvent> chunkEvents,
  ImageDecoderCallback decode,
  VoidCallback evictImage,
) async* {
  try {
    final uri = Uri.parse(url);
    final client = HttpClient();
    final request = await client.getUrl(uri);
    headers?.forEach((name, value) {
      request.headers.add(name, value);
    });
    final response = await request.close();
    if (response.statusCode != HttpStatus.ok) {
      throw HttpException(
        'HTTP request failed, statusCode: ${response.statusCode}, $url',
        uri: uri,
      );
    }
    final bytes = await consolidateHttpClientResponseBytes(
      response,
      onBytesReceived: (cumulative, total) {
        chunkEvents.add(
          ImageChunkEvent(
            cumulativeBytesLoaded: cumulative,
            expectedTotalBytes: total,
          ),
        );
      },
    );
    final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
    final codec = await decode(buffer);
    yield codec;
  } on Object catch (error, stackTrace) {
    scheduleMicrotask(evictImage);
    yield* Stream.error(error, stackTrace);
  }
}
